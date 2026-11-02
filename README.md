# flutter_application_1

一个用于记录时间事件的 Flutter 应用：选择标签、填写内容、设置起止时间，并将记录追加写入 CSV 文件。

## 架构建议

界面代码只负责界面。非界面的状态、逻辑、数据与模型应放在各自独立的文件中，避免把业务逻辑堆在 `main.dart` 或 State 里。

按职责分层：

| 层级 | 文件 | 职责 |
| --- | --- | --- |
| 界面 | `lib/main.dart` | 页面布局、交互回调、提示反馈，不包含业务规则 |
| 状态与逻辑 | `lib/time_log_controller.dart` | 标签切换、起止时间、保存流程，通过 `ChangeNotifier` 通知界面刷新 |
| 模型 | `lib/models/time_point.dart` | 时间点数据结构及 `copyWith` |
| 可复用组件 | `lib/widgets/` | 与业务无关的通用 UI 组件 |
| 数据服务 | `lib/time_log_service.dart` | `TimeRecord` 数据模型与 CSV 读写 |

### 目录结构

```
lib/
├── main.dart                    # 入口与界面
├── time_log_controller.dart     # 状态与业务逻辑
├── time_log_service.dart        # CSV 数据服务与记录模型
├── models/
│   └── time_point.dart          # 时间点模型
└── widgets/
    ├── wheel_number.dart        # 滚轮数字输入组件
    └── time_point_editor.dart   # 年/月/日/时/分编辑行
```

### 约定

- 界面层不直接读写文件，也不计算业务数据；统一调用控制器。
- 控制器持有状态并通过 `notifyListeners()` 驱动界面更新。
- 组件只接收数据与回调，不依赖具体业务状态。
- 代码优先通过命名表达意图，尽量少用解释性注释。
- 新增功能时先判断归属层级，再放入对应文件，避免交叉依赖。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
