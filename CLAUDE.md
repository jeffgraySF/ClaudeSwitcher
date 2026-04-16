# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

ClaudeSwitcher is a macOS menu bar app (~150 lines of Swift) that lets users switch between multiple Claude Code accounts. Picking a profile shows a folder picker, then writes a temporary `.command` file and opens it in Terminal — which `cd`s to the chosen folder, exports `CLAUDE_CONFIG_DIR`, and launches `claude`. It never touches credential files or the Keychain.

## Building

```bash
make build   # build only
make run     # build and relaunch
```

Or open `Claude Switcher/Claude Switcher.xcodeproj` in Xcode and hit ⌘R.

Minimum deployment target: macOS 14.0. Requires Xcode 15+. No code signing required for local development.

## Architecture

Four Swift files, no third-party dependencies:

- **`ClaudeSwitcherApp.swift`** — `@main` entry point. Holds `ProfileManager` as `@State` and injects it via `.environment()` into both scenes: `MenuBarExtra` (the menu) and `Settings`. Menu bar icon is a fixed SF Symbol (`arrow.triangle.2.circlepath`), not the active profile emoji.
- **`ProfileManager.swift`** — `@Observable` class holding `[Profile]`. Persists to `UserDefaults` as JSON on every mutation. `launchClaude(for:)` shows `NSOpenPanel`, writes a temp `.command` file to `/tmp`, and opens it with `NSWorkspace`. Also creates the config directory if missing.
- **`MenuBarMenuView.swift`** — Dropdown menu with a title header, inline `Picker` for profile selection (native checkmarks), Settings button via `\.openSettings` environment action, and Quit.
- **`SettingsView.swift`** — List of editable profile rows (emoji, name, configDir). Emoji field opens the macOS character palette on tap. Add via `+`; delete by swiping left.

The `Profile` struct is `Codable` + `Hashable` with a stable `UUID` id.

## Key constraints

- **No Keychain access** — deliberate security boundary. Do not add code that reads macOS Keychain entries.
- **No credential file access** — `launchClaude` only creates the config directory, never reads it.
- **Sandbox is disabled** (`ENABLE_APP_SANDBOX = NO`) — required for `NSWorkspace.open` on temp `.command` files. This is intentional; the app is meant to be built from source.
- `LSUIElement = YES` is set via `INFOPLIST_KEY_LSUIElement` in build settings (not a separate Info.plist file).
- `ProfileManager` uses `@Observable` + `@Environment` (Swift/SwiftUI modern observation). Do not revert to `ObservableObject`/`@Published` — it breaks under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
- The project targets macOS 26 SDK (Xcode 26) but deploys to macOS 14.0.

## UserDefaults

Profiles are stored under bundle ID `com.claudeswitcher.ClaudeSwitcher`. If the bundle ID ever changes, profiles will appear reset. To migrate: copy the `profiles` and `activeProfileID` keys from the old domain to the new one using `defaults export/write`, then run `killall cfprefsd` to flush the preferences cache before relaunching.

## Temp file launch mechanism

`launchClaude` writes a shell script to `/tmp/[ProfileName].command`, marks it executable, and opens it with `NSWorkspace`. Terminal auto-opens `.command` files. The file is not cleaned up (it's tiny and in `/tmp`). The tab title shows the profile name as the filename.
