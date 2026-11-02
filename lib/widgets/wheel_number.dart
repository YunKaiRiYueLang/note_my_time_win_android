import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WheelNumber extends StatelessWidget {
  const WheelNumber({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.width = 72,
  });

  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          final delta = signal.scrollDelta.dy > 0 ? -1 : 1;
          var next = value + delta;
          if (next < min) next = max;
          if (next > max) next = min;
          onChanged(next);
        }
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          "$value$unit",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
