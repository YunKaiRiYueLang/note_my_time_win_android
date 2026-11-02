import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// 引入独立逻辑文件
import 'time_log_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '时间记录器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 6, 44, 235),
        ),
      ),
      home: const MyHomePage(title: '时间记录'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 可鼠标滚轮增减的固定宽度数字组件，文字右对齐
class _WheelNumber extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;
  // 固定宽度，保证所有组件尺寸统一
  final double width;
  const _WheelNumber({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.width = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          int delta = signal.scrollDelta.dy > 0 ? -1 : 1;
          int next = value + delta;
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
        // 文字右对齐
        child: Text(
          "$value$unit",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _inputController;

  late final CsvTimeLogger _timeLogger;

  // 预设标签列表
  final List<String> _tags = ["工作", "工作间隙休息", "吃饭", "阅读", "运动", "杂事"];
  int _currentTagIndex = 0;

  // 起始时间 拆分为独立字段
  int _startYear = 2026;
  int _startMonth = 9;
  int _startDay = 10;
  int _startHour = 14;
  int _startMinute = 30;

  // 终止时间
  int _endYear = 2026;
  int _endMonth = 9;
  int _endDay = 10;
  int _endHour = 15;
  int _endMinute = 0;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _timeLogger = CsvTimeLogger(File('./time_log.csv'));
  }

  // 将界面上的起始时间字段组装DateTime
  DateTime _buildStartDateTime() {
    return DateTime(
      _startYear,
      _startMonth,
      _startDay,
      _startHour,
      _startMinute,
    );
  }

  DateTime _buildEndDateTime() {
    return DateTime(_endYear, _endMonth, _endDay, _endHour, _endMinute);
  }

  Future<void> _onTextFieldSubmit(String inputText) async {
    final content = inputText.trim();
    if (content.isEmpty) return;

    final record = TimeRecord(
      type: _tags[_currentTagIndex],
      startTime: _buildStartDateTime(),
      endTime: _buildEndDateTime(),
      content: content,
    );
    try {
      await _timeLogger.appendRecord(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("记录保存成功")));
      _inputController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("保存失败：$e")));
    }
  }

  // 滚轮切换顶部标签
  void _onScrollWheel(double delta) {
    setState(() {
      if (delta < 0) {
        _currentTagIndex = (_currentTagIndex + 1) % _tags.length;
      } else {
        _currentTagIndex = (_currentTagIndex - 1 + _tags.length) % _tags.length;
      }
    });
  }

  // 点击标签填充到输入框
  void _onTagTap() {
    _inputController.text = _tags[_currentTagIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 一行：左侧滚轮标签 + 右侧输入框
            Row(
              children: [
                Listener(
                  onPointerSignal: (signal) {
                    if (signal is PointerScrollEvent) {
                      _onScrollWheel(signal.scrollDelta.dy);
                    }
                  },
                  child: InkWell(
                    onTap: _onTagTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _tags[_currentTagIndex],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      labelText: "输入事件内容，回车记录",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _onTextFieldSubmit, //绑定回车事件
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== 起始时间行 =====
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text("起始时间：", style: TextStyle(fontSize: 14)),
                ),
                _WheelNumber(
                  value: _startYear,
                  min: 2020,
                  max: 2050,
                  unit: "年",
                  onChanged: (v) => setState(() => _startYear = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _startMonth,
                  min: 1,
                  max: 12,
                  unit: "月",
                  onChanged: (v) => setState(() => _startMonth = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _startDay,
                  min: 1,
                  max: 31,
                  unit: "日",
                  onChanged: (v) => setState(() => _startDay = v),
                ),
                const SizedBox(width: 12),
                _WheelNumber(
                  value: _startHour,
                  min: 0,
                  max: 23,
                  unit: "时",
                  onChanged: (v) => setState(() => _startHour = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _startMinute,
                  min: 0,
                  max: 59,
                  unit: "分",
                  onChanged: (v) => setState(() => _startMinute = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== 终止时间行 =====
            Row(
              children: [
                const SizedBox(
                  width: 80,
                  child: Text("终止时间：", style: TextStyle(fontSize: 14)),
                ),
                _WheelNumber(
                  value: _endYear,
                  min: 2020,
                  max: 2050,
                  unit: "年",
                  onChanged: (v) => setState(() => _endYear = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _endMonth,
                  min: 1,
                  max: 12,
                  unit: "月",
                  onChanged: (v) => setState(() => _endMonth = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _endDay,
                  min: 1,
                  max: 31,
                  unit: "日",
                  onChanged: (v) => setState(() => _endDay = v),
                ),
                const SizedBox(width: 12),
                _WheelNumber(
                  value: _endHour,
                  min: 0,
                  max: 23,
                  unit: "时",
                  onChanged: (v) => setState(() => _endHour = v),
                ),
                const SizedBox(width: 6),
                _WheelNumber(
                  value: _endMinute,
                  min: 0,
                  max: 59,
                  unit: "分",
                  onChanged: (v) => setState(() => _endMinute = v),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
