# Architecture

**Analysis Date:** 2026-04-02

## Pattern Overview

**Overall:** Client-Server with WebSocket Bridge

ccpocket is a mobile client for Claude Code and Codex CLI agents. The architecture follows a three-tier pattern:

1. **Flutter Mobile App** (iOS/Android/Web) -- the UI and interaction layer
2. **Bridge Server** (Node.js/TypeScript) -- the middleware that manages CLI processes
3. **CLI Agents** (Claude Code SDK, Codex SDK) -- the actual AI coding agents

The Bridge Server acts as a WebSocket relay between the mobile app and locally running CLI processes. It is designed to run on the same machine as the development project.

**Key Characteristics:**
- Real-time bidirectional communication over WebSocket
- Multi-session support with independent process management
- Streaming text deltas for real-time display of AI responses
- Support for two providers: Claude Code and Codex
- Push notifications via Firebase Cloud Messaging (FCM)
- mDNS-based automatic server discovery on local networks
- Graceful degradation for version mismatches between app and bridge

## Layers

### Mobile App Layer (Flutter/Dart)

- **Purpose:** User-facing mobile application with chat UI, session management, settings
- **Location:** `apps/mobile/lib/`
- **Contains:** Screens, widgets, state management (Cubit/Bloc), services, models, routing
- **Depends on:** Bridge Server (via WebSocket), Firebase (for push notifications)
- **Used by:** End users on iOS, Android, and Web platforms

### Bridge Server Layer (Node.js/TypeScript)

- **Purpose:** WebSocket server that proxies between mobile clients and CLI agents
- **Location:** `packages/bridge/src/`
- **Contains:** WebSocket server, session manager, process wrappers, message parser, stores
- **Depends on:** Claude Agent SDK (`@anthropic-ai/claude-agent-sdk`), Codex CLI, Node.js, Firebase Auth (for push relay)
- **Used by:** Mobile App (connects via WebSocket)

### Firebase Cloud Functions (Push Relay)

- **Purpose:** Relay push notifications from Bridge Server to mobile devices via FCM
- **Location:** `functions/src/`
- **Contains:** HTTP-triggered Cloud Function for token registration and notification dispatch
- **Depends on:** Firebase Admin SDK, Firestore (for rate limiting and token storage)
- **Used by:** Bridge Server (sends notify requests), Mobile App (receives FCM notifications)

## Data Flow

### Session Creation Flow

1. User taps "New Session" in `SessionListScreen` (`apps/mobile/lib/features/session_list/session_list_screen.dart`)
2. `NewSessionSheet` (`apps/mobile/lib/widgets/new_session_sheet.dart`) collects project path, provider, modes
3. `BridgeService.send()` (`apps/mobile/lib/services/bridge_service.dart`) sends `{ type: "start", projectPath, provider, ... }` via WebSocket
4. `BridgeWebSocketServer` (`packages/bridge/src/websocket.ts`) validates path against `BRIDGE_ALLOWED_DIRS`
5. `SessionManager.create()` (`packages/bridge/src/session.ts`) generates a session ID, creates an `SdkProcess` or `CodexProcess`
6. Process is started via `SdkProcess.start()` or `CodexProcess.start()` (`packages/bridge/src/sdk-process.ts`, `packages/bridge/src/codex-process.ts`)
7. `{ type: "system", subtype: "session_created", sessionId, ... }` is broadcast to all connected clients
8. Mobile app navigates to `ClaudeSessionRoute` or `CodexSessionRoute` via `AppRouter` (`apps/mobile/lib/router/app_router.dart`)

### Message Flow (User Input)

1. User types message in `ChatInputWithOverlays` (`apps/mobile/lib/features/chat_session/widgets/chat_input_with_overlays.dart`)
2. `ChatSessionCubit.sendInput()` (`apps/mobile/lib/features/chat_session/state/chat_session_cubit.dart`) calls `BridgeService.send()`
3. `{ type: "input", text, sessionId }` sent over WebSocket
4. `BridgeWebSocketServer` delegates to `SessionManager.input()` which calls `SdkProcess.input()` or `CodexProcess.input()`
5. CLI agent processes the message and streams responses back

### Streaming Response Flow

1. CLI agent emits `stream-json` output (Claude) or stdout (Codex)
2. `SdkProcess` / `CodexProcess` parses the output into typed events
3. Events are emitted through `SessionManager` onMessage callback
4. `BridgeWebSocketServer` calls `broadcastSessionMessage(sessionId, msg)`
5. `BridgeService` receives the message, dispatches to the correct controller
6. `ChatSessionCubit` (subscribed to `messagesForSession(sessionId)`) processes via `ChatMessageHandler` (`apps/mobile/lib/services/chat_message_handler.dart`)
7. `ChatSessionCubit._applyUpdate()` updates `ChatSessionState`
8. For `StreamDeltaMessage`, text is appended to `StreamingStateCubit` (`apps/mobile/lib/features/chat_session/state/streaming_state_cubit.dart`)
9. `StreamingBubble` widget (`apps/mobile/lib/widgets/bubbles/streaming_bubble.dart`) renders in real-time

### Tool Approval Flow

1. CLI agent emits a permission request
2. Bridge sends `{ type: "permission_request", toolUseId, toolName, input }` to mobile
3. `ChatMessageHandler` creates `ChatStateUpdate` with `pendingPermission` set
4. `ApprovalBar` widget (`apps/mobile/lib/widgets/approval_bar.dart`) renders with Approve/Reject buttons
5. User taps Approve or Reject
6. `ChatSessionCubit.approveTool()` or `.rejectTool()` sends `{ type: "approve" | "reject", id, sessionId }` to bridge
7. Bridge delegates to `SdkProcess.handleToolApproval()` which calls the SDK permission result callback
8. CLI agent continues execution

### Push Notification Flow

1. Bridge detects a session event requiring notification (tool approval, completion, etc.)
2. `PushRelayClient.notify()` (`packages/bridge/src/push-relay.ts`) sends POST to Firebase Cloud Function
3. Authentication via Firebase Anonymous Auth (credentials in `~/.ccpocket/firebase-credentials.json`)
4. Cloud Function (`functions/src/index.ts`) looks up FCM tokens in Firestore, dispatches notification
5. Mobile app receives foreground FCM message via `FirebaseMessaging.onMessage` listener
6. `NotificationService` (`apps/mobile/lib/services/notification_service.dart`) shows local notification
7. Tapping notification navigates to the corresponding session via `_openSessionFromData()`

## State Management

**Approach:** flutter_bloc with Cubit pattern + Freezed immutable states

### Global State (Application-level)

Defined in `apps/mobile/lib/main.dart` via `MultiBlocProvider`:

| Cubit | File | Purpose |
|-------|------|---------|
| `ConnectionCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | WebSocket connection state (disconnected/connecting/connected/reconnecting) |
| `ActiveSessionsCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | Currently running sessions list |
| `RecentSessionsCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | Historical sessions from sessions-index |
| `GalleryCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | Gallery images from bridge |
| `FileListCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | Project file paths for @-mention autocomplete |
| `ProjectHistoryCubit` | `apps/mobile/lib/providers/bridge_cubits.dart` | Previously opened projects |
| `ServerDiscoveryCubit` | `apps/mobile/lib/providers/server_discovery_cubit.dart` | mDNS-discovered bridge servers |
| `SessionListCubit` | `apps/mobile/lib/features/session_list/state/session_list_cubit.dart` | Session list filters, pagination, search |
| `MachineManagerCubit` | `apps/mobile/lib/providers/machine_manager_cubit.dart` | Remote machine management (URLs, SSH) |
| `SettingsCubit` | `apps/mobile/lib/features/settings/state/settings_cubit.dart` | User preferences (theme, locale, push, etc.) |

All global Cubits that wrap `BridgeService` streams use `StreamCubit<T>` (`apps/mobile/lib/providers/stream_cubit.dart`), a generic Cubit that mirrors a `Stream<T>` as its state.

### Screen-level State

Per-session state is created at screen scope:

| Cubit | File | Purpose |
|-------|------|---------|
| `ChatSessionCubit` | `apps/mobile/lib/features/chat_session/state/chat_session_cubit.dart` | Single session messages, status, approval state, cost tracking |
| `StreamingStateCubit` | `apps/mobile/lib/features/chat_session/state/streaming_state_cubit.dart` | Real-time streaming text accumulation |
| `CodexSessionCubit` | `apps/mobile/lib/features/codex_session/state/codex_session_cubit.dart` | Extends `ChatSessionCubit` for Codex-specific behavior (no rewind) |
| `BranchCubit` | `apps/mobile/lib/features/git/state/branch_cubit.dart` | Git branch list |
| `CommitCubit` | `apps/mobile/lib/features/git/state/commit_cubit.dart` | Git commit state |
| `GitViewCubit` | `apps/mobile/lib/features/git/state/git_view_cubit.dart` | Git view mode and diff state |

### State Pattern

- **States** use `@freezed` annotations for immutable union types (`ChatSessionState`, `SettingsState`, `MachineManagerState`, etc.)
- **Cubit constructors** accept initial values and service dependencies
- **Message processing** follows: `ServerMessage` -> `ChatMessageHandler.handle()` -> `ChatStateUpdate` -> `ChatSessionCubit._applyUpdate()`
- **Side effects** are returned as `ChatSideEffect` enum values in `ChatStateUpdate`, executed by the widget layer

## Session Management Architecture

### Bridge Server Side

`SessionManager` (`packages/bridge/src/session.ts`) maintains an in-memory `Map<string, SessionInfo>`:

- **Session ID:** 8-character UUID prefix
- **Session lifecycle:** `create()` -> `start()` -> `input()` / `stop()` -> `remove()`
- **Multi-provider:** Each session is either `claude` or `codex` provider
- **Worktree support:** Sessions can optionally use git worktrees for isolated execution
- **History:** Each session stores up to `MAX_HISTORY_PER_SESSION = 100` messages in memory
- **Slash commands:** Cached per project path and delivered on `session_created`
- **Session resume:** Supports continuing existing Claude Code sessions via `--resume` flag

### Sessions Index (Historical)

`SessionsIndex` (`packages/bridge/src/sessions-index.ts`) provides persistent session history:

- Scans `~/.claude/projects/` for Claude Code JSONL session files
- Scans `~/.codex/threads/` for Codex session data
- Builds an index of past sessions with metadata (project path, git branch, summary, etc.)
- Supports pagination, filtering by project/provider, text search, and named-only filter
- Session renaming supported for both Claude (`customTitle`) and Codex (`thread_name`)

### Mobile App Side

- `BridgeService` holds the list of active sessions (`List<SessionInfo>`) and recent sessions (`List<RecentSession>`)
- `SessionListCubit` manages filters (project, provider, named-only, search) with server-side pagination
- Per-screen `ChatSessionCubit` subscribes to `messagesForSession(sessionId)` for isolated message streams

## Process Management

### Claude Code Process

`SdkProcess` (`packages/bridge/src/sdk-process.ts`):

- Uses `@anthropic-ai/claude-agent-sdk` `query()` function
- Spawns Claude Code CLI as a child process via the SDK
- Supports modes: `default`, `acceptEdits`, `bypassPermissions`, `plan`
- Auto-approval in `acceptEdits` mode for read-only and edit tools (defined in `ACCEPT_EDITS_AUTO_APPROVE`)
- Permission rule matching for session-level allow rules (e.g., `Bash(npm:*)`)
- Auth checking: validates Claude access token before starting sessions
- Rewind support via `SdkProcess.rewindFiles()` and `SdkProcess.rewindConversation()`
- Token usage extraction and accumulation (`inputTokens`, `outputTokens`, `cachedInputTokens`)

### Codex Process

`CodexProcess` (`packages/bridge/src/codex-process.ts`):

- Spawns Codex CLI as a child process
- Parses stdout line-by-line for events
- Supports approval policies: `untrusted`, `on-request`, `on-failure`, `never`
- Sandbox modes: `read-only`, `workspace-write`, `danger-full-access`
- Model selection: `gpt-5.4`, `gpt-5.4-mini`, `gpt-5.3-codex`, etc.
- Thread management: create, list, summarize threads
- Network access control and web search mode options

### Process Lifecycle

```
SessionManager.create()
  -> new SdkProcess() or new CodexProcess()
  -> process.start(cwd, options)
  -> process emits events via EventEmitter
  -> SessionManager.onMessage callback -> broadcast to WebSocket clients
  -> process.stop() on session end
```

## Message Parsing and Streaming Architecture

### Bridge Server Parser

`parser.ts` (`packages/bridge/src/parser.ts`):

- Defines all TypeScript types for `ClientMessage` and `ServerMessage` union types
- `parseClientMessage(json)` validates and parses incoming WebSocket messages
- Server message types include: `system`, `assistant`, `tool_result`, `result`, `error`, `status`, `history`, `permission_request`, `stream_delta`, `session_list`, `diff_result`, etc.
- `normalizeToolResultContent()` standardizes tool result content from both Claude and Codex formats

### Mobile App Message Deserialization

`messages.dart` (`apps/mobile/lib/models/messages.dart`):

- Dart sealed classes for `ServerMessage` with `ServerMessage.fromJson()` factory
- Covers all server message types with corresponding Dart classes
- `AssistantMessage` with sealed `AssistantContent` types: `TextContent`, `ToolUseContent`, `ThinkingContent`
- Enums for `Provider`, `ProcessStatus`, `PermissionMode`, `ExecutionMode`, `CodexApprovalPolicy`, `SandboxMode`

### Chat Message Handler

`ChatMessageHandler` (`apps/mobile/lib/services/chat_message_handler.dart`):

- Pure function pattern: `handle(ServerMessage) -> ChatStateUpdate`
- Converts server messages into UI-friendly state updates
- Manages streaming accumulation (`currentStreaming`)
- Handles slash commands, tool use hiding (subagent compression), cost tracking
- Graceful degradation for unsupported message types via `_unsupportedActions` map

### Streaming

- `StreamDeltaMessage` carries incremental text from the CLI agent
- `StreamingStateCubit` accumulates text fragments
- When a non-delta message arrives (or stream ends), accumulated text becomes a `ChatEntry`
- The `StreamingBubble` widget renders partial text in real-time

## Multi-session Support

### Bridge Server

- `SessionManager` maintains multiple concurrent sessions in its `Map<string, SessionInfo>`
- Each WebSocket client receives `session_list` broadcasts with all active sessions
- Messages are tagged with `sessionId` for routing
- `broadcastSessionMessage()` sends to all connected WebSocket clients (not just one)
- Multiple mobile clients can observe the same sessions simultaneously

### Mobile App

- `BridgeService` provides `messagesForSession(sessionId)` which filters the global message stream
- Each session screen creates its own `ChatSessionCubit` scoped to its session ID
- `SessionSwitcher` widget (`apps/mobile/lib/features/claude_session/widgets/session_switcher.dart`) allows switching between active sessions
- `SessionRouteObserver` (`apps/mobile/lib/router/session_route_observer.dart`) tracks which session is currently visible (for notification suppression)

## Connection Management and Reconnection Logic

### WebSocket Connection

`BridgeService.connect(url)` (`apps/mobile/lib/services/bridge_service.dart`):

1. Closes any existing connection
2. Creates `WebSocketChannel.connect(Uri.parse(url))`
3. Sets state to `BridgeConnectionState.connected`
4. Starts listening for incoming messages
5. Flushes any queued messages

### Auto-Reconnect

- On WebSocket disconnect (`onDone` or `onError`), if not intentional, schedules reconnect with exponential backoff
- Max reconnect delay: 30 seconds (`_maxReconnectDelay`)
- `_reconnectAttempt` counter increments each attempt
- `ensureConnected()` is called on app resume to detect silently killed iOS connections
- Uses `closeCode` check to distinguish real disconnection from perceived connection

### Connection Persistence

- WebSocket URL stored in `SharedPreferences` via `savePreferences(url)`
- API keys stored in `FlutterSecureStorage` via `MachineManagerService` (not plaintext)
- `autoConnect()` restores connection on app launch using saved preferences
- Deep link support via `app_links` package for `ccpocket://` URLs

### Server Discovery

- `ServerDiscoveryCubit` uses `ServerDiscoveryService` (`apps/mobile/lib/services/server_discovery_service.dart`)
- Platform-conditional: uses `bonsoir` (Bonjour/mDNS) on native, stub on web
- Discovered servers shown in `DiscoveredServersList` widget (`apps/mobile/lib/features/session_list/widgets/discovered_servers_list.dart`)
- Bridge advertises via `MdnsAdvertiser` (`packages/bridge/src/mdns.ts`) using `bonjour-service` package
- TXT records include `version` and `auth` fields

## Authentication Flow

### WebSocket Authentication

- Bridge server accepts optional `BRIDGE_API_KEY` environment variable
- When set, clients must include `?token=<API_KEY>` in the WebSocket URL
- Authentication happens on WebSocket connection (not per-message)
- Invalid token results in WebSocket close with code `4001`
- Connection URL with token is stored via `MachineManagerService` in `FlutterSecureStorage`

### Machine Manager

`MachineManagerService` (`apps/mobile/lib/services/machine_manager_service.dart`):

- Stores multiple bridge server configurations (name, URL, API key)
- API keys persisted in `FlutterSecureStorage` (encrypted)
- Health checks via HTTP `/health` endpoint
- SSH startup support via `SshStartupService` (`apps/mobile/lib/services/ssh_startup_service.dart`)

### Firebase Authentication (Push Relay)

`FirebaseAuthClient` (`packages/bridge/src/firebase-auth.ts`):

- Uses Firebase Auth REST API directly (no Node.js SDK dependency)
- Anonymous sign-in on bridge startup
- Credentials persisted to `~/.ccpocket/firebase-credentials.json`
- Auto-refreshes expired ID tokens
- UID serves as `bridgeId` for FCM token registration

## Error Handling

**Strategy:** Graceful degradation with actionable error messages

### Bridge Server

- `errorCode` field on error messages for programmatic handling
- Known error codes: `unsupported_message`, `path_not_allowed`, `auth_login_required`, `auth_token_expired`, `auth_api_error`
- Push relay failures logged but do not disrupt sessions
- mDNS failures are non-fatal (logging only)

### Mobile App

- `ChatMessageHandler._unsupportedActions` map defines behavior for unknown message types
  - `suppress` (default): log only, no UI impact
  - `showUpdateHint`: amber warning bubble suggesting bridge update
- `BridgeService.ensureConnected()` recovers from silently dropped connections
- Global `FlutterError.onError` and `TalkerBlocObserver` for error logging
- `StructuredErrorInference` (`apps/mobile/lib/utils/structured_error_inference.dart`) for user-friendly error display

## Cross-Cutting Concerns

**Logging:**
- Bridge Server: `console.log` / `console.warn` / `console.error` with `[bridge]`, `[ws]`, `[session]` prefixes
- Mobile App: `talker` logger (`apps/mobile/lib/core/logger.dart`) with `TalkerBlocObserver` for Bloc event logging

**Validation:**
- Client messages validated via `parseClientMessage()` in `parser.ts`
- Project paths validated against `BRIDGE_ALLOWED_DIRS` allowlist
- API key validated on WebSocket connection

**Localization:**
- Flutter `gen_l10n` with ARB files: `app_en.arb`, `app_ja.arb`, `app_zh.arb`
- Generated files in `apps/mobile/lib/l10n/`
- Push notification localization via `push-i18n.ts` (`packages/bridge/src/push-i18n.ts`)

**OTA Updates:**
- Shorebird Code Push for iOS/Android hot patches
- `ShorebirdUpdater` checks for patches on app launch (`main.dart`)
- User-selectable update track: `stable` or `staging`

---

*Architecture analysis: 2026-04-02*
