# APEX Media Manager (formerly ESPTV Player)

## Tech Stack
- **Framework**: Flutter (Android & Windows Desktop)
- **State Management**: Riverpod (`ConsumerWidget`, `Provider`, `FutureProvider`)
- **Backend / Database**: Supabase (PostgreSQL `app_settings` for OTA updates)
- **VPN**: `wireguard_flutter` + WGCF (Cloudflare WARP)
- **Windows Installer**: Inno Setup (`installer.iss`)

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
5. **Update Supabase Database**:
   - Use the Supabase MCP tool (`execute_sql`) to update the database:
     `update app_settings set latest_version = '2.2.41', release_notes = 'Tus notas de parche aquí...';`
