# Codebase Concerns
**Analysis Date:** 2026-04-02
---
## Critical
### Hardcoded Firebase API Key in Source Code
- **Issue:** Firebase Web API key is hardcoded in `packages/bridge/src/firebase-auth.ts` (line 20). Public npm package; key ships in dist.
- **Files:** `packages/bridge/src/firebase-auth.ts`
- **Impact:** Unauthorized access if Firebase rules are misconfigured.
- **Fix approach:** Move to env var. Validate Firebase rules.
### No TLS/WSS Support
- **Issue:** Bridge uses plain HTTP and unencrypted WebSocket. No TLS option. API keys in URL query params.
- **Files:** `packages/bridge/src/index.ts` (line 99), `packages/bridge/src/websocket.ts` (line 301)
- **Impact:** API keys exposed to network sniffing.
- **Fix approach:** Add HTTPS/WSS. Move API key to first-message auth.
### WebSocket API Key in URL Query Parameter
- **Issue:** API key passed as `?token=` query param. OWASP A01:2021.
- **Files:** `packages/bridge/src/websocket.ts` (lines 321-327), `apps/mobile/lib/services/bridge_service.dart` (line 937)
- **Impact:** Credential leakage via logs and proxy caches.
- **Fix approach:** Send API key as first WebSocket message.

---
## High
### Giant God File: websocket.ts (4,333 lines)
- **Issue:** `packages/bridge/src/websocket.ts` is 4,333 lines handling WebSocket, auth, 30+ message types, git, files, images, recording, debug, screenshots, push. Very hard to review/test.
- **Files:** `packages/bridge/src/websocket.ts`
- **Fix approach:** Extract handlers into domain modules (e.g., `ws-handlers/git.ts`).
### No Rate Limiting or Connection Limits
- **Issue:** No rate limiting on WebSocket, HTTP, or sessions. No connection/session/message limits.
- **Files:** `packages/bridge/src/websocket.ts`, `packages/bridge/src/index.ts`
- **Fix approach:** Add max connections, sessions, per-client rate limiting.
### CORS Wildcard
- **Issue:** `Access-Control-Allow-Origin: *` on all HTTP endpoints.
- **Files:** `packages/bridge/src/index.ts` (lines 100-103)
- **Fix approach:** Restrict CORS via `BRIDGE_CORS_ORIGINS` env var.
### Claude OAuth Client ID Hardcoded
- **Issue:** OAuth client ID hardcoded in `packages/bridge/src/usage.ts` (line 91).
- **Fix approach:** Make configurable via env var.
### CI Only Tests Flutter
- **Issue:** `.github/workflows/test.yml` has no Bridge tests or TypeScript checks.
- **Fix approach:** Add CI job for `npm run test:bridge` and `npx tsc --noEmit`.
### Credentials in Files
- **Issue:** Firebase and Claude OAuth tokens written to home directory files with 0o600.
- **Files:** `packages/bridge/src/firebase-auth.ts` (line 63), `packages/bridge/src/usage.ts`
- **Fix approach:** Use OS keychain for token storage.

---
## Medium
### Widespread Swallowed Exceptions
- **Issue:** Both Bridge and Flutter discard exceptions. Bridge: `debug-trace-store.ts`, `recording-store.ts`, `websocket.ts` (line 3159), `codex-process.ts` (line 984). Flutter: 28+ instances.
- **Impact:** Silent failures. Data loss without indication.
- **Fix approach:** Log all caught exceptions.
### No WebSocket Ping/Pong Heartbeat
- **Issue:** Neither side implements ping/pong. `ws` supports it but not configured.
- **Files:** `packages/bridge/src/websocket.ts`, `apps/mobile/lib/services/bridge_service.dart` (line 1045)
- **Impact:** Half-open connections. iOS kills background WebSocket.
- **Fix approach:** Configure periodic `ping()`. Implement `onPong` handlers.
### Legacy Permission Mode Conversion
- **Issue:** 10+ instances of legacy conversion across `websocket.ts` and `chat_session_cubit.dart`.
- **Files:** `packages/bridge/src/websocket.ts` (lines 598-2169), `apps/mobile/lib/features/chat_session/state/chat_session_cubit.dart` (lines 595-777)
- **Fix approach:** Version negotiation. Single boundary layer.
### Large Files Without Tests
- **Issue:** `websocket.ts` (4,333 lines) and `sessions-index.ts` (2,207 lines) have incomplete coverage.
- **Fix approach:** Branch-level coverage for each handler case.
### shared_preferences API Key Fallback
- **Issue:** `autoConnect` falls back to plaintext `SharedPreferences`. Crash leaves key exposed.
- **Files:** `apps/mobile/lib/services/bridge_service.dart` (lines 925-944)
- **Fix approach:** One-time migration on startup.
### No Structured Logging (207 console calls)
- **Issue:** Raw console calls in Bridge (207 occurrences, 22 files). No levels or aggregation.
- **Fix approach:** Introduce `pino` or custom logger.

---
## Low
### Dependency Override for irondash_engine_context
- **Issue:** Third-party fork in `apps/mobile/pubspec.yaml` (lines 84-88).
- **Fix approach:** Track upstream issue (irondash/irondash#77).
### deprecated_member_use Suppressions
- **Issue:** 12 instances in image viewers.
- **Fix approach:** Migrate to replacement API.
### No Database Migration Path
- **Issue:** `DatabaseService._onUpgrade` empty in `apps/mobile/lib/services/database_service.dart` (line 79).
- **Fix approach:** Define migration pattern.
### Codex Spawns with Full process.env
- **Issue:** `codex-process.ts` passes entire env to child (line 358).
- **Fix approach:** Whitelist needed variables.
### No WebSocket Message Size Limit
- **Issue:** No `maxPayload` configured. Default 100MB.
- **Fix approach:** Set 10-20MB limit.
### Temp File Cleanup Silent Failures
- **Issue:** `codex-process.ts` line 984.
- **Fix approach:** Log failures. Use dedicated temp dir.
### Health Endpoint No Auth
- **Issue:** `/health`, `/version` unauthenticated in `packages/bridge/src/index.ts`.
- **Fix approach:** Apply API key auth to HTTP endpoints.
### No Graceful Shutdown
- **Issue:** `index.ts` shutdown does not notify clients.
- **Fix approach:** Send shutdown message. Wait with timeout.

---
## Cross-Cutting: Graceful Degradation
Version mismatch handling is well-designed:
- Bridge returns `errorCode: unsupported_message` with original type (`websocket.ts` line 532)
- App handles via `_unsupportedActions` map in `chat_message_handler.dart` (line 103)
- Default: `suppress`, user-facing: `showUpdateHint`
**Remaining concern:** No version negotiation on connect. Map must be manually maintained.
**Recommendation:** Use `_bridgeVersion` to gate features proactively.
---
## Platform-Specific Concerns
### iOS Background WebSocket Termination
- iOS kills WebSocket in background. `ensureConnected()` handles resume but no push-triggered reconnect.
### macOS Keychain Dependency for OAuth
- `BRIDGE_ENABLE_USAGE` only fully works on macOS (Keychain fallback in `usage.ts`).
### Flutter Web Platform Limitations
- `DatabaseService` returns null on web. `sqflite` not supported.
- `FlutterSecureStorage` varies by platform.
---
## Summary by Severity
| Severity | Count | Key Themes |
|----------|-------|------------|
| Critical | 3 | Hardcoded API key, no TLS, API key in URL |
| High | 6 | God file, no rate limiting, CORS wildcard, CI gaps, credential files, hardcoded OAuth client |
| Medium | 7 | Swallowed exceptions, no heartbeat, legacy compat, logging, test gaps, shared_prefs fallback |
| Low | 8 | Dependency forks, deprecation suppressions, env leakage, no shutdown cleanup |
---
*Concerns audit: 2026-04-02*
