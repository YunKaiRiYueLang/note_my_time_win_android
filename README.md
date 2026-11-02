# flutter_application_1

一个用于记录时间事件的 Flutter 应用：选择标签、填写内容、设置起止时间。记录同时写入 SQLite（主存储，便于查询）和 CSV（辅助导出）。

## 存储

主存储使用 SQLite，表结构如下：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | INTEGER | 自增主键 |
| `type` | TEXT | 事件类型（标签），已建索引 |
| `start_time` | INTEGER | 起始时间（epoch 毫秒），已建索引 |
| `end_time` | INTEGER | 终止时间（epoch 毫秒） |
| `content` | TEXT | 事件内容 |
| `created_at` | INTEGER | 创建时间（epoch 毫秒） |

保存时先写入 SQLite，再尽力追加到 `time_log.csv`；CSV 写入失败不会影响主存储。查询支持按类型、时间范围、关键字过滤及分页：

```dart
final records = await controller.queryRecords(
  type: '工作',
  from: DateTime(2026, 9, 1),
  to: DateTime(2026, 9, 30, 23, 59, 59),
  keyword: '代码',
  limit: 50,
  offset: 0,
);
```

Windows 与 Android 通过 `sqflite` / `sqflite_common_ffi` 统一访问，首次运行自动建表建索引，无需手动初始化。

## 历史记录

首页右上角进入历史记录页面，支持：

- 按内容或标签关键字搜索
- 按标签筛选
- 按日期范围筛选
- 分页加载（每页 30 条）
- 刷新与一键清除筛选

## 架构建议

界面代码只负责界面。非界面的状态、逻辑、数据与模型应放在各自独立的文件中，避免把业务逻辑堆在 `main.dart` 或 State 里。

按职责分层：

| 层级 | 文件 | 职责 |
| --- | --- | --- |
| 界面 | `lib/main.dart`、`lib/history_page.dart` | 页面布局、交互回调、提示反馈，不包含业务规则 |
| 状态与逻辑 | `lib/time_log_controller.dart`、`lib/history_controller.dart` | 标签切换、起止时间、保存与查询流程，通过 `ChangeNotifier` 通知界面刷新 |
| 模型 | `lib/models/time_point.dart` | 时间点数据结构及 `copyWith` |
| 可复用组件 | `lib/widgets/` | 与业务无关的通用 UI 组件 |
| 数据服务 | `lib/time_log_service.dart` | `TimeRecord` 数据模型与 CSV 读写 |
| 数据库 | `lib/data/time_log_database.dart` | SQLite 建表、插入、查询、删除 |

### 目录结构

```
lib/
├── main.dart                    # 入口与录入界面
├── history_page.dart            # 历史记录界面
├── time_log_controller.dart     # 录入状态与业务逻辑
├── history_controller.dart      # 历史筛选与分页逻辑
├── time_log_service.dart        # CSV 数据服务与记录模型
├── data/
│   └── time_log_database.dart   # SQLite 存储与查询
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
