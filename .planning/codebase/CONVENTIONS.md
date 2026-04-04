# 编码约定

**分析日期：** 2026-04-04

## Dart / Flutter 约定

### 文件命名
- snake_case：`bridge_service.dart`, `session_list_screen.dart`
- 测试文件：`*_test.dart`，与源文件同目录
- 生成文件：`*.freezed.dart`, `*.g.dart`, `*.gr.dart`

### 类与类型命名
- PascalCase：`BridgeService`, `SessionListScreen`, `MachineManagerCubit`
- Freezed 联合类型：`ServerMessage`, `ClientMessage`（在 `models/messages.dart`）
- Cubit 后缀：`*Cubit`（`MachineManagerCubit`, `ServerDiscoveryCubit`）

### 变量与函数
- camelCase：`sessionId`, `onMessageReceived`, `buildContext`
- 私有成员以下划线开头：`_status`, `_controller`

### 导入顺序
1. Dart SDK (`dart:*`)
2. Flutter SDK (`package:flutter/*`)
3. 第三方包 (`package:web_socket_channel/*`)
4. 项目内包（相对路径）

### 代码生成
- **freezed** — 不可变模型 + 联合类型
- **json_serializable** — JSON 序列化
- **auto_route** — 路由页面生成
- 运行：`dart run build_runner build`

### 状态管理
- 使用 `flutter_bloc` 的 Cubit 模式（非 Bloc）
- Cubit 文件放在 `providers/` 目录
- 日志集成：`talker_bloc_logger`

### Widget 组织
- Feature-based 目录结构
- 共享 Widget 放在 `widgets/`
- 使用 `flutter_hooks` 减少 StatefulWidget

## TypeScript / Node.js 约定

### 文件命名
- kebab-case：`codex-process.ts`, `push-relay.ts`, `session.ts`
- 测试文件：与源文件同目录，`.test.ts` 后缀

### 函数与变量
- camelCase：`start()`, `sendInput()`, `handleStdoutChunk()`
- 私有以下划线开头：`_status`, `_threadId`, `_pendingPlanInput`
- 常量 UPPER_SNAKE_CASE：`JSON_RPC_TIMEOUT_MS`

### 类型
- 接口 PascalCase：`CodexStartOptions`, `SessionInfo`
- 类型别名 PascalCase：`ProcessStatus`, `Provider`

### TypeScript 配置
- 严格模式：`"strict": true`
- 目标：`"target": "ES2022"`
- 模块系统：`"module": "NodeNext"`
- ESM 模式：`"type": "module"`

### 导入顺序
1. Node.js 内置模块（`node:events`, `node:crypto`）
2. 第三方模块（`ws`, `bonjour-service`）
3. 项目内相对路径

```typescript
import { EventEmitter } from "node:events";
import { randomUUID } from "node:crypto";
import { spawn, type ChildProcessWithoutNullStreams } from "node:child_process";
import { CodexProcess } from "./codex-process.js";
import type { ServerMessage, ProcessStatus } from "./parser.js";
```

## 错误处理

### Dart
- 使用 try-catch 包装异步操作
- 抛出 Exception 对象
- 日志使用 `talker` 框架

### TypeScript
- try-catch 包装异步操作
- 抛出 Error 对象，不抛字符串
- 错误消息包含上下文

```typescript
try {
  await this.request("thread/start", threadParams);
} catch (err) {
  const message = err instanceof Error ? err.message : String(err);
  console.error("[codex-process] bootstrap error:", err);
  this.emitMessage({ type: "error", message: `Codex error: ${message}` });
  this.setStatus("idle");
}
```

## 日志记录

### Dart/Flutter
- 使用 `talker` / `talker_flutter` 框架
- BLoC 日志：`talker_bloc_logger`

### TypeScript/Bridge
- `console.log` 调试日志
- `console.error` 错误日志
- 方括号标记来源：`[codex-process]`, `[session]`

```typescript
console.log(`[codex-process] Starting app-server (cwd: ${projectPath})`);
console.error("[codex-process] app-server process error:", err);
```

## Linting

### Flutter
- `flutter_lints ^6.0.0`
- `analysis_options.yaml` 配置

### TypeScript
- Vitest 内置 lint
- 无额外 ESLint 配置（基于 `package.json` 未发现 eslint 依赖）

## 模块设计

### Flutter
- Feature 模块内聚：每个 feature 自包含 screen、widget、logic
- 服务层集中在 `services/` 目录
- 共享模型在 `models/`

### TypeScript
- 显式命名导出
- 桶文件 `index.ts` 作为入口
- 类继承 `EventEmitter` 并使用泛型定义事件类型

---

*编码约定分析：2026-04-04*
