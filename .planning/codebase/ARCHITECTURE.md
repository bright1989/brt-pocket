# 系统架构

**分析日期：** 2026-04-04

## 整体模式

多组件架构，由三个独立应用/服务组成，通过 WebSocket 和 Firebase 互联：

```
┌─────────────────┐    WebSocket     ┌──────────────────┐    subprocess    ┌──────────────┐
│   Flutter App   │◄────────────────►│   Bridge Server  │◄───────────────►│  Claude Code  │
│  (mobile/iOS/   │                  │   (Node.js)      │                  │  Codex CLI    │
│   Android)      │    mDNS/QR       │                  │                  └──────────────┘
└─────────────────┘◄────────────────►│                  │
                                       └────────┬─────────┘
                                                │
                                                │ Firebase
                                                ▼
                                       ┌──────────────────┐
                                       │ Firebase Cloud   │
                                       │ Functions (FCM)  │
                                       └──────────────────┘
```

## 分层架构

### 移动端层次

```
Presentation    →  features/*/screens, widgets
State           →  providers/ (Cubit), flutter_hooks
Business Logic  →  services/, features/*/logic
Data            →  models/, database_service, sqflite
Infrastructure  →  bridge_service, server_discovery, fcm_service
Routing         →  router/ (auto_route)
```

### Bridge 服务器层次

```
CLI Entry       →  cli.ts
WebSocket Layer →  websocket.ts
Session Mgmt    →  session.ts, sessions-index.ts
Process Mgmt    →  codex-process.ts, sdk-process.ts
Services        →  gallery-store, worktree-store, git-operations
Infrastructure  →  mdns.ts, firebase-auth.ts, push-relay.ts
```

## 数据流

### 会话消息流

```
用户输入 → Mobile App → WebSocket → Bridge Server → Claude Code/Codex CLI
                                       │
响应 ← Mobile App ← WebSocket ← Bridge Server ← CLI stdout
```

### 消息处理链
- `apps/mobile/lib/services/bridge_service.dart` — WebSocket 连接管理
- `apps/mobile/lib/services/chat_message_handler.dart` — 消息解析与路由
- `apps/mobile/lib/models/messages.dart` — 类型化消息模型
- `apps/mobile/lib/providers/stream_cubit.dart` — 消息流状态管理

### 推送通知流

```
Bridge 事件 → push-relay.ts → Firebase Function → FCM → Mobile App
                                                         │
                                                         ▼
                                                 notification_service
                                                 (前台: 本地通知)
                                                 (后台: 系统通知)
```

## 核心抽象

### BridgeService（移动端）
- **位置：** `apps/mobile/lib/services/bridge_service.dart`
- **基类：** `apps/mobile/lib/services/bridge_service_base.dart`
- **变体：**
  - `mock_bridge_service.dart` — Mock 数据（开发/预览）
  - `replay_bridge_service.dart` — 录制回放（调试）
- **职责：** WebSocket 生命周期、消息收发、重连管理

### Session（Bridge 端）
- **位置：** `packages/bridge/src/session.ts`
- **职责：** 会话生命周期管理、消息路由、进程绑定

### CodexProcess / SDKProcess（Bridge 端）
- **位置：** `packages/bridge/src/codex-process.ts`, `packages/bridge/src/sdk-process.ts`
- **职责：** CLI 子进程管理、stdin/stdout 管道、JSON-RPC 通信

## 状态管理模式

### BLoC/Cubit
- **位置：** `apps/mobile/lib/providers/`
- **核心 Cubit：**
  - `bridge_cubits.dart` — Bridge 连接状态
  - `machine_manager_cubit.dart` — 已知机器列表
  - `server_discovery_cubit.dart` — mDNS 发现状态
  - `stream_cubit.dart` — 消息流
  - `unseen_sessions_cubit.dart` — 未读会话计数
- **日志：** `talker_bloc_logger` 集成

### Hook 模式
- 使用 `flutter_hooks` 减少 StatefulWidget 样板代码
- 在 feature screens 中广泛使用

## 入口点

| 入口 | 文件 | 说明 |
|------|------|------|
| Flutter App | `apps/mobile/lib/main.dart` | 移动应用主入口 |
| Bridge CLI | `packages/bridge/src/cli.ts` | Bridge 命令行工具 |
| Bridge Server | `packages/bridge/src/index.ts` | Bridge 服务器入口 |
| Firebase Functions | `functions/src/index.ts` | 云函数入口 |

## Feature 模块

移动端采用 Feature-driven 组织：

| Feature | 目录 | 职责 |
|---------|------|------|
| Claude Session | `features/claude_session/` | Claude Code 会话 UI |
| Codex Session | `features/codex_session/` | Codex 会话 UI |
| Chat Session | `features/chat_session/` | 通用聊天组件 |
| Session List | `features/session_list/` | 会话列表主页 |
| Settings | `features/settings/` | 设置页面 |
| Git | `features/git/` | Git 操作 UI |
| Gallery | `features/gallery/` | 截图画廊 |
| Debug | `features/debug/` | 调试工具 |
| File Peek | `features/file_peek/` | 文件预览 |
| Message Images | `features/message_images/` | 消息内图片 |
| Prompt History | `features/prompt_history/` | 提示词历史 |
| Setup Guide | `features/setup_guide/` | 新手引导 |

## 设计决策

1. **双引擎支持** — 同时支持 Claude Code（SDK）和 Codex CLI，Bridge 层抽象了差异
2. **Mock 架构** — `mock/` 目录 + MockBridgeService 支持无需真实后端的开发预览
3. **代码生成** — freezed（模型）+ json_serializable（序列化）+ auto_route（路由）减少样板
4. **录制回放** — replay_bridge_service 支持调试场景复现
5. **Monorepo** — npm workspaces 管理共享逻辑，Flutter 应用独立于 Bridge 包

---

*架构分析：2026-04-04*
