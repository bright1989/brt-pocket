# 技术债务与关注点

**分析日期：** 2026-04-04

## 技术债务

### 大型模型文件
- **位置：** `apps/mobile/lib/models/messages.dart`
- **问题：** Freezed 生成的联合类型模型可能超过 2000 行，导致编译时间增长
- **影响：** 代码导航困难，IDE 性能下降
- **建议：** 考虑拆分为多个文件（按消息类型分组）

### Mock Service 架构耦合
- **位置：** `apps/mobile/lib/services/mock_bridge_service.dart`, `apps/mobile/lib/mock/`
- **问题：** Mock 数据硬编码路径，与真实数据结构紧耦合
- **影响：** 当消息模型变更时，mock 数据容易过期
- **建议：** 使用序列化 JSON 文件替代硬编码 mock

### 代码生成依赖
- **问题：** 大量依赖 build_runner 生成代码（freezed, json_serializable, auto_route）
- **影响：** 生成文件增加仓库体积，初次构建耗时
- **现状：** 已是 Flutter 社区标准做法，风险可控

## 已知问题

### 消息历史加载
- **问题：** 长会话的消息历史加载可能卡顿或丢失
- **位置：** `apps/mobile/lib/services/chat_message_handler.dart`
- **影响：** 用户体验下降

### 键盘输入处理
- **问题：** 软键盘弹出时 UI 叠加/布局异常
- **位置：** 会话输入区域
- **影响：** 文本输入体验不稳定

## 安全关注点

### Mock 服务安全
- **位置：** `apps/mobile/lib/services/mock_bridge_service.dart`
- **问题：** Mock 模式下可能意外访问真实文件系统
- **风险：** 低 — Mock 仅用于开发预览，不进入生产构建

### WebSocket 认证
- **位置：** `packages/bridge/src/websocket.ts`
- **问题：** WebSocket 连接的认证机制依赖局域网隔离
- **风险：** 中 — 如果暴露到公网，需要额外认证层

### SSH 密钥管理
- **位置：** `apps/mobile/lib/services/ssh_startup_service.dart`
- **问题：** SSH 连接凭据的存储与管理
- **现状：** 使用 `flutter_secure_storage` 存储，风险可控

## 性能问题

### 大型 Widget 树
- **问题：** Session Card 等 Widget 可能过于复杂（嵌套层级深）
- **位置：** `apps/mobile/lib/features/session_list/`
- **影响：** 滚动性能下降，构建时间增加
- **建议：** 考虑使用 `RepaintBoundary` 或拆分 Widget

### 消息流 UI
- **问题：** 高频消息（如代码输出流）可能导致 UI 卡顿
- **位置：** 会话消息列表
- **建议：** 节流渲染、虚拟列表

### 数据库操作
- **位置：** `apps/mobile/lib/services/database_service.dart`
- **问题：** SQLite 读写可能阻塞 UI 线程
- **建议：** 确保数据库操作在 isolate 中执行

## 脆弱区域

### 文件路径解析
- **位置：** `apps/mobile/lib/services/connection_url_parser.dart`
- **问题：** URL 解析可能因边界情况（特殊字符、编码）失败

### 状态 Cubit 生命周期
- **位置：** `apps/mobile/lib/providers/`
- **问题：** 多个 Cubit 之间可能存在竞态条件
- **场景：** 快速切换页面时的状态初始化/销毁时序

### 进程管理
- **位置：** `packages/bridge/src/codex-process.ts`, `sdk-process.ts`
- **问题：** 子进程异常退出时的清理和恢复逻辑
- **影响：** 可能残留僵尸进程

## 依赖风险

### Shorebird Code Push
- **版本：** `^2.0.5`
- **风险：** 第三方 OTA 服务依赖，服务可用性取决于 Shorebird
- **影响：** 如果 Shorebird 服务中断，无法推送热更新

### Flutter Markdown
- **版本：** `^0.7.7+1`
- **风险：** Markdown 渲染包的维护状态和性能
- **影响：** 消息显示质量

### Marionette Flutter
- **版本：** `^0.4.0`
- **风险：** 相对新的包，API 可能不稳定
- **影响：** 桌面集成功能

### irondash_engine_context fork
- **位置：** `apps/mobile/pubspec.yaml` dependency_overrides
- **问题：** 使用第三方 fork 替代官方包（16KB page alignment 修复）
- **风险：** fork 可能不被上游维护，升级路径不明确

## 扩展性限制

### WebSocket 连接容量
- **位置：** `packages/bridge/src/websocket.ts`
- **问题：** 单个 Bridge 服务器实例的连接数限制
- **现状：** 设计为单用户使用，当前足够

### 消息历史存储
- **问题：** SQLite 本地存储容量限制
- **影响：** 长期使用后数据库可能膨胀

## 测试覆盖空白

### Flutter 端自动化测试不足
- **问题：** 主要依赖 Mock 预览和手动测试
- **缺少：** Widget 测试、集成测试的系统性覆盖

### Edge Case 覆盖
- **问题：** 网络中断恢复、进程异常退出等场景
- **缺少：** 异常路径的端到端测试

---

*关注点分析：2026-04-04*
