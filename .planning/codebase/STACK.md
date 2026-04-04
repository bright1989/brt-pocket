# 技术栈

**分析日期：** 2026-04-04

## 语言与运行时

| 层级 | 语言 | 运行时 |
|------|------|--------|
| 移动端 | Dart 3.11+ | Flutter |
| Bridge 服务器 | TypeScript 5.7+ | Node.js >=18.0.0 |
| Firebase Functions | TypeScript | Firebase Cloud Functions |

## 核心框架

- **Flutter** — 跨平台移动 UI（iOS/Android）
- **Flutter BLoC** (`flutter_bloc ^9.1.0`) — 状态管理（Cubit 模式）
- **auto_route** (`^11.1.0`) — 声明式路由
- **freezed** (`^3.1.0`) — 不可变数据模型 + 联合类型
- **flutter_hooks** (`^0.21.3+1`) — Hook 式 Widget 构建
- **WebSocket** (`web_socket_channel ^3.0.3`, `ws ^8.18.0`) — 实时双向通信

## 关键依赖

### 移动端（`apps/mobile/pubspec.yaml`）

| 包 | 版本 | 用途 |
|----|------|------|
| `web_socket_channel` | ^3.0.3 | WebSocket 客户端 |
| `marionette_flutter` | ^0.4.0 | Marionette 桌面通信协议 |
| `shared_preferences` | ^2.5.0 | 本地 KV 存储 |
| `sqflite` | ^2.4.2 | 本地 SQLite 数据库 |
| `flutter_local_notifications` | ^20.0.0 | 本地通知 |
| `flutter_markdown` | ^0.7.7+1 | Markdown 渲染 |
| `google_fonts` | ^8.0.0 | 字体加载 |
| `bonsoir` | ^6.0.1 | mDNS 服务发现（Bonjour） |
| `mobile_scanner` | ^7.1.4 | 二维码扫描 |
| `speech_to_text` | ^7.3.0 | 语音输入 |
| `http` | ^1.6.0 | HTTP 客户端 |
| `dartssh2` | ^2.10.0 | SSH 连接 |
| `flutter_secure_storage` | ^10.0.0 | 安全存储 |
| `firebase_core` | ^4.4.0 | Firebase 核心 |
| `firebase_messaging` | ^16.1.1 | Firebase 推送通知 |
| `shorebird_code_push` | ^2.0.5 | OTA 热更新 |
| `highlight` / `syntax_highlight` | ^0.7.0 / ^0.5.0 | 代码语法高亮 |
| `super_drag_and_drop` | ^0.9.1 | 跨应用拖放 |
| `in_app_review` | ^2.0.11 | 应用内评分 |

### Bridge 服务器（`packages/bridge/package.json`）

| 包 | 版本 | 用途 |
|----|------|------|
| `@anthropic-ai/claude-agent-sdk` | ^0.2.74 | Claude Code Agent SDK |
| `ws` | ^8.18.0 | WebSocket 服务器 |
| `bonjour-service` | ^1.3.0 | mDNS 服务发布 |
| `qrcode` | ^1.5.4 | 二维码生成 |
| `socks` | ^2.8.7 | SOCKS 代理支持 |
| `undici` | ^7.24.4 | HTTP 客户端 |

### 开发依赖

| 工具 | 用途 |
|------|------|
| `vitest ^4.0.18` | Bridge 单元测试 |
| `@vitest/coverage-v8 ^4.0.18` | 测试覆盖率 |
| `bloc_test ^10.0.0` | BLoC 状态测试 |
| `patrol_finders ^3.1.0` | UI 测试 Finder |
| `build_runner ^2.5.4` | 代码生成（freezed, json_serializable, auto_route） |

## 项目结构模式

- **Monorepo** — npm workspaces（`packages/*`）
- **多应用** — `apps/mobile/`（Flutter） + `packages/bridge/`（Node.js） + `functions/`（Firebase）
- **代码生成** — freezed + json_serializable + auto_route_generator

## 版本信息

- **应用版本：** 1.53.0+89
- **Bridge 版本：** 1.33.0
- **Dart SDK：** ^3.11.0
- **许可证：** FSL-1.1-MIT（应用）/ MIT（Bridge 包）

## 配置文件

| 文件 | 用途 |
|------|------|
| `apps/mobile/pubspec.yaml` | Flutter 依赖声明 |
| `packages/bridge/package.json` | Bridge 依赖声明 |
| `functions/package.json` | Firebase Functions 依赖 |
| `apps/mobile/shorebird.yaml` | Shorebird OTA 配置 |
| `apps/mobile/android/gradle.properties` | Android 构建配置 |

---

*技术栈分析：2026-04-04*
