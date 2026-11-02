import 'package:flutter/foundation.dart';

import 'time_log_service.dart';

typedef TimeRecordQuery = Future<List<TimeRecord>> Function({
  String? type,
  DateTime? from,
  DateTime? to,
  String? keyword,
  int limit,
  int offset,
});

class HistoryController extends ChangeNotifier {
  HistoryController({required this.queryRecords});

  static const pageSize = 30;

  final TimeRecordQuery queryRecords;

  final List<TimeRecord> _records = [];
  String? _type;
  DateTime? _from;
  DateTime? _to;
  String _keyword = '';
  bool _isLoading = false;
  bool _hasMore = true;
  Object? _error;
  int _requestId = 0;

  List<TimeRecord> get records => List.unmodifiable(_records);
  String? get type => _type;
  DateTime? get from => _from;
  DateTime? get to => _to;
  String get keyword => _keyword;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  Object? get error => _error;
  bool get isEmpty => !_isLoading && _error == null && _records.isEmpty;

  Future<void> refresh() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _fetch(offset: 0);
      if (requestId != _requestId) return;
      _records
        ..clear()
        ..addAll(results);
      _hasMore = results.length == pageSize;
    } catch (error) {
      if (requestId != _requestId) return;
      _error = error;
      _hasMore = false;
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    final requestId = _requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _fetch(offset: _records.length);
      if (requestId != _requestId) return;
      _records.addAll(results);
      _hasMore = results.length == pageSize;
    } catch (error) {
      if (requestId != _requestId) return;
      _error = error;
      _hasMore = false;
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setType(String? value) async {
    if (_type == value) return;
    _type = value;
    await refresh();
  }

  Future<void> setKeyword(String value) async {
    final trimmed = value.trim();
    if (_keyword == trimmed) return;
    _keyword = trimmed;
    await refresh();
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    if (_from == from && _to == to) return;
    _from = from;
    _to = to;
    await refresh();
  }

  Future<void> clearFilters() async {
    if (_type == null &&
        _from == null &&
        _to == null &&
        _keyword.isEmpty) {
      return;
    }
    _type = null;
    _from = null;
    _to = null;
    _keyword = '';
    await refresh();
  }

  Future<List<TimeRecord>> _fetch({required int offset}) {
    return queryRecords(
      type: _type,
      from: _from,
      to: _to,
      keyword: _keyword,
      limit: pageSize,
      offset: offset,
    );
  }
}
