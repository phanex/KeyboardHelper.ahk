# AHK Keyboard Helper

A compact AutoHotkey script for keyboard power-users, combining a layout switcher, text diary, and plain-text pasting.

- **Layout Switcher**: Toggle between two keyboard layouts using a single key.
- **Plain Text Paste**: Paste clipboard content without any formatting.
- **Input Diary**: Log all typed text to recover lost work after a crash.

## Features

### 1. Layout Switcher

Tired of `Alt+Shift`? This script allows you to quickly toggle between your primary keyboard layout (e.g., English) and the last-used secondary layout (e.g., German, Ukrainian) by simply tapping a single key of your choice (like `LCtrl` or `CapsLock`). You can still access other installed keyboard layouts through standard Windows methods (e.g., `Win+Space`, `Alt+Shift`, mouse selection).

- **Fast & Reliable**: Uses an event-driven `InputHook` for minimal system load and high reliability.
- **Per-Window Switching**: Intelligently switches the layout for the active window only, preserving your layout settings in other applications.
- **Modifier Aware**: Holding the key down allows it to function as a normal modifier (e.g., for `Ctrl+C`), while a quick tap triggers the layout switch.

### 2. Plain Text Paste

Strips all formatting (fonts, colors, links) from your clipboard content. Just copy from anywhere and paste as clean, plain text.

- **Seamless Integration**: Uses the familiar `Win+V` hotkey by default.
- **Preserves Clipboard History**: Your original, formatted clipboard content is restored immediately after pasting, so it doesn't interfere with Windows' native clipboard history.

### 3. Input Diary

A safety net for your typing. This feature logs all keyboard input to a text file, ensuring you can recover text from a closed note, a browser crash, or an unexpected system shutdown.

- **Automatic & Lightweight**: Captures keystrokes in the background and saves them periodically.
- **Simple Recovery**: On startup, the previous session's log is saved to `diary.last.txt`, so your most recent work is always backed up.

### ⚠️ Privacy Notice

The Input Diary is designed to log only printable characters and ignores most hotkey combinations.

> **‼️ IMPORTANT SECURITY WARNING ‼️**
>
> The Input Diary feature records **ALL** keystrokes, including **passwords** and other sensitive information.
>
> To prevent logging sensitive information, you must **either** disable the feature, pause the script, **or** exit it entirely before entering such data:
> - **Disable the feature:** Set `global ENABLE_INPUT_DIARY := false` in the script's configuration.
> - **Pause the script:** Right-click the AutoHotkey icon in the system tray and select "Pause Script".
> - **Exit the script:** Close the script entirely via the same tray icon.

## Installation

1.  **Install AutoHotkey**: Download and install [AutoHotkey v2.0](https://www.autohotkey.com/).
2.  **Download the Script**: Place the `KeyboardHelper.ahk` file in a folder of your choice.
3.  **Run the Script**: Double-click the `KeyboardHelper.ahk` file to run it. An icon will appear in your system tray.

For convenience or to have the script run automatically on Windows startup, you can place a shortcut to it in your Startup folder (`Shell:startup`). For some AutoHotkey setups, renaming the script to `AutoHotkey.ahk` and placing it in your Documents folder may also enable auto-run.

## Configuration

All settings can be changed by editing the constants at the top of the `KeyboardHelper.ahk` script file.

```ahk
; === CONFIGURATION ===

; --- Feature Toggles ---
global ENABLE_LAYOUT_SWITCHER := true ; Set to false to disable the Layout Switcher
global ENABLE_PLAIN_PASTE := true     ; Set to false to disable Plain Text Paste
global ENABLE_INPUT_DIARY := true     ; Set to false to disable the Input Diary

; --- Layout Switcher ---
global LAYOUT_PRI := "en-US"          ; Primary layout (e.g., English)
global LAYOUT_SEC := "de-DE"          ; Secondary layout (e.g., German)
global LAYOUT_SWITCH_KEY := "LCtrl"   ; Key to tap for layout switching. Supported: LCtrl, RCtrl, LShift, RShift, CapsLock, LAlt, RAlt, AppsKey, etc.

; --- Plain Text Paste ---
global PLAIN_PASTE_KEY := "#v"        ; Hotkey for plain text paste (Win+V)

; --- Input Diary ---
global DIARY_CLEAR_ON_START := true   ; Move old diary to backup on startup
; =====================
```

To find your keyboard layout's locale name (e.g., `"en-US"`), you can run the following command in PowerShell: `dism /online /get-intl`

## Usage

- **Switch Layout**: Tap the `LAYOUT_SWITCH_KEY` (e.g., `LCtrl`) in any application.
- **Paste Plain Text**: Press `PLAIN_PASTE_KEY` (`Win+V`) to paste clipboard content without formatting.
- **Recover Text**: If you lose text, open `diary.txt` or `diary.last.txt` in the script's directory to find your logged keystrokes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
