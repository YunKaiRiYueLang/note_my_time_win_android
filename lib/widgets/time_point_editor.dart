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

  static const _compactBreakpoint = 600.0;

  final String label;
  final TimePoint value;
  final ValueChanged<TimePoint> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < _compactBreakpoint;
    return isCompact ? _buildCompact(context) : _buildWheelRow();
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDateTime(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formattedDateTime,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelRow() {
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

  Future<void> _pickDateTime(BuildContext context) async {
    final initial = value.dateTime;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050, 12, 31),
    );
    if (selectedDate == null || !context.mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (selectedTime == null) return;

    onChanged(
      value.copyWith(
        year: selectedDate.year,
        month: selectedDate.month,
        day: selectedDate.day,
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      ),
    );
  }

  String get _formattedDateTime {
    final dateTime = value.dateTime;
    return '${dateTime.year}-${_padTwo(dateTime.month)}-${_padTwo(dateTime.day)} '
        '${_padTwo(dateTime.hour)}:${_padTwo(dateTime.minute)}';
  }

  static String _padTwo(int value) => value.toString().padLeft(2, '0');
}
