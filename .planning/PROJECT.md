# ccpocket

## What This Is

ccpocket 是一个面向 Claude Code 和 Codex CLI 的移动客户端应用。用户通过 Flutter 移动应用（iOS/Android/Web）连接到本地的 Bridge Server（Node.js/TypeScript），通过 WebSocket 实时与 Claude Code 或 Codex AI 编码代理交互。支持多会话管理、工具审批、流式响应、推送通知等功能。

这是一个已发布的产品，通过 TestFlight 和 Google Play 分发，支持 Shorebird OTA 热更新。

## Core Value

用户可以在移动设备上实时与 Claude Code / Codex 交互——包括发送消息、审批工具执行、查看结果——完全保留桌面端 CLI 的能力。

## Requirements

### Validated

<!-- 从现有代码库推导出的已实现功能 -->

- ✓ WebSocket 连接到 Bridge Server — existing
- ✓ 创建和管理多个 Claude Code / Codex 会话 — existing
- ✓ 实时流式文本显示 AI 响应 — existing
- ✓ 工具执行审批（Approve/Reject）— existing
- ✓ 会话历史查看和恢复 — existing
- ✓ mDNS 自动发现本地 Bridge Server — existing
- ✓ 多机器/远程 Bridge 管理和 SSH 启动 — existing
- ✓ FCM 推送通知（工具审批请求、会话完成等）— existing
- ✓ 二维码扫描连接 — existing
- ✓ Git diff 查看和文件变更预览 — existing
- ✓ Diff 图片自动展示 — existing
- ✓ 消息中图片查看器 — existing
- ✓ 语音输入消息 — existing
- ✓ 会话列表过滤、搜索和分页 — existing
- ✓ 设置页面（主题、语言、推送通知偏好）— existing
- ✓ 日中英三语本地化 — existing
- ✓ Codex 会话支持（approval policy, sandbox mode, model 选择）— existing
- ✓ 会话录屏功能 — existing
- ✓ Claude 使用量统计 — existing
- ✓ Shorebird OTA 热更新（stable/staging）— existing
- ✓ Bridge Server npm 发布 (@ccpocket/bridge) — existing
- ✓ CLI 权限模式（default, acceptEdits, bypassPermissions, plan）— existing
- ✓ Prompt 历史记录 — existing
- ✓ Graceful degradation（App/Bridge 版本不匹配处理）— existing
- ✓ Git branch/commit 查看 — existing
- ✓ 文件 @mention 自动补全 — existing
- ✓ Web 平台支持 — existing
- ✓ macOS 平台支持（DMG 分发）— existing

### Active

<!-- 当前开发范围，待实现的功能 -->

(由需求讨论阶段确定)

### Out of Scope

- [多用户/团队协作] — 当前为单用户工具
- [自建 AI 模型] — 依赖 Claude Code 和 Codex CLI，不自行训练模型

## Context

### 技术架构
- **三层架构**: Flutter App ↔ WebSocket ↔ Bridge Server ↔ CLI Agent (Claude Code SDK / Codex SDK)
- **状态管理**: flutter_bloc (Cubit) + Freezed 不可变状态
- **路由**: auto_route 声明式路由 + 代码生成
- **包管理**: npm workspaces (monorepo) + pub

### 现有产品状态
- 已发布到 TestFlight 和 Google Play
- 使用 Shorebird 进行 OTA 热更新
- Bridge Server 通过 npm 发布为 @ccpocket/bridge
- Firebase Cloud Functions 处理推送通知中继
- CI/CD 通过 GitHub Actions

### 已知技术债务
- `websocket.ts` 巨型文件 (4,333行)，需要拆分
- 3个严重安全问题：Firebase API key 硬编码、无 TLS 支持、API key 在 URL 查询参数中
- 无 WebSocket 心跳机制
- Bridge Server 缺少结构化日志
- CI 未测试 Bridge Server

## Constraints

- **技术栈**: Flutter/Dart (mobile) + TypeScript/Node.js (bridge)，不可更改
- **CLI 依赖**: 完全依赖 Claude Code SDK 和 Codex CLI，无法自定义 AI 行为
- **平台**: iOS 15+, Android (compileSdk), macOS 11.0, Web (功能受限)
- **Firebase**: 推送通知依赖 Firebase 项目 (ccpocket-ca33b)
- **单用户设计**: 移动端为单用户工具，无多租户需求
- **本地部署**: Bridge Server 需要运行在开发机器上，不支持云端托管

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| WebSocket 通信 | 实时双向通信需求 | ✓ Good |
| Bridge Server 中间件 | 隔离 CLI 进程管理与移动 UI | ✓ Good |
| Cubit + Freezed 状态管理 | 类型安全的不可变状态 | ✓ Good |
| Feature-first 目录结构 | 按功能组织代码 | ✓ Good |
| Shorebird OTA | 快速修复分发无需等待审核 | ✓ Good |
| mDNS 发现 | 零配置局域网连接 | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-02 after initialization*
