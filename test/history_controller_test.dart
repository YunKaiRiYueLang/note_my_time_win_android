import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/history_controller.dart';
import 'package:flutter_application_1/time_log_service.dart';

void main() {
  test('loads, filters and paginates records', () async {
    final records = List.generate(
      45,
      (index) => TimeRecord(
        id: index,
        type: index.isEven ? '工作' : '阅读',
        startTime: DateTime(2026, 9, 10, 9).add(Duration(minutes: index)),
        endTime: DateTime(2026, 9, 10, 9, 1).add(Duration(minutes: index)),
        content: '记录 $index',
      ),
    );

    Future<List<TimeRecord>> queryRecords({
      String? type,
      DateTime? from,
      DateTime? to,
      String? keyword,
      int limit = 100,
      int offset = 0,
    }) async {
      final filtered = records.where((record) {
        if (type != null && record.type != type) return false;
        if (from != null && record.startTime.isBefore(from)) return false;
        if (to != null && record.startTime.isAfter(to)) return false;
        if (keyword != null &&
            !record.content.contains(keyword) &&
            !record.type.contains(keyword)) {
          return false;
        }
        return true;
      }).toList();
      return filtered.skip(offset).take(limit).toList();
    }

    final controller = HistoryController(queryRecords: queryRecords);
    addTearDown(controller.dispose);

    await controller.refresh();
    expect(controller.records, hasLength(HistoryController.pageSize));
    expect(controller.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.records, hasLength(45));
    expect(controller.hasMore, isFalse);

    await controller.setType('工作');
    expect(controller.records, hasLength(23));
    expect(
      controller.records.every((record) => record.type == '工作'),
      isTrue,
    );

    await controller.setKeyword('记录 0');
    expect(controller.records, hasLength(1));

    await controller.clearFilters();
    expect(controller.records, hasLength(HistoryController.pageSize));
    expect(controller.type, isNull);
    expect(controller.keyword, isEmpty);
  });
}
