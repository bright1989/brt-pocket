# 目录结构

**分析日期：** 2026-04-04

## 顶层布局

```
brt-pocket/
├── apps/
│   └── mobile/                    # Flutter 移动应用
├── packages/
│   └── bridge/                    # Node.js Bridge 服务器
├── functions/                     # Firebase Cloud Functions
├── scripts/                       # 构建/开发脚本
├── docs/                          # 文档
├── .claude/                       # Claude Code 配置
└── package.json                   # Monorepo 根配置
```

## apps/mobile/ — Flutter 移动应用

```
apps/mobile/
├── lib/
│   ├── main.dart                  # 应用入口
│   ├── constants/                 # 全局常量
│   ├── core/                      # 核心工具/基类
│   ├── features/                  # 功能模块（Feature-driven）
│   │   ├── claude_session/        #   Claude Code 会话
│   │   ├── codex_session/         #   Codex 会话
│   │   ├── chat_session/          #   通用聊天组件
│   │   ├── session_list/          #   会话列表（主页）
│   │   ├── settings/              #   设置
│   │   ├── git/                   #   Git 操作
│   │   ├── gallery/               #   截图画廊
│   │   ├── debug/                 #   调试面板
│   │   ├── file_peek/             #   文件预览
│   │   ├── message_images/        #   消息内嵌图片
│   │   ├── prompt_history/        #   提示词历史
│   │   └── setup_guide/           #   新手引导
│   ├── hooks/                     # 自定义 Flutter Hooks
│   ├── l10n/                      # 国际化资源
│   ├── mock/                      # Mock 数据（开发预览用）
│   ├── models/                    # 共享数据模型
│   │   ├── messages.dart          #   消息类型定义
│   │   ├── machine.dart           #   机器信息模型
│   │   ├── recorded_event.dart    #   录制事件模型
│   │   ├── terminal_app.dart      #   终端应用模型
│   │   └── new_session_tab.dart   #   新会话标签模型
│   ├── providers/                 # BLoC Cubit 状态管理
│   │   ├── bridge_cubits.dart     #   Bridge 连接状态
│   │   ├── machine_manager_cubit.dart
│   │   ├── server_discovery_cubit.dart
│   │   ├── stream_cubit.dart
│   │   └── unseen_sessions_cubit.dart
│   ├── router/                    # 路由（auto_route）
│   │   ├── app_router.dart        #   路由定义
│   │   └── app_router.gr.dart     #   生成文件
│   ├── screens/                   # 全局页面
│   │   ├── mock_preview_screen.dart
│   │   └── qr_scan_screen.dart
│   ├── services/                  # 核心服务层
│   │   ├── bridge_service.dart    #   WebSocket Bridge
│   │   ├── bridge_service_base.dart
│   │   ├── mock_bridge_service.dart
│   │   ├── replay_bridge_service.dart
│   │   ├── chat_message_handler.dart
│   │   ├── database_service.dart  #   SQLite 数据库
│   │   ├── fcm_service.dart       #   Firebase 推送
│   │   ├── notification_service.dart
│   │   ├── server_discovery_service.dart  # mDNS 发现
│   │   ├── machine_manager_service.dart
│   │   ├── voice_input_service.dart
│   │   ├── ssh_startup_service.dart
│   │   └── ...
│   ├── theme/                     # 主题定义
│   ├── utils/                     # 工具函数
│   └── widgets/                   # 共享 Widget
├── assets/docs/                   # 静态资源文档
├── test/                          # Flutter 测试
├── android/                       # Android 平台配置
├── ios/                           # iOS 平台配置
├── macos/                         # macOS 平台配置
├── pubspec.yaml                   # Flutter 依赖
└── shorebird.yaml                 # Shorebird OTA 配置
```

## packages/bridge/ — Bridge 服务器

```
packages/bridge/
├── src/
│   ├── index.ts                   # 服务器入口
│   ├── cli.ts                     # CLI 命令行
│   ├── websocket.ts               # WebSocket 服务器
│   ├── session.ts                 # 会话管理
│   ├── sessions-index.ts          # 会话索引
│   ├── codex-process.ts           # Codex CLI 进程
│   ├── sdk-process.ts             # Claude SDK 进程
│   ├── parser.ts                  # 消息解析
│   ├── mdns.ts                    # mDNS 服务发布
│   ├── firebase-auth.ts           # Firebase 认证
│   ├── push-relay.ts              # 推送通知中继
│   ├── push-i18n.ts               # 推送消息国际化
│   ├── gallery-store.ts           # 截图存储
│   ├── image-store.ts             # 图片存储
│   ├── git-assist.ts              # Git 操作
│   ├── git-operations.ts          # Git 底层操作
│   ├── worktree.ts                # Git worktree 管理
│   ├── worktree-store.ts          # Worktree 存储
│   ├── archive-store.ts           # 归档存储
│   ├── recording-store.ts         # 录制存储
│   ├── project-history.ts         # 项目历史
│   ├── prompt-history-backup.ts   # 提示词历史备份
│   ├── proxy.ts                   # SOCKS 代理
│   ├── screenshot.ts              # 截图功能
│   ├── doctor.ts                  # 环境诊断
│   ├── startup-info.ts            # 启动信息
│   ├── version.ts                 # 版本信息
│   ├── usage.ts                   # 使用统计
│   ├── debug-trace-store.ts       # 调试追踪
│   ├── setup-launchd.ts           # macOS launchd 配置
│   ├── setup-systemd.ts           # Linux systemd 配置
│   └── dev.ts                     # 开发模式入口
├── test/                          # 旧测试目录（空）
├── *.test.ts                      # 与源文件同目录的测试
├── package.json
└── tsconfig.json
```

## functions/ — Firebase Cloud Functions

```
functions/
├── src/
│   └── index.ts                   # 云函数入口（推送中继）
├── package.json
└── tsconfig.json
```

## scripts/ — 构建脚本

```
scripts/
├── build-android.cjs              # Android 构建
├── dev-restart.cjs                # 开发重启
├── setup-hooks.cjs                # Git hooks 安装
└── setup-launchd.cjs              # launchd 配置
```

## 关键位置速查

| 需求 | 文件路径 |
|------|----------|
| 应用入口 | `apps/mobile/lib/main.dart` |
| 消息模型 | `apps/mobile/lib/models/messages.dart` |
| Bridge 服务 | `apps/mobile/lib/services/bridge_service.dart` |
| 数据库服务 | `apps/mobile/lib/services/database_service.dart` |
| 路由配置 | `apps/mobile/lib/router/app_router.dart` |
| 状态管理 | `apps/mobile/lib/providers/` |
| Bridge 入口 | `packages/bridge/src/index.ts` |
| CLI 命令 | `packages/bridge/src/cli.ts` |
| 会话管理 | `packages/bridge/src/session.ts` |
| WebSocket | `packages/bridge/src/websocket.ts` |
| 推送中继 | `packages/bridge/src/push-relay.ts` |
| Monorepo 配置 | `package.json` |

## 命名约定

- **文件命名：** Flutter 用 snake_case（`bridge_service.dart`），TypeScript 用 kebab-case（`codex-process.ts`）
- **测试文件：** 与源文件同目录，添加 `.test` 后缀
- **生成文件：** `*.freezed.dart`, `*.g.dart`, `*.gr.dart` 由 build_runner 生成
- **Feature 目录：** snake_case（`claude_session/`, `session_list/`）

---

*目录结构分析：2026-04-04*
