import 'package:flutter/material.dart';

import 'history_controller.dart';
import 'time_log_controller.dart';
import 'time_log_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.timeLogController});

  final TimeLogController timeLogController;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController _keywordController = TextEditingController();
  late final HistoryController _historyController;

  @override
  void initState() {
    super.initState();
    _historyController = HistoryController(
      queryRecords: widget.timeLogController.queryRecords,
    );
    _historyController.refresh();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final from = _historyController.from;
    final to = _historyController.to;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: from == null || to == null
          ? null
          : DateTimeRange(start: from, end: to),
    );
    if (picked == null) return;

    final endOfDay = DateTime(
      picked.end.year,
      picked.end.month,
      picked.end.day,
      23,
      59,
      59,
      999,
    );
    _historyController.setDateRange(picked.start, endOfDay);
  }

  void _clearFilters() {
    _keywordController.clear();
    _historyController.clearFilters();
  }

  String get _dateRangeLabel {
    final from = _historyController.from;
    final to = _historyController.to;
    if (from == null || to == null) return '全部日期';
    return '${_formatDate(from)} ~ ${_formatDate(to)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${_padTwo(date.month)}-${_padTwo(date.day)}';
  }

  static String _padTwo(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off),
            tooltip: '清除筛选',
          ),
          IconButton(
            onPressed: _historyController.refresh,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _historyController,
        builder: (context, _) {
          return Column(
            children: [
              _buildFilters(),
              const Divider(height: 1),
              Expanded(child: _buildRecords(context)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: '按内容或标签搜索',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _historyController.setKeyword,
            ),
          ),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String?>(
              key: ValueKey(_historyController.type),
              initialValue: _historyController.type,
              decoration: const InputDecoration(
                labelText: '标签',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('全部标签'),
                ),
                ...TimeLogController.tags.map(
                  (tag) => DropdownMenuItem<String?>(
                    value: tag,
                    child: Text(tag),
                  ),
                ),
              ],
              onChanged: _historyController.setType,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(_dateRangeLabel),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('清除筛选'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecords(BuildContext context) {
    final controller = _historyController;

    if (controller.isLoading && controller.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null && controller.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败：${controller.error}'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.refresh,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (controller.isEmpty) {
      return const Center(child: Text('暂无记录'));
    }

    final records = controller.records;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length + (controller.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == records.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: controller.isLoading
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: controller.loadMore,
                      child: const Text('加载更多'),
                    ),
            ),
          );
        }
        return _RecordCard(record: records[index]);
      },
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final TimeRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(label: Text(record.type)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.content,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${record.startTimeText} ~ ${record.endTimeText}'
              '  ·  ${record.durationText}',
            ),
          ],
        ),
      ),
    );
  }
}
