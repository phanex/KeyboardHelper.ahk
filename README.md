# AHK Keyboard Helper v2.0.0

A compact, high-performance AutoHotkey v2 script combining:
- macOS-style Layout Switcher (toggles between last two active layouts)
- CapsLock Reset & Long-press (tap = switch to English, hold = native CapsLock toggle)
- Plain Text Paste (Win+V)
- Screen Color Picker (Win+Alt+C)

## Key Features

### 1. **macOS-Style Layout Switcher**
Toggle between your two most recently used keyboard layouts with a quick tap of a single key (e.g. `LCtrl`).
- **Context Aware:** Tracks active layout per-window, fully compatible with consoles (PowerShell, Command Prompt, Far Manager) via IME window resolution.
- **Smart Tap Detection:** Distinguishes between a quick tap (for layout switching) and long-press / modifiers (holding `Ctrl`).

### 2. **CapsLock Reset & Long-Press**
- **Short Tap:** Immediately and unconditionally resets your keyboard layout to primary (`en-US`). Never guess which language is active when typing code, passwords, or shell commands.
- **Long Press (>350ms):** Toggles real `CapsLock` (uppercase mode). Prevents accidental CapsLock activation during fast typing.

### 3. **Plain Text Paste**
Strip all formatting when pasting from the clipboard.
- **Hotkey:** `Win+V` by default.
- **Clean:** Preserves original clipboard content after paste.

### 4. **Screen Color Picker**
Inspect any pixel on screen and grab its hex color code.
- **Hotkey:** `Win+Alt+C` copies `#RRGGBB` directly to clipboard and shows a brief 1-second tooltip.

## Installation & Setup

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/).
2. Run `KeyboardHelper.ahk` (or place a shortcut in your Startup folder `shell:startup`).

## License

MIT License. See [LICENSE](LICENSE) for details.
