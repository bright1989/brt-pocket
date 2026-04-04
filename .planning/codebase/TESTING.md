# 测试模式

**分析日期：** 2026-04-04

## 测试框架

### Bridge 服务器（TypeScript）
- **Runner：** Vitest 4.0.18
- **Config：** `packages/bridge/vitest.config.ts`
- **覆盖率：** `@vitest/coverage-v8 ^4.0.18`
- **命令：**
  - `npm test` — 运行所有测试
  - `npm run test:watch` — 监听模式
  - `npm run test:coverage` — 覆盖率报告

### Flutter 移动端
- **Runner：** Flutter Test
- **UI 测试：** `patrol_finders ^3.1.0`
- **BLoC 测试：** `bloc_test ^10.0.0`
- **Driver 测试：** `flutter_driver`（集成测试）

## 测试文件组织

### Bridge 端
- 与源文件同目录：`packages/bridge/src/*.test.ts`
- 命名模式：`codex-process.ts` → `codex-process.test.ts`

**已有测试文件：**
| 源文件 | 测试文件 |
|--------|----------|
| `codex-process.ts` | `codex-process.test.ts` |
| `session.ts` | `session.test.ts` |
| `parser.ts` | `parser.test.ts` |
| `websocket.ts` | `websocket.test.ts` |
| `gallery-store.ts` | `gallery-store.test.ts` |
| `image-store.ts` | `image-store.test.ts` |
| `git-assist.ts` | `git-assist.test.ts` |
| `git-operations.ts` | `git-operations.test.ts` |
| `worktree.ts` | `worktree.test.ts` |
| `worktree-store.ts` | `worktree-store.test.ts` |
| `archive-store.ts` | 无独立测试 |
| `recording-store.ts` | `recording-store.test.ts` |
| `debug-trace-store.ts` | `debug-trace-store.test.ts` |
| `project-history.ts` | `project-history.test.ts` |
| `proxy.ts` | `proxy.test.ts` |
| `push-relay.ts` | `push-relay.test.ts` |
| `push-i18n.ts` | `push-i18n.test.ts` |
| `setup-launchd.ts` | `setup-launchd.test.ts` |
| `setup-systemd.ts` | `setup-systemd.test.ts` |
| `startup-info.ts` | `startup-info.test.ts` |
| `version.ts` | `version.test.ts` |
| `doctor.ts` | `doctor.test.ts` |
| `sdk-process.ts` | `sdk-process.test.ts` |

### Flutter 端
- 测试文件位于 `apps/mobile/test/`
- Widget 测试、集成测试、驱动测试

## 测试结构

### Bridge 端模式

```typescript
describe("CodexProcess (app-server)", () => {
  beforeEach(() => {
    // 测试设置
  });

  afterEach(() => {
    // 测试清理
  });

  it("starts codex app-server and sends initialize + thread/start", async () => {
    // 测试实现
  });
});
```

## Mocking

### Bridge 端
- 使用 Vitest 内置 mocking（`vi.fn()`, `vi.mock()`）
- `vi.hoisted()` 提升模拟变量

```typescript
const { spawnMock, fakeChildren } = vi.hoisted(() => ({
  spawnMock: vi.fn(),
  fakeChildren: [] as FakeChildProcess[],
}));

vi.mock("node:child_process", () => ({
  spawn: spawnMock,
}));
```

**模拟对象：**
- `FakeChildProcess` — 模拟子进程（继承 EventEmitter）
- `FakeReadable` / `FakeWritable` — 模拟流
- Node.js 内置模块（child_process, fs）

### Flutter 端
- `MockBridgeService` — Mock Bridge 连接
- `mock/` 目录包含 mock 数据
- `bloc_test` 用于 Cubit 测试

## 覆盖率配置

```typescript
coverage: {
  provider: "v8",
  include: ["src/**/*.ts"],
  exclude: ["src/**/*.test.ts", "src/index.ts"],
},
```

## 测试类型

### 单元测试
- **范围：** 单个类或函数
- **方法：** 隔离测试，模拟依赖
- **示例：** CodexProcess 启停逻辑、Session 消息路由

### 集成测试
- **范围：** 多组件交互
- **方法：** 部分集成，关键组件使用真实实现
- **示例：** SessionManager 管理 CodexProcess

### E2E 测试
- **Flutter Driver** — 桌面/移动端集成测试
- **Marionette MCP** — 通过 dart-mcp 进行 UI 自动化验证

## 异步测试工具

```typescript
// Bridge 端常用 helper
async function tick(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
}

// JSON-RPC 请求捕获
function nextOutgoingRequest(child: FakeChildProcess): Record<string, unknown> {
  return consumeOutgoing(
    child,
    (value) => typeof value.method === "string" && value.id !== undefined,
  );
}
```

## 测试覆盖率评估

**Bridge 端覆盖率良好：** 大部分核心模块有对应测试文件（22 个测试文件覆盖主要功能模块）。

**Flutter 端覆盖率有限：** 主要依赖 Mock 预览和手动 UI 验证，自动化测试覆盖较少。

---

*测试分析：2026-04-04*
