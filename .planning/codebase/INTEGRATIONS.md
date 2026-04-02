# External Integrations

**Analysis Date:** 2026-04-02

## APIs and External Services

### Claude Agent SDK (Anthropic)
- SDK: `@anthropic-ai/claude-agent-sdk` ^0.2.74
- Purpose: Spawns and manages Claude Code CLI processes via the SDK
- Implementation: `packages/bridge/src/sdk-process.ts` (base class), `packages/bridge/src/claude-process.ts` (Claude-specific)
- API used: query() from SDK for streaming agent interactions
- Auth: Reads Claude Code OAuth credentials from ~/.claude/.credentials.json or macOS Keychain
- OAuth client: Uses Claude Code OAuth client ID for token refresh
- Token URL: https://platform.claude.com/v1/oauth/token

### Codex CLI
- Purpose: Spawns and manages OpenAI Codex CLI processes
- Implementation: `packages/bridge/src/codex-process.ts`
- Communication: Spawns Codex as child process, communicates via stdin/stdout JSON-RPC
- Models: o3, o4-mini, and Codex-specific models
- Features: Approval policy management (untrusted, on-request, on-failure, never)

### Anthropic API (Usage Tracking)
- Purpose: Fetch Claude Code usage data (token utilization, rate limits)
- Implementation: `packages/bridge/src/usage.ts`
- Endpoint: Usage data fetched via Claude Code CLI (not direct API call)
- Auth: Reuses Claude Code OAuth credentials
- Controlled by: BRIDGE_ENABLE_USAGE env var (opt-in, direct Anthropic API communication)

### Firebase Cloud Functions (Push Relay)
- URL: https://us-central1-ccpocket-ca33b.cloudfunctions.net/relay
- Purpose: FCM token management and push notification relay
- Implementation: `functions/src/index.ts` (server), `packages/bridge/src/push-relay.ts` (client)
- Auth: Firebase Anonymous Auth ID token (Bearer token)
- Operations: register, unregister, notify (FCM multicast)

## Data Storage

### Local SQLite Database (Flutter App)
- Client: sqflite ^2.4.2
- Implementation: `apps/mobile/lib/services/database_service.dart`
- Database: ccpocket.db (v1 schema)
- Tables: prompt_history (text, project_path, use_count, is_favorite, timestamps)
- Indexes: idx_prompt_text_project (unique), idx_prompt_last_used, idx_prompt_project

### SharedPreferences (Flutter App)
- Client: shared_preferences ^2.5.0
- Purpose: App settings, connection history, review metrics, update dismissal
- Platform: iOS (NSUserDefaults), Android (SharedPreferences), Web (localStorage)

### Flutter Secure Storage
- Client: flutter_secure_storage ^10.0.0
- Purpose: Sensitive data (SSH keys, API keys, Bridge connection credentials)
- Platform: iOS (Keychain), Android (EncryptedSharedPreferences)

### File System Storage (Bridge Server)
- Image store: In-memory session-scoped image cache (`packages/bridge/src/image-store.ts`)
- Gallery store: Disk-persistent image storage (`packages/bridge/src/gallery-store.ts`)
- Project history: `packages/bridge/src/project-history.ts`
- Recording store: Session recordings (`packages/bridge/src/recording-store.ts`)
- Debug trace store: `packages/bridge/src/debug-trace-store.ts`
- Archive store: `packages/bridge/src/archive-store.ts`
- Worktree store: `packages/bridge/src/worktree-store.ts`
- Firebase credentials: ~/.ccpocket/firebase-credentials.json
- Prompt history backup: `packages/bridge/src/prompt-history-backup.ts`

### Firestore (Firebase Cloud)
- Collections: bridges/{bridgeId}/tokens (FCM tokens), rate_limits (rate limiting)
- TTL: Rate limit docs use expireAt field for auto-deletion

## File Storage
- Service: Local filesystem only (Bridge Server)
- Gallery images: Disk-persistent via GalleryStore
- Session images: In-memory via ImageStore (session-scoped)
- No cloud file storage integration

## Caching
- Diff image cache: In-memory on Flutter side (keyed by project path + file path)
- Image cache: extended_image ^10.0.1 on Flutter side
- No Redis or external caching layer

## Authentication and Identity

### Bridge Server WebSocket Auth
- Implementation: `packages/bridge/src/websocket.ts`
- Method: API key in first message (when BRIDGE_API_KEY env var is set)
- Type: Simple shared secret (not OAuth/JWT)
- Response: Sends system message with init or error
- Client: `apps/mobile/lib/services/bridge_service.dart`

### Firebase Anonymous Auth (Bridge Server)
- Purpose: Identity for push notification relay
- Implementation: `packages/bridge/src/firebase-auth.ts`
- Method: Firebase Auth REST API (signUp + token refresh, no client SDK)
- Project: ccpocket-ca33b
- Credentials persisted: ~/.ccpocket/firebase-credentials.json (UID + refresh token)
- SDK API key embedded in source (not secret, public Firebase config)

### Claude Code OAuth
- Purpose: Reuse Claude Code authentication for usage tracking
- Implementation: `packages/bridge/src/usage.ts`
- Credential sources: ~/.claude/.credentials.json (file), macOS Keychain (service: Claude Code-credentials)
- OAuth client ID embedded in source (Claude Code client ID)

### SSH Authentication
- Client: dartssh2 ^2.10.0
- Implementation: `apps/mobile/lib/services/ssh_startup_service.dart`
- Purpose: Remote Bridge Server management (start/stop via launchctl)
- Credentials: Stored in flutter_secure_storage

## Monitoring and Observability

### Logging
- Bridge Server: console.log / console.warn / console.error (structured prefixes like [bridge], [firebase-auth], [push-relay])
- Flutter App: talker ^5.1.13 (global logger instance in `apps/mobile/lib/core/logger.dart`)
- BLoC events: talker_bloc_logger for state management logging
- Debug trace: Session-scoped debug events via DebugTraceStore

### Error Tracking
- No external error tracking service (no Sentry, Bugsnag, etc.)
- Flutter: Global error handler in main.dart
- Bridge: Unhandled rejection / uncaught exception logging

## Push Notifications

### FCM (Firebase Cloud Messaging)
- Flutter client: `apps/mobile/lib/services/fcm_service.dart`
- Local display: `apps/mobile/lib/services/notification_service.dart` (flutter_local_notifications ^20.0.0)
- Channel: ccpocket_channel (Android, high importance)
- Events: permission_request, session_complete, agent_waiting
- Locale-aware: Notifications filtered by locale (en, ja, zh)
- Background handler: Registered in main.dart (no-op, OS handles display)

### Push Relay Flow
1. Flutter app obtains FCM token via FirebaseMessaging.instance.getToken()
2. App sends push_register message to Bridge Server via WebSocket
3. Bridge calls PushRelayClient.registerToken() to Cloud Function
4. Cloud Function stores token in Firestore under bridges/{bridgeId}/tokens
5. When agent needs attention, Bridge calls PushRelayClient.notify()
6. Cloud Function sends multicast FCM to all tokens for that bridge
7. Invalid tokens are auto-cleaned from Firestore

## mDNS Discovery (Local Network)

### Bridge Server (Advertiser)
- Package: bonjour-service ^1.3.0
- Implementation: `packages/bridge/src/mdns.ts`
- Service type: _ccpocket._tcp
- TXT records: version=1, auth=required|none
- Configurable: BRIDGE_DISABLE_MDNS env var to disable

### Flutter App (Discoverer)
- Package: bonsoir ^6.0.1
- Implementation: `apps/mobile/lib/services/server_discovery_service.dart` (interface), `apps/mobile/lib/services/server_discovery_impl_io.dart` (bonsoir impl)
- Conditional import: Uses stub on web platform, bonsoir on native
- Events: service resolved (host, port, auth), service lost

## WebSocket Protocol

### Connection
- URL format: ws://host:port or wss://host:port
- Auth: API key sent as first message (optional)
- Default port: 8765
- Client: web_socket_channel ^3.0.3 (Flutter), ws ^8.18.0 (Bridge)

### Client to Server Messages (key types)
- start: New session (projectPath, provider, sessionId, permissionMode, model, etc.)
- input: User message (text, images, sessionId)
- approve / reject: Tool execution approval/rejection
- answer: AskUserQuestion response
- push_register / push_unregister: FCM token management
- set_permission_mode: Runtime permission changes
- stop_session: Stop a running session
- get_history: Load session message history
- get_diff: Fetch git diff for a project
- Various git operations: stage, unstage, commit, push, branch management
- Full protocol: ~50 message types defined in `packages/bridge/src/parser.ts`

### Server to Client Messages (key types)
- system: Init, session_created, model info, skill metadata
- assistant: Agent response messages (text, tool_use, thinking)
- tool_result: Tool execution results (with optional images)
- result: Session completion (cost, duration, tokens)
- error: Error notifications (with errorCode for graceful degradation)
- status: Process status (idle, running, waiting_approval)
- permission_request: Tool permission prompt
- stream_delta / thinking_delta: Streaming text chunks
- diff_result / diff_image_result: Git diff display
- session_list: Active and recent sessions
- Various git results, worktree operations, debug bundles
- Full protocol: ~60 message types defined in `packages/bridge/src/parser.ts`

### Graceful Degradation
- Bridge returns errorCode: unsupported_message for unknown types
- App uses _unsupportedActions map in `apps/mobile/lib/services/chat_message_handler.dart`
- Strategies: suppress (log only), showUpdateHint (warn user to update Bridge)

## CI/CD and Deployment

### GitHub Actions Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| test.yml | PR, push to main | Flutter analyze + test |
| bridge-release.yml | Tag: bridge/v* | npm publish + GitHub Release |
| ios-release.yml | Tag: ios/v* | Shorebird release + TestFlight upload |
| android-release.yml | Tag: android/v* | Shorebird release + Play Store upload |
| macos-release.yml | Tag: macos/v* | macOS build + sign + notarize + DMG |
| ios-patch.yml | Manual | Shorebird OTA patch (iOS staging) |
| android-patch.yml | Manual | Shorebird OTA patch (Android staging) |
| pages.yml | Push to docs/ | GitHub Pages deployment |
| daily-metrics.yml | Schedule | Daily metrics collection |
| upload-metadata.yml | Manual | Store screenshot + metadata upload |

### Shorebird OTA
- Package: shorebird_code_push ^2.0.5
- App ID: 54b45d3c-0bf2-4208-9ded-7b5c01368bb9
- auto_update: false (manual track control: stable/staging)
- Patch flow: staging release -> verify -> promote to stable
- Config: `apps/mobile/shorebird.yaml`
- Scripts: `.claude/skills/shorebird-patch/` (patch.sh, promote.sh)

### App Store Distribution
- iOS: TestFlight via apple-actions/upload-testflight-build@v3
- Android: Google Play internal track (draft) via r0adkll/upload-google-play@v1
- macOS: GitHub Release with signed/notarized DMG

### npm Publishing
- Package: @ccpocket/bridge
- Registry: npm (public access)
- Provenance: OIDC signing (npm publish --provenance)
- CI: GitHub Actions with npm registry token

## Deep Links

### App Links
- Package: app_links ^7.0.0
- Implementation: `apps/mobile/lib/main.dart` (AppLinks listener)
- Purpose: Open connection URLs (ccpocket:// scheme), navigate to sessions

### URL Launcher
- Package: url_launcher ^6.3.1
- Purpose: Open external URLs (GitHub, App Store, documentation)

## Native Platform Integrations

### Speech to Text
- Package: speech_to_text ^7.3.0
- Implementation: `apps/mobile/lib/services/voice_input_service.dart`
- Platform: iOS (SFSpeechRecognizer), Android (Google Speech API)
- Disabled on desktop and web platforms

### Image Picker
- Package: image_picker ^1.1.2
- Purpose: Camera and gallery image selection for chat messages

### QR Code Scanner
- Bridge (generate): qrcode ^1.5.4 in `packages/bridge/src/index.ts`
- App (scan): mobile_scanner ^7.1.4
- Purpose: Scan connection QR code to auto-connect to Bridge

### In-App Review
- Package: in_app_review ^2.0.11
- Implementation: `apps/mobile/lib/services/in_app_review_service.dart`
- Eligibility: Min 3 connections, 3 sessions, 5 approvals, 2 usage days, 3-day install age
- Cooldown: 90 days between prompts

### Local Notifications
- Package: flutter_local_notifications ^20.0.0
- Implementation: `apps/mobile/lib/services/notification_service.dart`
- Android channel: ccpocket_channel (high importance)
- iOS: requestAlertPermission, requestBadgePermission, requestSoundPermission
- Not available on web

### Share
- Package: share_plus ^12.0.1
- Purpose: Share session content, app install links

## Proxy Support

- Implementation: `packages/bridge/src/proxy.ts`
- Env vars: HTTPS_PROXY, HTTP_PROXY, ALL_PROXY
- Protocols: http://, https:// (via undici ProxyAgent), socks4://, socks5://, socks5h:// (via socks + undici Agent)
- Scope: Global fetch dispatcher (affects all outbound HTTP from Bridge)

## Environment Configuration

### Required env vars (Bridge Server)
- None required for basic operation
- BRIDGE_API_KEY: Optional, enables authentication
- BRIDGE_ENABLE_USAGE: Optional, enables Anthropic API usage fetching
- HTTPS_PROXY: Optional, proxy configuration

### Secrets location
- Firebase: GitHub Actions secrets (APP_STORE_CONNECT_*, CERTIFICATE_PRIVATE_KEY, SHOREBIRD_TOKEN, etc.)
- Android signing: GitHub Actions secrets (KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_ALIAS, GCLOUD_SERVICE_ACCOUNT_CREDENTIALS)
- Firebase config: GOOGLE_SERVICE_INFO_PLIST_BASE64 (iOS), GOOGLE_SERVICES_JSON_BASE64 (Android)
- npm: GitHub Actions OIDC (no stored secret)
- macOS signing: MACOS_CERTIFICATE_P12, MACOS_CERTIFICATE_PASSWORD in GitHub Actions
- Local: flutter_secure_storage on device, ~/.ccpocket/ on host machine

## Webhooks and Callbacks

### Incoming
- None (Bridge does not expose webhook endpoints)

### Outgoing
- FCM relay: POST to https://us-central1-ccpocket-ca33b.cloudfunctions.net/relay
- Firebase Auth REST: POST to https://identitytoolkit.googleapis.com/v1/accounts:signUp
- Firebase token refresh: POST to https://securetoken.googleapis.com/v1/token
- Claude OAuth token refresh: POST to https://platform.claude.com/v1/oauth/token

---

*Integration audit: 2026-04-02*
