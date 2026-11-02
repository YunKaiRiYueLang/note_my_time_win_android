import 'dart:io';

import 'package:flutter/foundation.dart';

import 'models/time_point.dart';
import 'time_log_service.dart';

class TimeLogController extends ChangeNotifier {
  TimeLogController({CsvTimeLogger? logger})
      : _logger = logger ?? CsvTimeLogger(File('./time_log.csv'));

  static const tags = ['工作', '工作间隙休息', '吃饭', '阅读', '运动', '杂事'];

  final CsvTimeLogger _logger;

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

    await _logger.appendRecord(
      TimeRecord(
        type: currentTag,
        startTime: _start.dateTime,
        endTime: _end.dateTime,
        content: content,
      ),
    );
    return true;
  }
}
