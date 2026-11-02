import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../time_log_service.dart';

class TimeLogDatabase {
  TimeLogDatabase._(this._database);

  static const _databaseFileName = 'time_log.db';
  static const _schemaVersion = 1;
  static const _tableName = 'time_records';
  static bool _platformFactoryConfigured = false;

  final Database _database;

  static Future<TimeLogDatabase> open() async {
    _configurePlatformFactory();
    final databasePath = p.join(await getDatabasesPath(), _databaseFileName);
    final database = await openDatabase(
      databasePath,
      version: _schemaVersion,
      onCreate: _createSchema,
    );
    return TimeLogDatabase._(database);
  }

  static Future<TimeLogDatabase> openInMemory() async {
    _configurePlatformFactory();
    final database = await openDatabase(
      inMemoryDatabasePath,
      version: _schemaVersion,
      onCreate: _createSchema,
    );
    return TimeLogDatabase._(database);
  }

  static void _configurePlatformFactory() {
    if (_platformFactoryConfigured) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      databaseFactory = sqflite.databaseFactory;
    }
    _platformFactoryConfigured = true;
  }

  static Future<void> _createSchema(Database database, int version) async {
    await database.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await database.execute(
      'CREATE INDEX idx_time_records_type ON $_tableName(type)',
    );
    await database.execute(
      'CREATE INDEX idx_time_records_start_time ON $_tableName(start_time)',
    );
  }

  Future<int> insert(TimeRecord record) {
    return _database.insert(_tableName, {
      'type': record.type,
      'start_time': record.startTime.millisecondsSinceEpoch,
      'end_time': record.endTime.millisecondsSinceEpoch,
      'content': record.content,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<TimeRecord>> query({
    String? type,
    DateTime? from,
    DateTime? to,
    String? keyword,
    int limit = 100,
    int offset = 0,
  }) async {
    final conditions = <String>[];
    final arguments = <Object?>[];

    if (type != null) {
      conditions.add('type = ?');
      arguments.add(type);
    }
    if (from != null) {
      conditions.add('start_time >= ?');
      arguments.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      conditions.add('start_time <= ?');
      arguments.add(to.millisecondsSinceEpoch);
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      conditions.add('(type LIKE ? OR content LIKE ?)');
      final pattern = '%${keyword.trim()}%';
      arguments
        ..add(pattern)
        ..add(pattern);
    }

    final rows = await _database.query(
      _tableName,
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'start_time DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_recordFromRow).toList();
  }

  Future<int> delete(int id) {
    return _database.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() => _database.close();

  static TimeRecord _recordFromRow(Map<String, Object?> row) {
    return TimeRecord(
      id: row['id'] as int?,
      type: row['type'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(row['end_time'] as int),
      content: row['content'] as String,
    );
  }
}
