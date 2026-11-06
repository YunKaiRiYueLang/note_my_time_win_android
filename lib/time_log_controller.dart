import 'dart:io';

import 'package:flutter/foundation.dart';

import 'data/time_log_database.dart';
import 'models/time_point.dart';
import 'time_log_service.dart';

class TimeLogController extends ChangeNotifier {
  TimeLogController({
    CsvTimeLogger? csvLogger,
    Future<TimeLogDatabase> Function()? openDatabase,
  })  : _csvLogger = csvLogger ?? CsvTimeLogger(File('./time_log.csv')),
        _openDatabase = openDatabase ?? TimeLogDatabase.open;

  static const tags = ['工作', '工作间隙休息', '吃饭', '阅读', '运动', '杂事'];

  final CsvTimeLogger _csvLogger;
  final Future<TimeLogDatabase> Function() _openDatabase;
  Future<TimeLogDatabase>? _databaseFuture;

  int _currentTagIndex = 0;
  TimePoint _start = const TimePoint(
    year: 2026,
    month: 9,
    day: 10,
    hour: 14,
    minute: 30,
  );
  TimePoint _end = const TimePoint(
    year: 2026,
    month: 9,
    day: 10,
    hour: 15,
    minute: 0,
  );

  String get currentTag => tags[_currentTagIndex];
  TimePoint get start => _start;
  TimePoint get end => _end;

  void showNextTag() {
    _currentTagIndex = (_currentTagIndex + 1) % tags.length;
    notifyListeners();
  }

  void showPreviousTag() {
    _currentTagIndex = (_currentTagIndex - 1 + tags.length) % tags.length;
    notifyListeners();
  }

  void selectTag(String tag) {
    final index = tags.indexOf(tag);
    if (index < 0 || index == _currentTagIndex) return;
    _currentTagIndex = index;
    notifyListeners();
  }

  void setStart(TimePoint value) {
    _start = value;
    notifyListeners();
  }

  void setEnd(TimePoint value) {
    _end = value;
    notifyListeners();
  }

  Future<bool> save(String rawContent) async {
    final content = rawContent.trim();
    if (content.isEmpty) return false;

    final record = TimeRecord(
      type: currentTag,
      startTime: _start.dateTime,
      endTime: _end.dateTime,
      content: content,
    );
    final database = await _database;
    await database.insert(record);
    await _appendToCsvBestEffort(record);
    return true;
  }

  Future<List<TimeRecord>> queryRecords({
    String? type,
    DateTime? from,
    DateTime? to,
    String? keyword,
    int limit = 100,
    int offset = 0,
  }) async {
    final database = await _database;
    return database.query(
      type: type,
      from: from,
      to: to,
      keyword: keyword,
      limit: limit,
      offset: offset,
    );
  }

  Future<TimeLogDatabase> get _database =>
      _databaseFuture ??= _openDatabase();

  Future<void> _appendToCsvBestEffort(TimeRecord record) async {
    try {
      await _csvLogger.appendRecord(record);
    } on FileSystemException catch (error) {
      debugPrint('CSV export failed: $error');
    }
  }

  @override
  void dispose() {
    _databaseFuture?.then((database) => database.close());
    super.dispose();
  }
}
