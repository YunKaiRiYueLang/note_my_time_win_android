import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'history_page.dart';
import 'time_log_controller.dart';
import 'widgets/time_point_editor.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _inputController = TextEditingController();
  late final TimeLogController _timeLogController;

  @override
  void initState() {
    super.initState();
    _timeLogController = TimeLogController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _timeLogController.dispose();
    super.dispose();
  }

  Future<void> _submitContent(String inputText) async {
    try {
      final saved = await _timeLogController.save(inputText);
      if (!mounted || !saved) return;

      _inputController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("记录保存成功")));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("保存失败：$error")));
    }
  }

  void _cycleTag(double scrollDelta) {
    if (scrollDelta < 0) {
      _timeLogController.showNextTag();
    } else {
      _timeLogController.showPreviousTag();
    }
  }

  void _fillTagIntoInput() {
    _inputController.text = _timeLogController.currentTag;
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HistoryPage(timeLogController: _timeLogController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timeLogController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [
              IconButton(
                onPressed: _openHistory,
                icon: const Icon(Icons.history),
                tooltip: '历史记录',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Listener(
                      onPointerSignal: (signal) {
                        if (signal is PointerScrollEvent) {
                          _cycleTag(signal.scrollDelta.dy);
                        }
                      },
                      child: InkWell(
                        onTap: _fillTagIntoInput,
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
                            _timeLogController.currentTag,
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
                        onSubmitted: _submitContent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TimePointEditor(
                  label: "起始时间：",
                  value: _timeLogController.start,
                  onChanged: _timeLogController.setStart,
                ),
                const SizedBox(height: 16),
                TimePointEditor(
                  label: "终止时间：",
                  value: _timeLogController.end,
                  onChanged: _timeLogController.setEnd,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
