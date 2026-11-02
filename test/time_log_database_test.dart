import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/data/time_log_database.dart';
import 'package:flutter_application_1/time_log_service.dart';

void main() {
  test('inserts and queries records', () async {
    final database = await TimeLogDatabase.openInMemory();
    addTearDown(database.close);

    await database.insert(
      TimeRecord(
        type: '工作',
        startTime: DateTime(2026, 9, 10, 9),
        endTime: DateTime(2026, 9, 10, 10),
        content: '写代码',
      ),
    );
    await database.insert(
      TimeRecord(
        type: '阅读',
        startTime: DateTime(2026, 9, 11, 9),
        endTime: DateTime(2026, 9, 11, 10),
        content: '读书',
      ),
    );

    final byKeyword = await database.query(keyword: '代码');
    expect(byKeyword, hasLength(1));
    expect(byKeyword.single.type, '工作');

    final byType = await database.query(type: '阅读');
    expect(byType, hasLength(1));
    expect(byType.single.content, '读书');

    final byDateRange = await database.query(
      from: DateTime(2026, 9, 11),
      to: DateTime(2026, 9, 11, 23, 59),
    );
    expect(byDateRange, hasLength(1));
    expect(byDateRange.single.type, '阅读');
  });
}
