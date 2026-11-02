import 'dart:io';

class TimeRecord {
  final int? id;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final String content;

  const TimeRecord({
    this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.content,
  });

  String get durationText {
    final difference = endTime.difference(startTime);
    final duration = difference.isNegative ? Duration.zero : difference;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "$hours时$minutes分$seconds秒";
  }

  String get startTimeText => _formatDateTime(startTime);

  String get endTimeText => _formatDateTime(endTime);

  String toCsvLine() {
    return [
      _escapeCsvField(type),
      _escapeCsvField(startTimeText),
      _escapeCsvField(endTimeText),
      _escapeCsvField(durationText),
      _escapeCsvField(content),
    ].join(',');
  }

  static String _formatDateTime(DateTime time) {
    return "${time.year}-${_padTwoDigits(time.month)}-${_padTwoDigits(time.day)} "
        "${_padTwoDigits(time.hour)}:${_padTwoDigits(time.minute)}";
  }

  static String _padTwoDigits(int value) => value.toString().padLeft(2, '0');

  static String _escapeCsvField(String field) {
    final requiresQuoting =
        field.contains(',') || field.contains('"') || field.contains('\n');
    if (!requiresQuoting) return field;
    return '"${field.replaceAll('"', '""')}"';
  }
}

class CsvTimeLogger {
  static const _headerLine = '类型,起始时间,终止时间,时间间隔,内容\n';

  final File file;

  CsvTimeLogger(this.file);

  Future<void> appendRecord(TimeRecord record) async {
    final fileExists = await file.exists();
    final sink = file.openWrite(mode: FileMode.append);
    try {
      if (!fileExists) {
        sink.write(_headerLine);
      }
      sink.write('${record.toCsvLine()}\n');
    } finally {
      await sink.flush();
      await sink.close();
    }
  }
}
