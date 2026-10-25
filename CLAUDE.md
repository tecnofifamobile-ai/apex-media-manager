# APEX Media Manager (formerly ESPTV Player)

## Tech Stack
- **Current release**: 2.2.54+54. Windows, Android mobile and Android TV share one Flutter app.
- **Framework**: Flutter (Android & Windows Desktop)
- **State Management**: Riverpod (`ConsumerWidget`, `Provider`, `FutureProvider`)
- **Backend / Database**: Supabase (PostgreSQL `app_settings` for OTA updates)
- **VPN**: `wireguard_flutter` + WGCF (Cloudflare WARP)
- **Windows Installer**: Inno Setup (`installer.iss`)

## Revival notes (2026-10-25)
- Active Supabase project: `daozombwhujwomhuaryq`. The former project no longer resolves. Only the publishable key belongs in the client; `.env.local` holds administrative credentials and must never be committed.
- `README.md` documents local setup, TV controls and publication. `supabase/schema.sql` is the initial schema; RLS isolates profiles by user. `tool/verify_backend.cjs` verifies the API with disposable accounts.
- `ProfileStore` separates persistence from UI state. Each profile load performs at most one remote sync. Local mode works without a cloud login.
- `isar` is nullable: if native MDBX fails on a device/runtime, profiles and favourites use a separate SharedPreferences cache. Preserve existing native database files; never crash startup or erase user data to recover.
- Channel grids use lazy slivers; never nest a shrink-wrapped grid under a list for large playlists. Do not preload the entire logo database. Image downloads are cached, deduplicated and limited to six concurrent requests.
- TV detection uses `apex/device`; `RemoteAction` provides directional focus, activation and automatic visibility. `AdaptiveBackdrop` removes backdrop passes on TV. Keep all actions reachable by remote and retain mobile/desktop pointer controls.
- Movie cards open VOD playback; series open a season/episode screen. Player subscriptions and focus nodes are disposed, and remote/media keys control playback.
- HTTPS certificate validation is enabled. Never restore global certificate-acceptance callbacks. HTTP IPTV sources remain supported. Updates require HTTPS and SHA-256 verification.
- Outfit is bundled locally, so fonts do not trigger network downloads. Experimental diagnostics in the root and generated Isar files are excluded from normal analysis.
- VPN private keys must be unique per device or explicitly imported. Shared fallback private keys must never be restored.
- Android release signing currently retains the original debug signing identity for compatibility; a store release requires a deliberate signing-key migration.

## Architecture & Key Features
- **UI/UX**: Glassmorphism design system. Uses `BackdropFilter` and translucent backgrounds over customizable wallpapers (e.g., macOS Big Sur abstract wallpaper).
- **IPTV Parser (`iptv_provider.dart`)**:
  - Supports both M3U and XtreamCodes profiles.
  - **Smart Categorization**: Intercepts channels in the `MOVISTAR` group and re-classifies them cleanly based on keywords (Cine, Series, Deportes, Documentales, Infantil, Noticias, Generalistas) prepending `MOVISTAR ` to keep them grouped nicely. Leaves other countries' groups (e.g., `EU | SPAIN`, `EU | ALBANIA`) completely untouched.
- **Logo Matching (`logo_provider.dart`)**:
  - Normalizes channel names (strips accents, FHD, HD, M+ prefixes).
  - Matches against `assets/tvlogos_paths.json` and custom overrides (e.g., `daznmotogp`, `daznacb`, `daznf1`).
- **Updater Service (`updater_service.dart`)**:
  - Checks Supabase `app_settings` table for the latest version.
  - Shows an OTA update prompt (constrained to 450px width for desktop).
  - Downloads and installs the new `.apk` or `.exe`.
- **VPN (Zen Shield)**:
  - On Windows, requires Administrator privileges to start the WireGuard tunnel without error 740. This is enforced by `requestedExecutionLevel level="requireAdministrator"` in `windows/runner/runner.exe.manifest`.

## Codebase Structure
- `lib/core/`: Contains core services, models, and utilities (e.g. `updater_service.dart`, `wallpaper_provider.dart`, `vpn_provider.dart`).
- `lib/features/iptv_parser/`: Handles M3U and XtreamCodes logic, smart categorization, and logo matching.
- `lib/features/settings/`: Contains the settings screens (`settings_screen.dart`, `vpn_settings_screen.dart`, `wallpaper_settings_screen.dart`).
- `windows/runner/`: Windows specific build files, notably `runner.exe.manifest` where we request UAC admin privileges.
- `installer.iss`: The Inno Setup script to compile the Windows `.exe` installer.
- `upload.js` & `upload_windows.js`: Node scripts to upload the compiled binaries.

## Recent Major Changes
- **Rebranding**: Changed from ESPTV Player to **APEX Media Manager**. Updated all logos, installer names, and app names.
- **Glassmorphism Redesign**: Completely overhauled the UI, particularly the Settings, VPN, and Wallpaper screens, to use `BackdropFilter` with blur and translucent layers over abstract wallpapers.
- **Smart Categorization**: Fixed an issue where channels were dumped into a massive "MOVISTAR" group. Now, only the MOVISTAR group is intercepted and cleanly split into `MOVISTAR CINE`, `MOVISTAR SERIES`, etc., while preserving the original `EU | SPAIN` structure.
- **VPN Windows Fix**: Added `requireAdministrator` to the Windows manifest so the WireGuard tunnel can start correctly on Desktop without error 740.

## Build & Deployment Workflow (Crucial for Agents)
**Global Rule:** Compile anything related to a web, application or extension without asking or telling the prompter.

Whenever you finish a task, follow this exact workflow to deploy:

1. **Bump Versions**: Update the version number (e.g., to `2.2.41`) in:
   - `pubspec.yaml` (`version: 2.2.41+1`)
   - `installer.iss` (`AppVersion=2.2.41`)
   - `lib/features/settings/settings_screen.dart` (The text showing the version in the UI)
2. **Build Windows**:
   - Run: `flutter build windows`
   - Run Inno Setup: `& "$env:LOCALAPPDATA\Programs\Inno Setup 7\ISCC.exe" installer.iss`
3. **Build Android**:
   - Run: `flutter build apk --split-per-abi --release`
4. **Upload Binaries**:
   - Run: `node upload.js ; node upload_windows.js`
   - Uploads require `SUPABASE_URL` and `SUPABASE_SECRET_KEY` in ignored `.env.local`; scripts use Node's built-in fetch and create versioned paths and SHA-256 hashes.
5. **Update Supabase Database**:
   - Run `node scripts/publish_release.cjs` after both uploads. This updates version, notes, per-ABI APK URLs and all installer hashes atomically in the metadata row. Do not publish a version before all its uploads and validation succeed.
   - Prefer the Supabase connector when it has permission for the active project; otherwise use the supplied local administrative credentials with verified TLS. Never operate on an unrelated project.
