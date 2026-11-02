import 'package:flutter/material.dart';

import '../models/time_point.dart';
import 'wheel_number.dart';

class TimePointEditor extends StatelessWidget {
  const TimePointEditor({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimePoint value;
  final ValueChanged<TimePoint> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        WheelNumber(
          value: value.year,
          min: 2020,
          max: 2050,
          unit: "年",
          onChanged: (year) => onChanged(value.copyWith(year: year)),
        ),
        const SizedBox(width: 6),
        WheelNumber(
          value: value.month,
          min: 1,
          max: 12,
          unit: "月",
          onChanged: (month) => onChanged(value.copyWith(month: month)),
        ),
        const SizedBox(width: 6),
        WheelNumber(
          value: value.day,
          min: 1,
          max: 31,
          unit: "日",
          onChanged: (day) => onChanged(value.copyWith(day: day)),
        ),
        const SizedBox(width: 12),
        WheelNumber(
          value: value.hour,
          min: 0,
          max: 23,
          unit: "时",
          onChanged: (hour) => onChanged(value.copyWith(hour: hour)),
        ),
        const SizedBox(width: 6),
        WheelNumber(
          value: value.minute,
          min: 0,
          max: 59,
          unit: "分",
          onChanged: (minute) => onChanged(value.copyWith(minute: minute)),
        ),
      ],
    );
  }
}
