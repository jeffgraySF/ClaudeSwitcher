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

When you pick a profile, ClaudeSwitcher asks which project folder to open, then launches a Terminal window running:

```bash
cd ~/your-project
export CLAUDE_CONFIG_DIR=~/.claude-work
claude
```

**This app never reads, writes, or touches your credential files.**

## Security

Most account-switcher tools for Claude Code work by reading OAuth tokens out of the macOS Keychain and swapping them. ClaudeSwitcher takes a different approach:

- ✅ No Keychain access
- ✅ No credential reading or swapping
- ✅ Credentials stay isolated in their own folders
- ✅ ~150 lines of Swift — audit it in a few minutes
- ✅ Stores only profile names and folder paths in `UserDefaults`

The tradeoff: no usage stats dashboard. That's the feature that requires token access, and it's the one we skip.

**Build from source.** There are no signed binaries. Review the code before running it.

## Requirements

- macOS 14.0+
- Xcode 15+
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) installed

## Installation

```bash
git clone https://github.com/yourusername/ClaudeSwitcher.git
cd ClaudeSwitcher
make run
```

Or open `Claude Switcher/Claude Switcher.xcodeproj` in Xcode and hit ⌘R.

> **Note for forks:** update `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode target's build settings to use your own reverse-domain identifier.

## First-time setup

Log into each account once from Terminal before switching profiles:

```bash
CLAUDE_CONFIG_DIR=~/.claude-personal claude   # log in, then /exit
CLAUDE_CONFIG_DIR=~/.claude-work claude       # log in, then /exit
```

## Usage

- **Switch accounts** — click the menu bar icon, pick a profile, choose a project folder. A new Terminal window opens in that folder with the account active and `claude` running.
- **Edit profiles** — menu bar icon → **Settings…** to rename, change emojis, or update config dirs.
- **Add/remove** — `+` button in Settings, or swipe left on a row to delete.
- **Emoji picker** — click the emoji field in Settings to open the macOS character palette.

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
- Keyboard shortcut to cycle profiles
- Import/export profiles as JSON

## License

MIT — see [LICENSE](LICENSE).
