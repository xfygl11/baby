# 萱萱成长记

> **"说句话，记录爱，陪她长大"** —— 用最自然的方式，珍藏 0-18 岁的成长记忆

一款陪伴宝宝 0-18 岁成长的智能记录 APP，以 **AI 智能交互为核心特色**，通过自然语言对话（文字 + 语音）轻松记录成长的每一个珍贵瞬间。从婴儿期的喂养睡眠，到学生时代的成绩荣誉，一句话完成记录，AI 还能生成每日总结、讲睡前故事、预测成长曲线。所有数据本地存储，重视隐私保护。

## 功能特性

- **AI 智能助手**：自然语言对话记录，支持文字与语音输入，自动提取意图与实体，一句话完成记录
- **全阶段成长记录**：覆盖 0-18 岁全生命周期，包含喂养、睡眠、尿布、体温、用药、疫苗、里程碑、日记等 30+ 记录类型
- **智能弹窗提醒**：根据宝宝月龄与行为规律，主动推送睡眠窗口、喂养间隔、疫苗提醒、体温复测、用药提醒等场景化提醒
- **成长曲线**：基于 WHO 生长标准数据，可视化身高体重发育曲线，支持成长预测
- **发育里程碑**：按月龄推送发育检查提醒，追踪大运动、语言、认知、社交等维度发展
- **疫苗管理**：国家免疫规划疫苗全周期管理，接种提醒与超期预警
- **时间线**：自动汇总所有记录，按时间倒序展示宝宝成长轨迹
- **每日总结**：AI 自动生成当日喂养、睡眠、体温等数据摘要
- **数据备份**：本地数据导出与导入，保障数据安全
- **分阶段主题**：随宝宝成长自动切换婴儿期、幼儿期、学龄前、小学期、青春期配色主题

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter >= 3.22.0 / Dart >= 3.3.0 |
| 状态管理 | Riverpod（flutter_riverpod + riverpod_annotation + riverpod_generator） |
| 本地数据库 | Drift（基于 SQLite 的类型安全 ORM） |
| 图表 | fl_chart |
| 本地通知 | flutter_local_notifications + timezone |
| 语音 | speech_to_text + flutter_sound |
| 存储 | shared_preferences + flutter_secure_storage |
| 其他 | intl、uuid、image_picker、share_plus、file_picker、permission_handler、dynamic_color |

## 项目结构

```
lib/
├── core/                       # 核心基础设施
│   ├── constants/              # 常量与枚举定义（app_enums.dart）
│   ├── theme/                  # 主题系统（颜色、间距、圆角、分阶段配色）
│   └── utils/                  # 工具类（日期时间处理等）
├── data/                       # 数据层
│   └── drift/
│       ├── daos/               # 数据访问对象（各业务表 Repository）
│       ├── tables/             # Drift 表定义
│       └── app_database.dart   # 数据库入口
├── presentation/               # 表现层
│   ├── pages/                  # 页面（首页、AI 助手、成长、时间线、设置等）
│   ├── providers/              # Riverpod Provider 定义
│   └── widgets/                # 可复用 UI 组件
├── services/                   # 业务服务层
│   ├── ai/                     # AI 对话引擎（意图识别、实体抽取、状态机、回复生成）
│   ├── popup/                  # 智能弹窗服务
│   ├── notification/           # 本地通知服务
│   ├── timeline/               # 时间线服务
│   ├── summary/                # 每日总结服务
│   ├── growth/                 # 成长曲线服务
│   ├── milestone/              # 发育里程碑服务
│   ├── vaccine/                # 疫苗服务
│   └── backup/                 # 数据备份服务
└── main.dart                   # 应用入口
```

## 开发环境要求

- **Flutter SDK**：>= 3.22.0
- **Dart SDK**：>= 3.3.0
- **Android Studio / VS Code**：推荐安装 Flutter 与 Dart 插件
- **Android**：minSdkVersion 21+，建议使用最新版 Android SDK
- **iOS**：iOS 12.0+（如需 iOS 开发）

## 构建和运行

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 生成 Drift 代码

项目使用 Drift 作为数据库 ORM，首次运行或修改表结构后需要执行代码生成：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. 运行应用

```bash
flutter run
```

## 重要说明

- **首次运行必须在有 Flutter SDK 的环境中执行 `build_runner`**：项目依赖 Drift 和 Riverpod 的代码生成（`*.g.dart` 文件），这些文件不纳入版本管理，需通过 `dart run build_runner build --delete-conflicting-outputs` 生成后项目才能正常编译运行。
- 若修改了 `lib/data/drift/tables/` 下的表定义或 `lib/presentation/providers/` 中的 Provider 注解，需重新执行步骤 2。
- 所有宝宝数据均存储在本地设备，不上传云端，请定期使用备份功能导出数据。
- 开发时若遇到生成的代码冲突，可添加 `--delete-conflicting-outputs` 参数强制重新生成。
