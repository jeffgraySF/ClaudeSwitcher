# ClaudeSwitcher

A minimal macOS menu bar app for switching between multiple [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) accounts with a single click.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Why

Claude Code doesn't yet support multiple accounts natively. The common workaround — logging out and back in — loses your session context every time. ClaudeSwitcher keeps each account in its own isolated config directory and opens a new Terminal window pointed at the right one, so you're never a `/logout` away from losing your place.

## How it works

Each profile maps to a separate `CLAUDE_CONFIG_DIR` folder:

```
~/.claude-personal/   ← personal account credentials live here
~/.claude-work/       ← work account credentials live here
~/.claude-freelance/  ← freelance account credentials live here
```

When you switch profiles, ClaudeSwitcher opens a new Terminal window with:

```bash
CLAUDE_CONFIG_DIR=~/.claude-work claude
```

That's the entire mechanism. **This app never reads, writes, or touches your credential files.**

## Security

Most account-switcher tools for Claude Code work by reading OAuth tokens out of the macOS Keychain and swapping them. ClaudeSwitcher takes a different approach:

- ✅ No Keychain access
- ✅ No credential reading or swapping
- ✅ Credentials stay isolated in their own folders
- ✅ ~120 lines of Swift — audit it in a few minutes
- ✅ Stores only profile names and folder paths in `UserDefaults`

The tradeoff: no usage stats dashboard. That's the feature that requires token access, and it's the one we skip.

## Requirements

- macOS 14.0+
- Xcode 15+
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed

## Installation

### Build from source

```bash
git clone https://github.com/yourusername/ClaudeSwitcher.git
```

- Open Xcode → File → New → Project → **macOS → App**
- Product Name: `ClaudeSwitcher`, Interface: **SwiftUI**, Language: **Swift**, Deployment: **macOS 14.0**
- Delete the generated `ContentView.swift` and add all `.swift` files from this repo
- In `Info.plist`, add `LSUIElement = YES` to hide the dock icon
- Build and run (⌘R)

## First-time setup

Log into each account once from Terminal before switching profiles:

```bash
CLAUDE_CONFIG_DIR=~/.claude-personal claude   # log in, then /exit
CLAUDE_CONFIG_DIR=~/.claude-work claude       # log in, then /exit
```

You'll also see a one-time macOS prompt asking if ClaudeSwitcher can control Terminal. Click **Allow**.

## Usage

- **Switch accounts** — click the menu bar icon, pick a profile. A new Terminal window opens with that account active.
- **Active account** — the menu bar icon shows the emoji of the currently active profile.
- **Edit profiles** — menu bar icon → **Settings…** to rename, change emojis, or update config dirs.
- **Add/remove** — `+` button in Settings, or swipe left on a row to delete.

## Project structure

```
ClaudeSwitcherApp.swift   — app entry point, MenuBarExtra + Settings scenes
ProfileManager.swift      — profile model, persistence, Terminal launch logic
MenuBarMenuView.swift     — menu bar dropdown
SettingsView.swift        — settings window
```

## Contributing

PRs welcome. Some ideas:

- iTerm2 support
- Menu bar label showing the active profile name
- Keyboard shortcut to cycle profiles
- Import/export profiles as JSON

## License

MIT — see [LICENSE](LICENSE).
