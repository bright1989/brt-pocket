# Codebase Structure

**Analysis Date:** 2026-04-02

## Directory Layout

```
ccpocket/
  apps/
    mobile/
      lib/
        constants/         # App-wide constants and feature flags
        core/              # Core utilities (logger)
        features/          # Feature-first modules (screens, state, widgets)
          chat_session/    # Shared chat session state and widgets
          claude_session/  # Claude Code session screen
          codex_session/   # Codex session screen
          debug/           # Debug screen
          file_peek/       # File content preview sheet
          gallery/         # Image gallery
          git/             # Git operations (branch, commit, diff)
          message_images/  # Message image viewer
          prompt_history/  # Prompt history browser
          session_list/    # Home screen (session list and connection)
          settings/        # Settings screen
          setup_guide/     # First-time setup wizard
        hooks/             # Flutter hooks (useAppResume, useScrollTracking, etc.)
        l10n/              # Localization (ARB source and generated Dart)
        main.dart          # App entry point
        mock/              # Mock data for UI preview
        models/            # Data models (messages, machine, session)
        providers/         # Global Bloc/Cubit providers
        router/            # AutoRoute configuration
        screens/           # Standalone screens (mock preview, QR scan)
        services/          # Business logic services
        theme/             # App theming, markdown styles
        utils/             # Utility functions
        widgets/           # Shared widgets (bubbles, input bar, session cards)
      pubspec.yaml
      test/
  functions/
    src/index.ts           # Firebase Cloud Functions (push relay)
  packages/
    bridge/
      src/                 # Bridge Server source (TypeScript)
      tsconfig.json
      vitest.config.ts
      package.json
      CHANGELOG.md
  scripts/                 # Automation and utility scripts
  .claude/                 # Claude Code skills, agents, hooks
  .github/                 # GitHub Actions workflows
  docs/                    # Project documentation
  package.json             # npm workspace root
```

## Directory Purposes

### apps/mobile/lib/ -- Flutter Application

**constants/**
- Purpose: App-wide constants and feature flag configuration
- Key files: `app_constants.dart` (default values), `feature_flags.dart` (feature toggles)

**core/**
- Purpose: Cross-cutting core utilities
- Key files: `logger.dart` (talker-based logging singleton)

**features/** -- Feature-First Modules
- Purpose: Each subdirectory is a self-contained feature with screen, state, and widgets
- Pattern: Each feature has a screen file (StatefulWidget) and optionally a `state/` directory with Cubit + Freezed state
- Shared features: `chat_session/` provides shared chat UI consumed by both Claude and Codex screens

**hooks/**
- Purpose: Reusable Flutter hooks for widget lifecycle and behavior
- Key files: `use_scroll_tracking.dart`, `use_keyboard_scroll_adjustment.dart`, `use_voice_input.dart`, `use_list_auto_complete.dart`

**l10n/**
- Purpose: Internationalization source and generated files
- Source: `app_en.arb` (English), `app_ja.arb` (Japanese), `app_zh.arb` (Chinese)
- Generated: `app_localizations.dart`, `app_localizations_en.dart`, etc.

**mock/**
- Purpose: Mock data for UI preview and testing
- Key files: `mock_scenarios.dart` (10 mock scenarios), `mock_sessions.dart`, `mock_image_data.dart`, `store_screenshot_data.dart`

**models/**
- Purpose: Shared data model definitions used across features
- Key files: `messages.dart` (86K, all ServerMessage/ClientMessage types), `machine.dart` (MachineWithStatus), `recorded_event.dart`, `terminal_app.dart`
- Generated: `machine.freezed.dart`, `machine.g.dart`

**providers/**
- Purpose: Global state providers registered in `main.dart` via BtMultiBlocProvider`
- Key files: `bridge_cubits.dart` (typedefs for stream-backed cubits), `stream_cubit.dart` (generic stream-to-cubit adapter), `machine_manager_cubit.dart`, `server_discovery_cubit.dart`, `unseen_sessions_cubit.dart`
- Generated: `machine_manager_cubit.freezed.dart`

**router/**
- Purpose: Declarative routing with AutoRoute
- Key files: `app_router.dart` (route definitions), `app_router.gr.dart` (generated), `session_route_observer.dart` (tracks active session for notification suppression)

**screens/**
- Purpose: Standalone screens that do not belong to a feature module
- Key files: `mock_preview_screen.dart` (AppBar mock button preview), `qr_scan_screen.dart` (QR code scanner for connection URLs)

**services/**
- Purpose: Business logic and external service integration
- Key files:
  - `bridge_service.dart` (1155 lines, WebSocket client and all stream controllers)
  - `bridge_service_base.dart` (abstract interface for BridgeService and MockBridgeService)
  - `chat_message_handler.dart` (converts ServerMessage to ChatStateUpdate)
  - `database_service.dart` (SQLite for prompt history)
  - `draft_service.dart` (unsent message drafts)
  - `fcm_service.dart` (Firebase Cloud Messaging token management)
  - `machine_manager_service.dart` (machine CRUD, health checks, SSH startup)
  - `mock_bridge_service.dart` (mock implementation for UI preview)
  - `notification_service.dart` (local notification display)
  - `ssh_startup_service.dart` (remote bridge startup via SSH)
  - `voice_input_service.dart` (speech-to-text)

**theme/**
- Purpose: App theming and markdown rendering styles
- Key files: `app_theme.dart` (light/dark themes, color palette), `markdown_style.dart` (syntax highlighting), `app_spacing.dart`, `provider_style.dart`

**utils/**
- Purpose: Pure utility functions
- Key files: `diff_parser.dart` (unified diff parser), `tool_categories.dart` (tool categorization for UI), `debug_bundle_share.dart`, `structured_error_inference.dart`, `terminal_launcher.dart`, `platform_helper.dart`

**widgets/** -- Shared Widgets
- Purpose: Reusable UI components consumed by multiple features
- Key files:
  - `chat_input_bar.dart` (message input with attachments, slash commands, voice)
  - `new_session_sheet.dart` (93K, session creation form with all options)
  - `session_card.dart` (98K, session list item with status, actions)
  - `approval_bar.dart` (tool approval/rejection UI)
  - `message_bubble.dart` (assistant message rendering)
  - `slash_command_sheet.dart` (slash command browser)
- **bubbles/** subdirectory: Specialized bubble widgets for each message type (`assistant_bubble.dart`, `user_bubble.dart`, `tool_result_bubble.dart`, `thinking_bubble.dart`, `error_bubble.dart`, `plan_card.dart`, `result_chip.dart`, etc.)

### packages/bridge/src/ -- Bridge Server

**Purpose:** WebSocket bridge server connecting mobile clients to Claude Code and Codex CLI processes

Key files (by responsibility):

| File | Size | Purpose |
|------|------|---------|
| `websocket.ts` | 150K | WebSocket server, message routing, session management orchestration |
| `codex-process.ts` | 80K | Codex CLI process wrapper (spawn, events, thread management) |
| Btsessions-index.ts` | 70K | Persistent session index (scans JSONL files, pagination, search) |
| `session.ts` | 33K | In-memory session manager (create, start, stop, rewind) |
| `sdk-process.ts` | 41K | Claude Code SDK process wrapper (spawn via SDK, permission handling) |
| `parser.ts` | 31K | Message type definitions, ClientMessage/ServerMessage parsing |
| `git-operations.ts` | 10K | Git stage/unstage/commit/push/branch/revert operations |
| `gallery-store.ts` | 13K | Disk-persistent image gallery management |
| `image-store.ts` | 5K | In-memory session-scoped image storage |
| `usage.ts` | 20K | Claude auth status, token validation, usage/cost fetching |
| `doctor.ts` | 22K | Environment diagnostic checks (CLI, SDK, tools) |
| `worktree.ts` | 11K | Git worktree creation/removal/listing |
| `proxy.ts` | 3K | HTTP/SOCKS proxy setup for SDK connections |
| `push-relay.ts` | 3K | Firebase Cloud Functions relay client for FCM push |
| `firebase-auth.ts` | 6K | Firebase Anonymous Auth (REST API, credential persistence) |
| `mdns.ts` | 2K | mDNS advertisement via bonjour-service |
| `startup-info.ts` | 4K | Startup banner with connection instructions |
| `index.ts` | 8K | Server entry point (HTTP + WebSocket, store initialization) |
| `cli.ts` | 3K | CLI interface for bridge doctor command |
| `version.ts` | 2K | Package version info |

Test files: Co-located with source as `*.test.ts` (e.g., `websocket.test.ts`, `session.test.ts`, etc.)

### functions/src/ -- Firebase Cloud Functions

- Purpose: Push notification relay (FCM token registration, notification dispatch)
- Key file: `index.ts` (single HTTP-triggered function with register/unregister/notify operations)
- Auth: Firebase App Check + Firestore-backed rate limiting

### .claude/ -- Claude Code Configuration

- **agents/**: Custom sub-agents (`code-reviewer.md`, `e2e-verifier.md`)
- **hooks/**: Quality gates (`post-edit-analyze.sh`, `pre-stop-check.sh`)
- **skills/**: Custom slash commands (`release-bridge/`, `release-app/`, `test-bridge/`, `test-flutter/`, `mobile-automation/`, `self-review/`, `shorebird-patch/`, `sim-preview/`, `web-preview/`, `flutter-ui-design/`, `merge/`, etc.)
- **settings.json**: Claude Code project settings

### scripts/ -- Automation Scripts

- `dev-restart.sh`: One-command dev restart (bridge + Flutter)
- `setup-launchd.sh`: macOS launchd service installation
- `check-secrets.sh`: Pre-commit secret scanning
- `daily-metrics.sh`: Daily project metrics collection
- `generate-jwt.py`: JWT generation for testing
- `setup-test-repo.sh`: Test repository setup
- `feature-graphic/`: Store feature graphic assets
- `install-banner/`: Install instruction banner generation

## Key File Locations

### Entry Points

| Path | Purpose |
|------|---------|
| `apps/mobile/lib/main.dart` | Flutter app entry point (BlocProvider setup, deep links, FCM, Shorebird) |
| `packages/bridge/src/index.ts` | Bridge server entry point (HTTP + WebSocket server, store init) |
| `packages/bridge/src/cli.ts` | Bridge CLI entry point (doctor command) |
| `functions/src/index.ts` | Firebase Cloud Functions entry point (push relay) |

### Configuration

| Path | Purpose |
|------|---------|
| `package.json` (root) | npm workspace root, shared scripts |
| `packages/bridge/package.json` | Bridge package config, dependencies, scripts |
| `packages/bridge/tsconfig.json` | TypeScript config (ESM, strict, NodeNext) |
| `packages/bridge/vitest.config.ts` | Vitest test runner config |
| `apps/mobile/pubspec.yaml` | Flutter dependencies and app metadata |
| `.mcp.json` | MCP tool configuration for Claude Code |
| `.mise.toml` | mise tool version manager config |
| `.gtrconfig` | Git worktree config (copy/include/exclude rules) |
| `firebase.json` | Firebase project configuration |
| `firestore.rules` | Firestore security rules |
| `.gitignore` | Git ignore patterns |
| `packages/bridge/com.ccpocket.bridge.plist` | macOS launchd plist template |

### Core Logic

| Path | Purpose |
|------|---------|
| `packages/bridge/src/websocket.ts` | WebSocket server, message routing, all client message handlers |
| `packages/bridge/src/session.ts` | Session lifecycle management |
| `packages/bridge/src/sdk-process.ts` | Claude Code SDK integration |
| `packages/bridge/src/codex-process.ts` | Codex CLI integration |
| `packages/bridge/src/sessions-index.ts` | Persistent session history index |
| `packages/bridge/src/parser.ts` | Message type system and parsing |
| `apps/mobile/lib/services/bridge_service.dart` | WebSocket client, all stream controllers |
| `apps/mobile/lib/services/chat_message_handler.dart` | ServerMessage to UI state conversion |
| `apps/mobile/lib/features/chat_session/state/chat_session_cubit.dart` | Per-session state management |
| `apps/mobile/lib/models/messages.dart` | Dart message type definitions (87K) |

## Naming Conventions

### Files
- Dart: `snake_case.dart` (e.g., `chat_session_cubit.dart`)
- TypeScript: `kebab-case.ts` (e.g., `sdk-process.ts`, `gallery-store.ts`)
- Generated Dart: `*.freezed.dart`, `*.g.dart`, `*.gr.dart` (auto-generated, never edit manually)
- Test files: Co-located as `*_test.dart` (Flutter) or `*.test.ts` (Bridge)

### Directories
- Feature directories: `snake_case` (e.g., `chat_session/`, `session_list/`)
- State directories: Always named `state/` within a feature
- Widget directories: Always named `widgets/` within a feature

### Code Symbols
- Dart classes: `PascalCase` (e.g., `ChatSessionCubit`, `BridgeService`)
- Dart functions/methods: `camelCase` (e.g., `sendInput()`, `messagesForSession()`)
- Dart private members: `_leadingUnderscore` (e.g., `_bridge`, `_subscription`)
- TypeScript classes: `PascalCase` (e.g., `SessionManager`, `PushRelayClient`)
- TypeScript functions/methods: `camelCase` (e.g., `broadcastSessionMessage()`)
- TypeScript private members: `_leadingUnderscore` (e.g., `_sessions`, `_apiKey`)
- TypeScript constants: `UPPER_SNAKE_CASE` (e.g., `ACCEPT_EDITS_AUTO_APPROVE`)
- Dart enums: `PascalCase` with `camelCase` values (e.g., `ProcessStatus.starting`)

## Where to Add New Code

### New Feature
- Primary screen: Create a new directory under `apps/mobile/lib/features/<feature_name>/`
- Add the screen file (`<feature_name>_screen.dart`) as a BtRoutePage` annotated StatefulWidget
- Add state management in a `state/` subdirectory (Cubit + Freezed state)
- Add feature-specific widgets in a `widgets/` subdirectory
- Register the route in `apps/mobile/lib/router/app_router.dart`
- Tests: `apps/mobile/test/features/<feature_name>/`

### New Shared Widget
- Place in `apps/mobile/lib/widgets/` if used across multiple features
- If it is a message bubble variant, place in `apps/mobile/lib/widgets/bubbles/`
- Follow existing patterns: separate into its own file with a single main widget class

### New Service
- Place in `apps/mobile/lib/services/`
- If the service has a mock version for testing, implement `BridgeServiceBase` interface
- Register as a BtRepositoryProvider` in `main.dart`

### New Bridge Server Module
- Place in `packages/bridge/src/` following the `kebab-case.ts` naming
- Add a co-located test file `<module>.test.ts`
- If the module emits server messages, add types to `packages/bridge/src/parser.ts`
- If it handles client messages, add a handler in `packages/bridge/src/websocket.ts`

### New Shared Utility (Flutter)
- Place in `apps/mobile/lib/utils/` for pure utility functions
- Place in `apps/mobile/lib/hooks/` for Flutter hooks (widget lifecycle integration)

### New Global State (Flutter)
- Create a Cubit class in `apps/mobile/lib/providers/` or in the feature's `state/` directory
- If it wraps a `BridgeService` stream, use BtStreamCubit<T>` as a base typedef
- Register in the BtMultiBlocProvider` in `main.dart`

## Special Directories

### `apps/mobile/lib/l10n/` -- Localization
- Purpose: Flutter ARB source files and generated Dart localization classes
- Generated: Yes (by `flutter gen-l10n`)
- Committed: Yes (both source ARB files and generated Dart files)

### `apps/mobile/lib/mock/` -- Mock Data
- Purpose: Predefined mock scenarios for UI development and AppBar mock preview
- Generated: No
- Committed: Yes
- Contains: 10 mock scenarios covering various message types and states

### `packages/bridge/src/` (test files) -- Bridge Tests
- Purpose: Vitest test files co-located with source
- Generated: No
- Committed: Yes
- Pattern: `<module>.test.ts` beside `<module>.ts`
- Run: `npm run test --workspace=packages/bridge`

### `.claude/skills/` -- Custom Skills
- Purpose: Claude Code slash commands for project-specific workflows
- Generated: No
- Committed: Yes
- Each skill is a directory with `skill.md` describing the command

### `.claude/agents/` -- Custom Agents
- Purpose: Specialized sub-agents (code review, E2E verification)
- Generated: No
- Committed: Yes
- Each agent is a `.md` file with model, memory, and instructions

### `scripts/feature-graphic/` -- Store Assets
- Purpose: Generated feature graphic images for app store listings
- Generated: Yes
- Committed: Varies (typically in `.gitignore`)

### `docs/` -- Project Documentation
- Purpose: Design docs, specifications, and implementation notes
- Generated: No
- Committed: Yes

## Build Artifacts

- `apps/mobile/build/`: Flutter build output (gitignored)
- `packages/bridge/dist/`: TypeScript compiled output (gitignored)
- `apps/mobile/.dart_tool/`: Flutter build cache (gitignored)
- `apps/mobile/lib/router/app_router.gr.dart`: AutoRoute generated router (committed)
- `apps/mobile/lib/models/*.freezed.dart`: Freezed generated union types (committed)
- `apps/mobile/lib/models/*.g.dart`: JsonSerializable generated code (committed)
- `apps/mobile/lib/features/*/state/*.freezed.dart`: Freezed generated states (committed)

---

*Structure analysis: 2026-04-02*
