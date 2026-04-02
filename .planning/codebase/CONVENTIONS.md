# Coding Conventions

**Analysis Date:** 2026-04-02
## Naming Patterns

### Dart Files
- `snake_case.dart` for all Dart files
- Feature directories: `kebab-case/` (e.g., `chat_session/`, `session_list/`, `file_peek/`)
- State files: `{feature}_cubit.dart`, `{feature}_state.dart`, `{feature}_state.freezed.dart`
- Screen files: `{feature}_screen.dart`
- Widget files: `{widget_name}.dart` (e.g., `approval_bar.dart`, `message_bubble.dart`)
- Service files: `{purpose}_service.dart` (e.g., `bridge_service.dart`, `draft_service.dart`)
- Hook files: `use_{purpose}.dart` (e.g., `use_scroll_tracking.dart`, `use_app_resume_callback.dart`)
- Test files: `{target}_test.dart` co-located with source or in `test/` mirror

### Dart Classes
- PascalCase for all class names
- Cubits: `{Feature}Cubit` (e.g., `ChatSessionCubit`, `SettingsCubit`, `MachineManagerCubit`)
- States: `{Feature}State` (e.g., `ChatSessionState`, `SettingsState`)
- Widgets: `{DescriptiveName}` (e.g., `AssistantBubble`, `ApprovalBar`, `ChatInputBar`)
- Services: `{Purpose}Service` (e.g., `BridgeService`, `DraftService`, `NotificationService`)
- Screens: `{Feature}Screen` (e.g., `ClaudeSessionScreen`, `GitScreen`, `GalleryScreen`)
- Model classes: descriptive nouns (e.g., `RecordedEvent`, `ChatStateUpdate`, `MockStep`)
- Hook return types: `{Name}Result` (e.g., `ScrollTrackingResult`)

### Dart Functions/Methods
- `camelCase` for functions and methods
- Private members prefixed with `_` (e.g., `_messageController`, `_bridgeSub`, `_handleUri`)
- Factory constructors: `.fromJson()`, `.fromJsonLine()`
- Build methods: `_build{Thing}` (e.g., `_buildTheme`)
- Event handlers: `on{Event}` or `_on{Event}` (e.g., `_onScroll`, `_onDiffImageResult`)
- Getter overrides: `get` keyword (e.g., `bool get isCodex => ...`)
- Lifecycle callbacks: `initState`, `dispose`, `build`

### Dart Variables
- `camelCase` for local variables and parameters
- Constants: `camelCase` (not SCREAMING_CASE) - e.g., `const testSessionId = ...`
- Static constants: `camelCase` in classes (e.g., `static const keyShorebirdTrack = ...`)
- Enum values: `camelCase` (e.g., `ProcessStatus.waitingApproval`)
- Feature flags: compile-time `bool.fromEnvironment` via `FeatureFlags` class

### TypeScript Files
- `kebab-case.ts` for all TypeScript source files
- Test files: `{module}.test.ts` co-located with source (e.g., `websocket.test.ts`)
- Config files: `{tool}.config.ts` (e.g., `vitest.config.ts`)

### TypeScript Classes/Types
- PascalCase for classes and interfaces
- Union types: PascalCase for type aliases (e.g., `AssistantContent`, `ClientMessage`, `ServerMessage`)
- Interface prefix: none (bare `interface`, not `I` prefix)
- Literal types: `type PermissionMode = "default" | "acceptEdits" | ...`
- Discriminated unions: `type: "text" | "tool_use" | "thinking"` field for discrimination

### TypeScript Functions/Variables
- `camelCase` for functions and variables
- Private class fields: `_fieldName` prefix (e.g., `_permissionMode`, `_sessions`)
- Constants: SCREAMING_CASE (e.g., `ACCEPT_EDITS_AUTO_APPROVE`)
- Environment variable parsing: `const PORT = parseInt(process.env.BRIDGE_PORT ?? "8765", 10)`
- Boolean env vars: `const RECORDING_ENABLED = \!\!process.env.BRIDGE_RECORDING`
## Code Style

### Dart Formatting
- **Tool:** `dart format` (built-in Dart formatter)
- **Line length:** Default (80 characters)
- **Trailing commas:** Used consistently for multi-line arguments and parameters
- **Run:** `dart format apps/mobile`
- No Prettier or custom formatting config

### Dart Linting
- **Tool:** `dart analyze` (built-in Dart analyzer)
- **Config:** `apps/mobile/analysis_options.yaml`
- **Base ruleset:** `package:flutter_lints/flutter.yaml`
- **Additional rules:** None custom - uses default flutter_lints
- **Run:** `dart analyze apps/mobile`
- **Suppress:** `// ignore: name_of_lint` or `// ignore_for_file: name_of_lint`

### TypeScript Formatting
- **Tool:** TypeScript built-in (`tsc`) - no separate formatter config
- **Strict mode:** Enabled (`"strict": true` in tsconfig.json)

### TypeScript Linting
- No ESLint configuration. Type checking via `tsc --noEmit`.
- **Run:** `npx tsc --noEmit -p packages/bridge/tsconfig.json`
## Import Organization

### Dart Import Order
Dart imports follow this consistent ordering pattern across all files:

1. **`dart:` imports** - standard library (e.g., `dart:async`, `dart:convert`)
2. **Blank line**
3. **`package:` imports** - third-party packages sorted alphabetically
   - Flutter SDK: `package:flutter/...`, `package:auto_route/...`, `package:flutter_bloc/...`
   - Third-party: `package:shared_preferences/...`, `package:web_socket_channel/...`
4. **Blank line**
5. **Relative imports** - project imports using `../../` paths
   - `../../core/logger.dart`
   - `../../models/messages.dart`
   - `../../services/bridge_service.dart`
   - `../../features/...` / `../../widgets/...` / `../../hooks/...`

**Selective imports** use `show`/`hide` clauses:
```dart
import '../../widgets/new_session_sheet.dart'
    show permissionModeFromRaw, sandboxModeFromRaw;
```

### TypeScript Import Order
1. **`node:` imports** - built-in Node modules (e.g., `import { readFileSync } from "node:fs"`)
2. **Blank line**
3. **Relative imports** - `./module.js` (always with `.js` extension, NodeNext resolution)
4. **Type imports** use `import type` syntax:
```typescript
import type { ServerMessage, ProcessStatus } from "./parser.js";
```

**Module resolution:** `NodeNext` with `.js` file extensions on all relative imports.
## Architecture Patterns

### State Management (Dart/Flutter)
- **Primary:** `flutter_bloc` with Cubit pattern
- **State classes:** Immutable via `freezed` code generation (`@freezed` annotation)
- **Generated files:** `*.freezed.dart` committed to source control
- **Sealed unions:** For exhaustive pattern matching (e.g., `ApprovalState`):
```dart
@freezed
abstract class ApprovalState with _$ApprovalState {
  const factory ApprovalState.none() = ApprovalNone;
  const factory ApprovalState.permission({...}) = ApprovalPermission;
  const factory ApprovalState.askUser({...}) = ApprovalAskUser;
}
```
- **Generic Cubit:** `StreamCubit<T>` wraps any `Stream<T>` as a Cubit (replaces Riverpod StreamProvider)
- **Stream typedefs:** Simple stream cubits use typedefs (e.g., `typedef ConnectionCubit = StreamCubit<BridgeConnectionState>`)
- **Named classes:** When multiple `StreamCubit<List<String>>` exist, use named subclasses for BlocProvider type resolution

### Widget Patterns
- **Screens:** `StatefulWidget` or `StatelessWidget` with `@RoutePage()` annotation (auto_route)
- **Widgets:** Mix of `StatefulWidget` and `StatelessWidget`
- **Hooks:** `flutter_hooks` for stateful logic in widgets (e.g., `useScrollTracking`, `useAppResumeCallback`)
- **Hook builder:** `HookBuilder` widget to embed hooks in widget trees
- **Const constructors:** Used where possible (e.g., `const ApprovalBar({super.key, ...})`)

### Service Pattern (Dart)
- **Interface abstraction:** `BridgeServiceBase` abstract class defines the contract
- **Real implementation:** `BridgeService implements BridgeServiceBase`
- **Mock implementations:** `MockBridgeService extends BridgeService` (in both `lib/services/` and `test/`)
- **Replay implementation:** `ReplayBridgeService extends BridgeService` for recorded session replay
- **Service instantiation:** Services are created in `main.dart` and provided via `RepositoryProvider`

### Provider Hierarchy (Dart)
- `MultiRepositoryProvider` wraps `MultiBlocProvider` in `main.dart`
- Services registered as `RepositoryProvider<T>.value(value: ...)`
- Cubits registered as `BlocProvider(create: (_) => ...)`
- Screen-scoped providers: `MultiBlocProvider` wraps screen widgets for feature-specific cubits

### TypeScript Module Pattern
- **ESM only:** `"type": "module"` in package.json
- **Class-based modules:** Main modules export classes (e.g., `export class BridgeWebSocketServer`)
- **Type-only exports:** `export type { ... }` in `parser.ts`
- **Barrel-style:** `index.ts` imports and re-exports from all modules
- **No barrel files per module** - direct imports preferred

### WebSocket Protocol
- **Typed messages:** Discriminated unions with `type` field (defined in `parser.ts`)
- **Bidirectional:** `ClientMessage` (client to server) and `ServerMessage` (server to client) types
- **TypeScript side:** Full type safety with discriminated unions
- **Dart side:** Sealed class `ServerMessage` with `fromJson` factory, `ClientMessage` with `toJson`
## Error Handling

### Dart Error Handling
- **Exceptions:** Try/catch with `logger.error(...)` for non-critical failures
- **Graceful degradation:** `_unsupportedActions` map controls behavior for unknown message types
- **State rollback:** Cubits implement rollback on error (e.g., `PermissionMode` rolls back on `set_permission_mode_rejected`)
- **Null safety:** Full null safety enabled (`sdk: ^3.11.0`)
- **Error types:** `ErrorMessage` model with `message` and `errorCode` fields
- **Structured error inference:** `inferStructuredErrorCode()` parses error text into structured codes

### TypeScript Error Handling
- **Try/catch:** Used for async operations (store init, Firebase auth)
- **Console logging:** `console.log`, `console.warn`, `console.error` with `[bridge]` prefix
- **Error responses:** HTTP 500 with `{ error: String(err) }` JSON body
- **Process events:** `process.on("SIGINT", shutdown)` for graceful shutdown

## Logging

### Dart Logging
- **Framework:** `talker` package (global `Talker` instance)
- **Instance:** `final logger = Talker(...)` in `lib/core/logger.dart`
- **Colors disabled:** `TalkerLoggerSettings(enableColors: false)`
- **Bloc observer:** `TalkerBlocObserver(talker: logger)` for BLoC event logging
- **Pattern:**
```dart
logger.info('[shorebird] Patch downloaded (track: $trackName)');
logger.error('[main] NotificationService init failed', e);
logger.warning('[fcm] handlers skipped: Firebase not initialized ($e)');
```
- **Tag format:** `[context] message` - lowercase context in square brackets

### TypeScript Logging
- **Framework:** `console.*` (no external logging library)
- **Pattern:**
```typescript
console.log("[bridge] Starting ccpocket bridge server...");
console.warn("[bridge] Push relay disabled: Firebase auth failed:", err);
console.error("[bridge] Failed to initialize gallery store:", err);
```
- **Tag format:** `[bridge]` prefix on all log messages

## Comments

### When to Comment
- **File-level doc comments:** On all Dart files (e.g., `/// ccpocket - Claude Code Mobile Client`)
- **Class-level doc comments:** On public classes, especially services, cubits, and complex widgets
- **Complex logic:** Explanatory comments for non-obvious algorithms (e.g., scroll tracking tolerance)
- **Workarounds:** Comment explaining why (e.g., dependency override comments in pubspec.yaml)
- **Compatibility:** Notes about backward compatibility (e.g., `// Legacy key for migration`)

### Doc Comment Style (Dart)
- Triple-slash `///` for doc comments
- Constructor and method docs on public API
- Parameter docs not consistently used - inline comments preferred
- Example:
```dart
/// Manages the state of a single chat session.
///
/// Subscribes to [BridgeService.messagesForSession] and delegates message
/// processing to [ChatMessageHandler].
class ChatSessionCubit extends Cubit<ChatSessionState> { ... }
```

### TypeScript Comments
- JSDoc-style `/** */` sparingly used
- Inline `//` comments for implementation notes
- No TSDoc standard enforced
## Function Design

### Dart
- **Size:** No strict limit but cubits tend to be large (500+ lines). Widget files moderate.
- **Parameters:** Named parameters with `{required}` for mandatory, optional with defaults
- **Return values:** Explicit `Future<void>` for async, specific types for data methods
- **Async:** `async`/`await` with `unawaited()` for fire-and-forget (from `dart:async`)
- **Factory pattern:** `factory.fromJson()` for deserialization
- **Single responsibility:** Handler classes (e.g., `ChatMessageHandler`) separate message processing from state management

### TypeScript
- **Size:** Functions kept focused. Large files (websocket.ts ~3500 lines) but methods are cohesive.
- **Parameters:** Options objects for complex constructors (e.g., `BridgeWebSocketServer({server, apiKey, ...})`)
- **Return types:** Explicit return types on most functions
- **Async:** `async`/`await` with `.then()`/`.catch()` for fire-and-forget initialization

## Git Commit Conventions

**Format:** Conventional Commits with optional scope

```
type(scope): description
```

**Types observed:**
- `feat` - new features (e.g., `feat(bridge): allow disabling mDNS advertisement`)
- `fix` - bug fixes (e.g., `fix(mobile): show "Changes" instead of project name`)
- `chore` - maintenance (e.g., `chore: bump version to 1.53.0+89`)
- `docs` - documentation (e.g., `docs: update README approval policy terminology`)
- `merge` - merge commits (e.g., `merge: feat/git-operations into main`)
- `fix(ci)`, `fix(codex)`, `fix(apple)`, `fix(test)` - scoped fixes
- `chore(l10n)`, `chore(store)` - scoped maintenance

**Scope:** Optional, in parentheses. Common scopes: `bridge`, `mobile`, `app`, `ci`, `l10n`, `test`, `codex`, `apple`, `store`, `readme`.

**Language:** English for commit messages.

**Pre-commit hook:** Runs `scripts/check-secrets.sh` for secret detection.

## Feature-First Architecture (Dart)

Features are organized as self-contained directories under `lib/features/`:

```
features/
  chat_session/          # Shared chat logic (state + widgets)
    state/               # Cubit + Freezed state
    widgets/             # Shared chat UI components
  claude_session/        # Claude-specific screen + widgets
  codex_session/         # Codex-specific screen + state
  session_list/          # Session list (home screen)
  settings/              # Settings screens + state
  git/                   # Git diff viewer
    state/               # GitViewCubit, CommitCubit
    widgets/
  gallery/               # Image gallery
  debug/                 # Debug screen
  file_peek/             # File peek sheet
  message_images/        # Image viewer
  prompt_history/        # Prompt history
  setup_guide/           # First-time setup
```

**Convention:** Shared logic lives in `chat_session/`. Provider-specific UI lives in `claude_session/` or `codex_session/`. Each feature that has state management includes a `state/` subdirectory.
## Message/Event Naming

### WebSocket Messages (TypeScript to Dart)
- `snake_case` for message type field values (e.g., `permission_request`, `stream_delta`, `waiting_approval`)
- `camelCase` for Dart class names (e.g., `PermissionRequestMessage`, `StreamDeltaMessage`)
- `camelCase` for Dart enum values (e.g., `ProcessStatus.waitingApproval`)
- Conversion: `from_string` maps `waiting_approval` to `ProcessStatus.waitingApproval`

### ChatEntry Types
- Union type `ChatEntry` with variants: `UserChatEntry`, `AssistantChatEntry`, `SystemChatEntry`, `ToolResultChatEntry`, `StatusChatEntry`, etc.
- `camelCase` for all variant names

### Side Effects
- Enum `ChatSideEffect` with `camelCase` values (e.g., `heavyHaptic`, `scrollToBottom`, `notifyApprovalRequired`)

## Platform Abstraction

- **Conditional imports:** `platform_helper.dart` with `platform_helper_io.dart` and `platform_helper_stub.dart`
- **Web detection:** `kIsWeb` from `package:flutter/foundation`
- **Platform checks:** `isMobilePlatform` helper, `Platform.isIOS`, `Platform.isAndroid`

## Localization

- **Framework:** Flutter built-in `flutter_localizations`
- **ARB files:** `lib/l10n/app_en.arb`, `app_ja.arb`, `app_zh.arb`
- **Generated files:** `app_localizations_en.dart`, `app_localizations_ja.dart`, `app_localizations_zh.dart`
- **Access:** `AppLocalizations.of(context)` for localized strings
- **Config:** `l10n.yaml` in app root
- **Languages:** English (primary), Japanese, Chinese (Simplified)

## Routing

- **Package:** `auto_route` (code-generated routing)
- **Config:** `AppRouter` class with `@AutoRouterConfig()` annotation
- **Generated file:** `app_router.gr.dart` (committed)
- **Route pages:** `@RoutePage()` annotation on screen widgets
- **Navigation:** `_appRouter.navigate(ClaudeSessionRoute(sessionId: id))`
- **Path format:** `/session/:sessionId`, `/codex-session/:sessionId`
- **Route observer:** `SessionRouteObserver` for tracking session screen lifecycle

## Constants and Configuration

- **App constants:** `lib/constants/app_constants.dart`
- **Feature flags:** `lib/constants/feature_flags.dart` - compile-time via `bool.fromEnvironment`
- **Spacing:** `lib/theme/app_spacing.dart` - static const doubles
- **Theme:** `lib/theme/app_theme.dart` - light/dark `ThemeData`
- **Markdown:** `lib/theme/markdown_style.dart`

---

*Convention analysis: 2026-04-02*
