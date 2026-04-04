# 外部集成

**分析日期：** 2026-04-04

## 核心通信

### WebSocket 协议
- **角色：** 移动端 ↔ Bridge 服务器的实时双向通信
- **移动端：** `web_socket_channel ^3.0.3`
- **Bridge 端：** `ws ^8.18.0`
- **协议：** JSON-RPC 风格消息（类型化消息模型在 `apps/mobile/lib/models/messages.dart`）

### Marionette 协议
- **角色：** 移动端 ↔ 桌面应用的远程控制
- **包：** `marionette_flutter ^0.4.0`
- **用途：** 截图、UI 自动化、远程操作

## 认证与身份

### Firebase Authentication
- **包：** `firebase_core ^4.4.0`, `firebase_messaging ^16.1.1`
- **用途：** 匿名认证（Bridge 端 `packages/bridge/src/firebase-auth.ts`）
- **流程：** Bridge 服务器使用 Firebase Auth 获取匿名 token，用于推送通知中继

### SSH 连接
- **包：** `dartssh2 ^2.10.0`
- **服务：** `apps/mobile/lib/services/ssh_startup_service.dart`
- **用途：** 远程启动机器上的 Bridge 服务器

### 安全存储
- **包：** `flutter_secure_storage ^10.0.0`
- **用途：** 存储敏感凭据（token、密钥等）

## 推送通知

### Firebase Cloud Messaging (FCM)
- **移动端：** `apps/mobile/lib/services/fcm_service.dart`
- **Bridge 端：** `packages/bridge/src/push-relay.ts`
- **Firebase Functions：** `functions/src/` — 推送中继 Cloud Function
- **流程：** Bridge → Firebase Function → FCM → 移动端

### 本地通知
- **包：** `flutter_local_notifications ^20.0.0`
- **服务：** `apps/mobile/lib/services/notification_service.dart`
- **用途：** 前台/后台通知显示

## 服务发现

### mDNS / Bonjour
- **移动端：** `bonsoir ^6.0.1` → `apps/mobile/lib/services/server_discovery_service.dart`
- **Bridge 端：** `bonjour-service ^1.3.0` → `packages/bridge/src/mdns.ts`
- **用途：** 局域网内自动发现 Bridge 服务器

### 二维码连接
- **扫描：** `mobile_scanner ^7.1.4` → `apps/mobile/lib/screens/qr_scan_screen.dart`
- **生成：** `qrcode ^1.5.4` → Bridge 端
- **解析：** `apps/mobile/lib/services/connection_url_parser.dart`

## Claude Code / Codex 集成

### Claude Agent SDK
- **包：** `@anthropic-ai/claude-agent-sdk ^0.2.74`
- **服务：** `packages/bridge/src/sdk-process.ts`
- **用途：** Bridge 服务器作为 Claude Code 的进程管理器

### Codex CLI
- **服务：** `packages/bridge/src/codex-process.ts`
- **用途：** Bridge 服务器管理 Codex CLI 子进程

## 数据存储

### 本地数据库
- **包：** `sqflite ^2.4.2`
- **服务：** `apps/mobile/lib/services/database_service.dart`
- **用途：** 本地消息持久化、会话数据存储

### SharedPreferences
- **包：** `shared_preferences ^2.5.0`
- **用途：** 用户设置、轻量 KV 存储

### Gallery Store
- **服务：** `packages/bridge/src/gallery-store.ts`
- **用途：** 截图/图片存储管理

## 网络

### SOCKS 代理
- **包：** `socks ^2.8.7`（Bridge）/ `dartssh2`（移动端隧道）
- **用途：** 通过 SSH 隧道连接远程 Bridge

### HTTP
- **包：** `http ^1.6.0`（移动端）/ `undici ^7.24.4`（Bridge）
- **用途：** API 请求、资源下载

## 第三方服务

### Shorebird Code Push
- **包：** `shorebird_code_push ^2.0.5`
- **配置：** `apps/mobile/shorebird.yaml`
- **用途：** OTA 热更新，无需应用商店发布即可推送补丁
- **脚本：** `.claude/skills/shorebird-patch/patch.cjs`, `promote.cjs`

### App Links / Deep Links
- **包：** `app_links ^7.0.0`
- **用途：** 通过 URL scheme 打开应用特定页面

### 应用内评分
- **包：** `in_app_review ^2.0.11`
- **服务：** `apps/mobile/lib/services/in_app_review_service.dart`

### 语音输入
- **包：** `speech_to_text ^7.3.0`
- **服务：** `apps/mobile/lib/services/voice_input_service.dart`

### 分享与剪贴板
- **包：** `share_plus ^12.0.1`（分享）/ `super_clipboard ^0.9.1`（剪贴板）

### 图片处理
- **包：** `image_picker ^1.1.2`（图片选择）/ `extended_image ^10.0.1`（图片显示）

---

*集成分析：2026-04-04*
