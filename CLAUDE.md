# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

ClaudeSwitcher is a macOS menu bar app (~120 lines of Swift) that lets users switch between multiple Claude Code accounts by launching a new Terminal window with `CLAUDE_CONFIG_DIR` set to the appropriate profile folder. It never touches credential files or the Keychain.

## Building

Open `Claude Switcher/Claude Switcher.xcodeproj` in Xcode and build with ⌘R. There is no command-line build script — this is an Xcode-only project.

Minimum deployment target: macOS 14.0. Requires Xcode 15+.

The app requires Automation permission (to control Terminal via AppleScript) — macOS will prompt on first launch.

## Architecture

Four Swift files, no third-party dependencies:

- **`ClaudeSwitcherApp.swift`** — `@main` entry point. Creates `ProfileManager` as a `@StateObject` and passes it as an `environmentObject` to both scenes: `MenuBarExtra` (the menu) and `Settings` (the settings window). The menu bar icon label displays the active profile's emoji.
- **`ProfileManager.swift`** — `ObservableObject` holding the `[Profile]` array. Persists to `UserDefaults` as JSON on every mutation. `launchClaude(for:)` runs an AppleScript to open a new Terminal window with `CLAUDE_CONFIG_DIR` set; it also creates the config directory if missing.
- **`MenuBarMenuView.swift`** — Dropdown menu using a `Picker` with `.inline` style for native checkmarks. Selecting a profile updates `activeProfileID` and calls `launchClaude`.
- **`SettingsView.swift`** — List of editable profile rows (emoji, name, configDir). Add via `+` button; delete by swiping left (`.onDelete`).

The `Profile` struct is `Codable` + `Hashable` with a stable `UUID` id. There are no async operations, no networking, and no framework dependencies beyond SwiftUI and AppKit.

## Key constraints

- **No Keychain access** — this is a deliberate security boundary. Do not add any code that reads macOS Keychain entries.
- **No credential file access** — `launchClaude` only creates the directory, never reads its contents.
- The app uses `LSUIElement = YES` (set in Info.plist) to suppress the Dock icon.
- `ProfileManager` is injected via `.environmentObject` — both views depend on it being in the environment, not passed directly.

## File layout note

There are loose `.swift` files in the repo root (`ProfileManager.swift`, `MenuBarMenuView.swift`, `SettingsView.swift`) that mirror the files inside `Claude Switcher/`. The canonical source is inside the `Claude Switcher/` directory used by the Xcode project. The root-level files appear to be drafts or copies.
