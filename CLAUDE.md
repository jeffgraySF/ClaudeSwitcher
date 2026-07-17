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
- **Sandbox status is contradictory** — build settings say `ENABLE_APP_SANDBOX = NO`, but `Claude Switcher.entitlements` sets `com.apple.security.app-sandbox = true`, and the entitlement wins, so the installed app actually runs **sandboxed** (see the UserDefaults section for the consequence — prefs live in a container). If you want it truly unsandboxed, the entitlements file must also be changed, not just the build setting. `NSWorkspace.open` on temp `.command` files still works under the current entitlements.
- `LSUIElement = YES` is set via `INFOPLIST_KEY_LSUIElement` in build settings (not a separate Info.plist file).
- `ProfileManager` uses `@Observable` + `@Environment` (Swift/SwiftUI modern observation). Do not revert to `ObservableObject`/`@Published` — it breaks under `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.
- The project targets macOS 26 SDK (Xcode 26) but deploys to macOS 14.0.

## UserDefaults — where profiles ACTUALLY live

**Edit profiles only through the app's Settings window.** Do NOT try to edit them with `defaults`/`plutil` from the command line — it does not work and wastes a lot of time. Here's why, because it's counterintuitive:

The **installed app runs sandboxed**, so its UserDefaults are redirected into a sandbox container. The real, live file the app reads and writes is:

```
~/Library/Containers/jeff.Claude-Switcher/Data/Library/Preferences/jeff.Claude-Switcher.plist
```

Two things make this non-obvious, and both are stated wrong elsewhere in older notes:

1. **The runtime domain is `jeff.Claude-Switcher`** (Xcode's auto-generated identifier), NOT `com.claudeswitcher.ClaudeSwitcher` — even though that's the `PRODUCT_BUNDLE_IDENTIFIER`/`CFBundleIdentifier` in the current source. The installed binary predates that bundle-id change, so its container and defaults domain are still the old auto-generated name.
2. **The app is sandboxed**, despite `ENABLE_APP_SANDBOX = NO` in build settings. The explicit `Claude Switcher.entitlements` file sets `com.apple.security.app-sandbox = true`, and that entitlement wins — hence the container.

`defaults read/write jeff.Claude-Switcher` from a normal shell hits the **non-container** `~/Library/Preferences/jeff.Claude-Switcher.plist` (and cfprefsd's non-container cache), which the sandboxed app never reads. So external edits and the app look at different files and can never agree — no amount of `killall cfprefsd` bridges it. To inspect (read-only) the real value, read the container plist path above directly with `plutil`.

If you rebuild+reinstall from current source, the new binary may switch to the `com.claudeswitcher.ClaudeSwitcher` domain and/or unsandboxed prefs, in which case profiles will appear reset — just re-enter them in Settings.

## Temp file launch mechanism

`launchClaude` writes a shell script to `/tmp/[ProfileName].command`, marks it executable, and opens it with `NSWorkspace`. Terminal auto-opens `.command` files. The file is not cleaned up (it's tiny and in `/tmp`). The tab title shows the profile name as the filename.
