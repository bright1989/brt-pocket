# Testing Patterns

**Analysis Date:** 2026-04-02

## Test Frameworks

### Flutter (Dart) Tests
- **Runner:** `flutter test` (Flutter test framework built on `test` package)
- **Config:** `apps/mobile/analysis_options.yaml` (uses `package:flutter_lints/flutter.yaml`)
- **Widget test extras:** `patrol_finders` for enhanced widget testing (`patrolWidgetTest`)
- **State testing:** `bloc_test` package (though direct cubit instantiation is more common)

### Bridge Server (TypeScript) Tests
- **Runner:** Vitest
- **Config:** `packages/bridge/vitest.config.ts`
- **Environment:** Node.js
- **Coverage provider:** v8 (`@vitest/coverage-v8`)

### Run Commands

**Flutter tests:**
```bash
cd apps/mobile && flutter test               # Run all tests
cd apps/mobile && flutter test --no-pub      # Run without pub get
cd apps/mobile && dart analyze lib/           # Static analysis
cd apps/mobile && dart format apps/mobile     # Format code
```

**Bridge tests:**
```bash
npm run test:bridge              # Run all bridge tests (vitest run)
npm run test:bridge:coverage      # Run with coverage
npm run test:bridge -- --watch   # Watch mode
npx tsc --noEmit -p packages/bridge/tsconfig.json  # Type check
```
## Test File Organization

### Flutter Test Location
Tests live in a separate top-level `test/` directory that mirrors the `lib/` structure:

```
apps/mobile/test/
  chat_session_cubit_test.dart       # Unit test for ChatSessionCubit
  chat_message_handler_test.dart     # Unit test for ChatMessageHandler
  connection_url_parser_test.dart    # Unit test for URL parser
  diff_parser_test.dart              # Unit test for diff parser
  messages_test.dart                 # Unit test for message models
  session_card_test.dart             # Widget test for SessionCard
  approval_bar_test.dart             # Widget test for ApprovalBar
  error_bubble_test.dart             # Widget test for ErrorBubble
  widget_test.dart                   # Basic smoke test
  chat_screen/                       # Feature-level widget tests
    helpers/chat_test_helpers.dart   # Shared test infrastructure
    approval_test.dart               # Approval flow tests
    ask_user_test.dart               # AskUserQuestion tests
    streaming_test.dart              # Streaming delta tests
    plan_mode_test.dart              # Plan mode tests
    input_test.dart                  # Input handling tests
    error_test.dart                  # Error display tests
  helpers/
    chat_test_dsl.dart               # Fluent test DSL (ChatTestScenario)
  hooks/
    use_list_auto_complete_test.dart # Hook tests
    use_scroll_tracking_test.dart    # Hook tests
    use_voice_input_test.dart        # Hook tests
  providers/
    bridge_cubits_test.dart          # Provider tests
  regressions/
    plan_clear_accept_test.dart      # Regression tests
    rewind_test.dart
    stop_button_test.dart
    user_message_display_test.dart
    session_restart_navigation_test.dart
  services/
    app_update_service_test.dart     # Service tests
    in_app_review_service_test.dart
```

### Bridge Test Location
Tests are co-located with source files using the `*.test.ts` naming convention:

```
packages/bridge/src/
  websocket.test.ts        # WebSocket server integration tests
  session.test.ts          # Session manager tests
  sdk-process.test.ts      # SDK process unit tests
  codex-process.test.ts    # Codex process tests
  parser.test.ts           # Parser unit tests
  git-operations.test.ts   # Git operations tests
  git-assist.test.ts       # Git assist tests
  image-store.test.ts      # Image store tests
  gallery-store.test.ts    # Gallery store tests
  recording-store.test.ts  # Recording store tests
  worktree.test.ts         # Worktree tests
  worktree-store.test.ts   # Worktree store tests
  debug-trace-store.test.ts # Debug trace store tests
  project-history.test.ts  # Project history tests
  push-relay.test.ts       # Push relay tests
  push-i18n.test.ts        # Push i18n tests
  proxy.test.ts            # Proxy tests
  doctor.test.ts           # Doctor tests
  version.test.ts          # Version tests
  setup-launchd.test.ts    # LaunchD setup tests
  setup-systemd.test.ts    # SystemD setup tests
  startup-info.test.ts     # Startup info tests
  sessions-index.test.ts   # Sessions index tests
```

### Naming Convention
- Flutter: `{target}_test.dart` (e.g., `chat_session_cubit_test.dart`)
- Bridge: `{module}.test.ts` (e.g., `websocket.test.ts`)
## Flutter Test Patterns

### Unit Tests (Cubit Tests)
Unit tests directly instantiate cubits with mock services. No BLoC test wrappers needed.

**Pattern from** `apps/mobile/test/chat_session_cubit_test.dart`:
```dart
void main() {
  late MockBridgeService mockBridge;
  late StreamingStateCubit streamingCubit;

  setUp(() {
    mockBridge = MockBridgeService();
    streamingCubit = StreamingStateCubit();
  });

  tearDown(() {
    streamingCubit.close();
    mockBridge.dispose();
  });

  ChatSessionCubit createCubit(String sessionId, {Provider? provider}) {
    return ChatSessionCubit(
      sessionId: sessionId,
      provider: provider,
      bridge: mockBridge,
      streamingCubit: streamingCubit,
    );
  }

  group('ChatSessionCubit', () {
    test('initial state is default ChatSessionState', () {
      final cubit = createCubit('test-session');
      addTearDown(cubit.close);
      expect(cubit.state.status, ProcessStatus.starting);
      expect(cubit.state.entries, isEmpty);
    });

    test('status message updates state.status', () async {
      final cubit = createCubit('s1');
      addTearDown(cubit.close);
      await Future.microtask(() {});
      mockBridge.emitMessage(
        const StatusMessage(status: ProcessStatus.running),
        sessionId: 's1',
      );
      await Future.microtask(() {});
      expect(cubit.state.status, ProcessStatus.running);
    });
  });
}
```

**Key patterns:**
- Define mock service as a class extending the real service
- Use `setUp`/`tearDown` for lifecycle management
- Use `addTearDown(cubit.close)` inside tests when cubits are created mid-test
- Use `await Future.microtask(() {}){BT} to flush microtask queue after emitting messages
- `group()` for logical test grouping
- Descriptive test names: `'condition, expected result'`

### Widget Tests
Widget tests use `patrolWidgetTest` (from `patrol_finders`) for enhanced widget testing:

**Pattern from** `apps/mobile/test/chat_screen/approval_test.dart`:
```dart
void main() {
  late MockBridgeService bridge;

  setUp(() {
    bridge = MockBridgeService();
  });

  tearDown(() {
    bridge.dispose();
  });

  patrolWidgetTest(
    'A1: Approval bar displays when permission request + waitingApproval',
    ($) async {
      await setupApproval($);
      expect($(ApprovalBar), findsOneWidget);
      expect($(#approve_button), findsOneWidget);
    },
  );
}
```

**Key patterns:**
- `patrolWidgetTest` instead of `testWidgets` for all widget tests
- `$` parameter provides `PatrolTester` for enhanced finders (`$(Type)`, `$(#key)`)
- Widget wrapping helper: `buildTestClaudeSessionScreen(bridge: bridge)` provides all required providers
### Fluent Test DSL
A custom fluent DSL enables declarative test scenarios:

**From** `apps/mobile/test/helpers/chat_test_dsl.dart`:
```dart
await ChatTestScenario($, bridge)
  .emit([
    msg.assistant('a1', 'Running command'),
    msg.bashPermission('tool-1'),
    msg.status(ProcessStatus.waitingApproval),
  ])
  .tap(#approve_button)
  .expectSent('approve', (m) => m['id'] == 'tool-1')
  .emit([
    msg.toolResult('tool-1', 'output'),
    msg.status(ProcessStatus.idle),
  ])
  .expectNoWidget(ApprovalBar)
  .run();
```

**Available DSL methods:**
- `.emit(messages)` - Emit server messages and pump
- `.tap(#key)` or `.tapText('text')` - Tap widgets
- `.enterText(#key, 'text')` - Enter text into fields
- `.pump()` - Pump frames
- `.expectSent(type, predicate?)` - Assert client message sent
- `.expectNotSent(type)` - Assert message not sent
- `.expectWidget(Type)` / `.expectNoWidget(Type)` - Assert widget presence
- `.expectText('text')` / `.expectNoText('text')` - Assert text visibility
- `.custom(action)` - Run arbitrary async action
- `.run()` - Execute all steps sequentially

**Message factories** (via `msg` global):
- `msg.assistant(id, text)`, `msg.bashPermission(toolUseId)`
- `msg.toolResult(toolUseId, content)`, `msg.status(status)`
- `msg.enterPlan(id, toolUseId)`, `msg.exitPlan(id, toolUseId, text)`
- `msg.askQuestion(toolUseId, questions)`, `msg.error(message)`
- `msg.streamDelta(text)`, `msg.result(subtype, cost, duration)`
### Mock Bridge Service
Two versions of `MockBridgeService` exist:

1. **Unit test version** (`apps/mobile/test/chat_session_cubit_test.dart`):
   - Extends `BridgeService` directly
   - Minimal: only overrides `messages`, `messagesForSession`, `send`, `dispose`
   - Tracks sent messages in `sentMessages` list
   - Exposes `emitMessage(msg, sessionId)` for simulating server messages

2. **Widget test version** (`apps/mobile/test/chat_screen/helpers/chat_test_helpers.dart`):
   - Also extends `BridgeService`
   - Full overrides: `connectionStatus`, `fileList`, `sessionList`, `httpBaseUrl`, `isConnected`
   - Provides proper stream controllers for widget tree hydration
   - Same `emitMessage` and `sentMessages` API

3. **Production mock** (`apps/mobile/lib/services/mock_bridge_service.dart`):
   - Full mock for UI preview and demo mode
   - Uses `MockScenario` data from `lib/mock/mock_scenarios.dart`
   - Supports git diff preview, stage/unstage tracking

4. **Replay service** (`apps/mobile/lib/services/replay_bridge_service.dart`):
   - Replays recorded session JSONL files
   - Supports `ReplayMode.realtime` and `ReplayMode.instant`
   - User actions serve as breakpoints between message chunks

### Widget Test Infrastructure

**From** `apps/mobile/test/chat_screen/helpers/chat_test_helpers.dart`:

- `buildTestClaudeSessionScreen(bridge:)` - Creates a full widget tree with all required providers
- `buildTestChatScreen(bridge:)` - Backward-compatible alias
- `pumpN(tester, count)` - Pump multiple frames (default 5x50ms) to handle animations
- `emitAndPump(tester, bridge, messages)` - Emit messages with short pumps between each
- `findSentMessage(bridge, type)` - Find a sent client message by type
- `findAllSentMessages(bridge, type)` - Find all sent messages of a type
- `decodeClientMessage(msg)` - Decode `ClientMessage` to JSON map
- `makeBashPermission(toolUseId)` - Create a permission request for Bash tool
- `makeAssistantMessage(id, text)` - Create an assistant server message
- `setupPlanApproval($, bridge)` - Setup helper for plan approval tests
- `setupMultiApproval($, bridge)` - Setup helper for multi-approval tests
- `approveAndEmitResult($, bridge, toolUseId, content)` - Approve and simulate result

**`SharedPreferences` mocking:**
```dart
SharedPreferences.setMockInitialValues({});
final prefs = await SharedPreferences.getInstance();
```
## Bridge Server Test Patterns

### Vitest Structure

Tests use Vitest with `describe`/`it`/`expect` structure.

Key patterns:
- `vi.hoisted()` for declaring mock references before module mocking
- `vi.mock()` for module-level mocking
- `beforeEach`/`afterEach` for setup/teardown
- Mock classes extend `EventEmitter` for process mocking
- `vi.fn()` for function mocking
- `vi.importActual()` for partial module mocking

### Mocking Patterns (TypeScript)

**`vi.hoisted()`** is used consistently to declare mock references before module mocking:
- Hoisted mocks ensure references are available when `vi.mock()` runs
- Mock functions: `vi.fn()`
- Mock classes: defined inline within `vi.mock()` callback
- Partial mocking with `vi.importActual()`: preserve some exports while mocking others

**Process mocking pattern** (from `codex-process.test.ts`):
- Create `FakeChildProcess` extending `EventEmitter`
- Mock `node:child_process` `spawn` to return fake processes
- Track created instances in arrays for test assertions

**File system mocking** (from `session.test.ts`):
- Mock `node:fs` functions (`existsSync`, `readFileSync`, `readdirSync`)
- Use `Set` and `Map` for in-memory fake directories and files

**Class mocking** (from `session.test.ts`):
- Mock process classes (`SdkProcess`, `CodexProcess`) as classes extending `EventEmitter`
- Push instances to arrays in constructor for later assertion
- Expose public mock methods: `vi.fn()`
## Coverage

### Flutter
- No enforced coverage target
- No coverage configuration in `analysis_options.yaml`
- Coverage can be generated with `flutter test --coverage` but is not part of CI

### Bridge Server
- **Coverage tool:** v8 via `@vitest/coverage-v8`
- **Run:** `npm run test:bridge:coverage`
- **Config in** `vitest.config.ts`:
  - Includes: `src/**/*.ts`
  - Excludes: `src/**/*.test.ts`, `src/index.ts`
- No enforced coverage threshold

## CI Pipeline

**Workflow:** `.github/workflows/test.yml`

- **Triggers:** Pull requests and pushes to `main`
- **Runner:** `ubuntu-latest`
- **Flutter version:** Read from `.mise.toml` (currently 3.41.5)
- **Steps:**
  1. Checkout code
  2. Read Flutter version from `.mise.toml`
  3. Setup Flutter with caching
  4. `flutter pub get`
  5. `dart analyze .`
  6. `flutter test`

**Note:** Bridge server tests are NOT run in CI. Only Flutter tests.

## Development Hooks

### Claude Code Hooks
Defined in `.claude/hooks/`:

- **post-edit-analyze.sh** - Runs `dart analyze` on edited Dart files (skips test files)
- **pre-stop-check.sh** - Runs `dart analyze` and `flutter test` before task completion
  - Only runs tests if `lib/*.dart` files have changed
  - Exits with code 2 on failure (blocks task completion)

### Git Hooks
- **pre-commit** - Runs `scripts/check-secrets.sh` for secret detection
- Installed via `scripts/setup-hooks.sh`

## Test Data and Fixtures

### Flutter Mock Scenarios
- `apps/mobile/lib/mock/mock_scenarios.dart` - 25+ predefined UI preview scenarios
- `apps/mobile/lib/mock/mock_sessions.dart` - Mock session data
- `apps/mobile/lib/mock/mock_image_data.dart` - Mock image data
- `apps/mobile/lib/mock/store_screenshot_data.dart` - Screenshot test data
- Scenarios cover: approval flow, plan mode, streaming, error states, Codex-specific flows

### TypeScript Test Helpers
- `tick()` utility for advancing microtask queue in tests
- `FakeChildProcess` / `FakeWritable` / `FakeReadable` for process mocking
- `fakeDirs` / `fakeFiles` for filesystem mocking
- `registerHistoryJsonl()` helper for setting up JSONL history files
## Common Patterns

### Async Testing (Flutter)
- Use `await Future.microtask(() {}){` to flush microtask queue after stream emissions
- Use `pumpN(tester)` (5x50ms pumps) to advance animations
- Use `emitAndPump()` for sequential message emission with pumps
- Use `addTearDown()` for cleanup when resources are created mid-test

### Error Testing (Flutter)
- Emit `ErrorMessage` and assert state changes
- Test error code inference via `inferStructuredErrorCode()`
- Test state rollback on error (e.g., permission mode rollback)

### Stream Testing (Flutter)
- Mock services expose `StreamController.broadcast()` for stream properties
- Tests add to controllers via `emitMessage()` and assert state changes
- `StreamCubit<T>` tested by providing a broadcast stream

### Connection Testing (Bridge)
- WebSocket tests use real HTTP server + WebSocket connections
- `createServer()` + `ws` connection for integration tests
- Clean up with `server.close()` and `ws.terminate()` in `afterEach`

### What to Mock
- `BridgeService` (or extend it) for all Flutter tests involving WebSocket communication
- `SharedPreferences` via `setMockInitialValues()`
- Node.js built-in modules (`node:fs`, `node:child_process`) for Bridge tests
- Internal modules via `vi.mock()` for Bridge tests

### What NOT to Mock
- Freezed state classes (they are pure data)
- Model `fromJson()` methods (test real parsing)
- Message handler logic (test real message processing)
---

*Testing analysis: 2026-04-02*
