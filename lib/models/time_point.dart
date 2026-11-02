class TimePoint {
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;

  const TimePoint({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
  });

  DateTime get dateTime => DateTime(year, month, day, hour, minute);

  TimePoint copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) {
    return TimePoint(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}
