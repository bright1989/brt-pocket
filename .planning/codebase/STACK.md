# Technology Stack

**Analysis Date:** 2026-04-02

## Languages

**Primary:**
- TypeScript 5.7+ -- Bridge Server (`packages/bridge/src/`), Firebase Cloud Functions (`functions/src/`)
- Dart (SDK ^3.11.0) -- Flutter Mobile App (`apps/mobile/lib/`)

**Secondary:**
- Kotlin -- Android native configuration (`apps/mobile/android/app/build.gradle.kts`)
- Swift/Objective-C -- iOS/macOS native layers (platform plugins, CocoaPods)
- YAML -- CI workflows (`.github/workflows/`), Flutter config (`pubspec.yaml`)

## Runtime

**Node.js:**
- Version: 22 (specified in `.mise.toml`, `packages/bridge/package.json` engines, `functions/package.json` engines)
- Current system: v22.22.2
- Module system: ESM (type: module in both bridge and functions)

**Dart/Flutter:**
- Dart SDK: ^3.11.0
- Flutter: 3.41.5 (specified in `.mise.toml`)
- Package Manager: pub (Flutter built-in)

**Package Managers:**
- npm workspaces (monorepo root `package.json` manages `packages/*`)
- Lockfile: `package-lock.json` present at root
- pub: `pubspec.lock` at `apps/mobile/pubspec.lock`)

## Frameworks

**Core - Bridge Server:**
- ws ^8.18.0 -- WebSocket server
- @anthropic-ai/claude-agent-sdk ^0.2.74 -- Claude Code CLI integration via SDK
- Node.js native `http` module -- HTTP server for health/version/usage endpoints

**Core - Flutter Mobile App:**
- flutter_bloc ^9.1.0 -- State management (Cubit pattern)
- flutter_hooks ^0.21.3+1 -- React-like hooks for widgets
- auto_route ^11.1.0 -- Declarative routing with code generation
- freezed_annotation ^3.1.0 -- Immutable union types and data classes
- json_annotation ^4.9.0 -- JSON serialization

**Core - Firebase Cloud Functions:**
- firebase-functions ^6.6.0 -- Cloud Functions v2 (HTTPS trigger)
- firebase-admin ^13.6.0 -- Admin SDK (Auth, Firestore, Messaging)

## Testing

**Bridge Server:**
- Vitest ^4.0.18 -- Test runner and assertion library
- @vitest/coverage-v8 ^4.0.18 -- Code coverage via V8
- Config: `packages/bridge/vitest.config.ts` (node environment, `src/**/*.test.ts`)

**Flutter Mobile App:**
- flutter_test -- Built-in Flutter widget/unit testing
- bloc_test ^10.0.0 -- BLoC/Cubit state testing
- patrol_finders ^3.1.0 -- UI integration testing (Patrol)
- flutter_driver -- Deprecated driver testing (still listed as dev dep)

## Build Tools and Dev Dependencies

**Bridge Server:**
- tsx ^4.19.0 -- TypeScript execution in development
- typescript ^5.7.0 -- Compiler (`tsc` for builds)
- Target: ES2022, module: NodeNext, moduleResolution: NodeNext
- Strict mode enabled

**Flutter Mobile App:**
- build_runner ^2.5.4 -- Code generation (Freezed, json_serializable, auto_route)
- freezed ^3.1.0 -- Code generator for immutable classes
- json_serializable ^6.9.5 -- JSON serialization code generator
- auto_route_generator ^10.4.0 -- Route code generator
- flutter_launcher_icons ^0.13.1 -- App icon generation
- flutter_lints ^6.0.0 -- Recommended lint rules

## Key Dependencies

### Bridge Server - Production

| Package | Version | Purpose |
|---------|---------|---------|
| @anthropic-ai/claude-agent-sdk | ^0.2.74 | Claude Code CLI process management |
| ws | ^8.18.0 | WebSocket server |
| bonjour-service | ^1.3.0 | mDNS advertisement (local network discovery) |
| qrcode | ^1.5.4 | QR code generation for connection URL |
| socks | ^2.8.7 | SOCKS4/SOCKS5 proxy support |
| undici | ^7.24.4 | HTTP proxy agent for global fetch |

### Bridge Server - Development

| Package | Version | Purpose |
|---------|---------|---------|
| @types/node | ^22.0.0 | Node.js type definitions |
| @types/qrcode | ^1.5.6 | QR code type definitions |
| @types/ws | ^8.5.0 | WebSocket type definitions |

### Flutter Mobile App - Production (key packages)

| Package | Version | Purpose |
|---------|---------|---------|
| web_socket_channel | ^3.0.3 | WebSocket client for Bridge communication |
| shared_preferences | ^2.5.0 | Local key-value persistence |
| sqflite | ^2.4.2 | Local SQLite database (prompt history) |
| flutter_local_notifications | ^20.0.0 | Local push notification display |
| firebase_core | ^4.4.0 | Firebase initialization |
| firebase_messaging | ^16.1.1 | FCM push notification handling |
| bonsoir | ^6.0.1 | mDNS service discovery (find Bridge on LAN) |
| mobile_scanner | ^7.1.4 | QR code scanning for connection setup |
| speech_to_text | ^7.3.0 | Voice input for messages |
| http | ^1.6.0 | HTTP client (usage checks, GitHub API) |
| flutter_markdown | ^0.7.7+1 | Markdown rendering in chat |
| google_fonts | ^8.0.0 | Custom typography (Space Grotesk, IBM Plex Sans) |
| app_links | ^7.0.0 | Deep link handling (ccpocket://) |
| share_plus | ^12.0.1 | Native share sheet |
| image_picker | ^1.1.2 | Camera/gallery image selection |
| dartssh2 | ^2.10.0 | SSH client for remote Bridge management |
| flutter_secure_storage | ^10.0.0 | Secure credential storage |
| shorebird_code_push | ^2.0.5 | OTA update delivery |
| talker / talker_flutter | ^5.1.13 | Logging framework |
| marionette_flutter | ^0.4.0 | E2E testing framework |
| auto_route | ^11.1.0 | Declarative routing |
| flutter_slidable | ^4.0.3 | Swipeable list actions |
| super_drag_and_drop | ^0.9.1 | Cross-platform drag and drop |
| highlight / syntax_highlight | ^0.7.0 / ^0.5.0 | Code syntax highlighting |
| in_app_review | ^2.0.11 | Native app review prompting |
| extended_image | ^10.0.1 | Advanced image loading/caching |
| skeletonizer | ^2.1.3 | Loading skeleton placeholders |
| collection | ^1.19.1 | Additional collection utilities |
| uuid | ^4.5.1 | UUID generation |
| super_clipboard | ^0.9.1 | Clipboard management |
| smooth_page_indicator | ^2.0.1 | Page indicator widgets |
| scroll_to_index | ^3.0.1 | Scrollable list position management |
| expandable_page_view | ^1.2.1 | PageView with dynamic children |
| flutter_svg | ^2.0.17 | SVG rendering |
| url_launcher | ^6.3.1 | External URL opening |
| package_info_plus | ^9.0.0 | App version/access info |
| flutter_bloc | ^9.1.0 | State management |
| flutter_hooks | ^0.21.3+1 | Widget lifecycle hooks |
| freezed_annotation | ^3.1.0 | Immutable data class annotations |
| json_annotation | ^4.9.0 | JSON serialization annotations |
| cupertino_icons | ^1.0.8 | iOS-style icons |

**Dependency Overrides:**
- `irondash_engine_context` -- Git fork from Sabbar-Engineering for 16KB page alignment (temporary until irondash/irondash#77 merges)

### Firebase Cloud Functions

| Package | Version | Purpose |
|---------|---------|---------|
| firebase-admin | ^13.6.0 | Server-side Firebase (Auth, Firestore, Messaging) |
| firebase-functions | ^6.6.0 | HTTPS Cloud Function v2 |

## Configuration

**Environment Variables (Bridge Server):**

| Variable | Default | Purpose |
|----------|---------|---------|
| BRIDGE_PORT | 8765 | WebSocket port |
| BRIDGE_HOST | 0.0.0.0 | Bind address |
| BRIDGE_API_KEY | (none) | API key authentication |
| BRIDGE_ALLOWED_DIRS | /c/Users/T490 | Allowed project directories |
| BRIDGE_RECORDING | (none) | Session recording |
| BRIDGE_DISABLE_MDNS | (none) | Disable mDNS advertisement |
| DIFF_IMAGE_AUTO_DISPLAY_KB | 1024 | Diff image auto-display threshold |
| DIFF_IMAGE_MAX_SIZE_MB | 5 | Max diff image size |
| BRIDGE_ENABLE_USAGE | (none) | Enable Claude usage fetching |
| HTTPS_PROXY | (none) | HTTP/SOCKS proxy |

**Build Configuration:**
- TypeScript: `packages/bridge/tsconfig.json` (strict, ES2022, NodeNext)
- Vitest: `packages/bridge/vitest.config.ts` (node env, v8 coverage)
- Flutter analysis: `apps/mobile/analysis_options.yaml` (flutter_lints)
- Flutter l10n: `flutter: generate: true` with ARB files in `lib/l10n/`
- Shorebird: `apps/mobile/shorebird.yaml` (auto_update: false)

**Tool Version Management:**
- mise (`.mise.toml`): Node 22, Flutter 3.41.5

## Platform Targets

**iOS:**
- Minimum deployment: iOS 15.0 (`ios/Podfile`)
- Signing: Codemagic CLI Tools + App Store Connect API
- Distribution: TestFlight, App Store (via Shorebird release)
- Bundle ID: com.k9i.ccpocket

**Android:**
- Compile SDK: flutter.compileSdkVersion
- Java: 17 (desugaring enabled)
- Signing: Keystore (`keystore.properties` / `keystore.jks`)
- Distribution: Google Play internal track (draft), Shorebird release
- Package: com.k9i.ccpocket
- Resource configurations: en, ja, zh-rCN

**macOS:**
- Minimum deployment: macOS 11.0 (`macos/Podfile`)
- Signing: Developer ID Application (p12 import, notarized via notarytool)
- Distribution: GitHub Release (DMG), no Shorebird for macOS

**Web:**
- Supported with `kIsWeb` guards in services
- Limitations: No sqflite, no local notifications, no FCM, no speech_to_text, no bonsoir

## Platform Requirements

**Development:**
- Node.js 22+
- Flutter 3.41.5
- Dart SDK ^3.11.0
- mise (recommended for version management)
- npm (for Bridge Server and Cloud Functions)

**Production:**
- Bridge Server: Node.js 18+ (published to npm as `@ccpocket/bridge`)
- Cloud Functions: Node.js 22 (Firebase Gen 2)
- Firebase project: ccpocket-ca33b (Cloud Functions, Firestore, FCM)

---

*Stack analysis: 2026-04-02*
