# AHK Productivity Pack v1.0.0

A single AutoHotkey v2.0 script that combines three powerful productivity tools for Windows 10/11.

- **Layout Switcher**: Toggle between two keyboard layouts using a single key.
- **Plain Text Paste**: Paste clipboard content without any formatting.
- **Input Diary**: Log all typed text to recover lost work after a crash.

## Features

### 1. Layout Switcher

Tired of `Alt+Shift`? Switch between your primary and secondary keyboard layouts (e.g., English and German) by simply tapping a single key of your choice (like `LCtrl` or `CapsLock`).

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

> **‼️ ВАЖНОЕ ПРЕДУПРЕЖДЕНИЕ О БЕЗОПАСНОСТИ ‼️**
>
> Функция "Дневник ввода" записывает **ВСЕ** вводимые символы, включая **пароли** и другую конфиденциальную информацию.
>
> Перед вводом таких данных, вы обязаны:
> - **Отключить функцию:** Установить `global ENABLE_INPUT_DIARY := false` в конфигурации скрипта.
> - **Приостановить скрипт:** Через иконку в системном трее (правый клик -> "Pause Script").
> - **Полностью закрыть скрипт:** Через ту же иконку.

## Installation

1.  **Install AutoHotkey**: Download and install [AutoHotkey v2.0](https://www.autohotkey.com/).
2.  **Download the Script**: Place the `AutoHotkey.ahk` file in a folder of your choice.
3.  **Run the Script**: Double-click the `AutoHotkey.ahk` file to run it. An icon will appear in your system tray.

To have the script run automatically on startup, place a shortcut to it in your Windows Startup folder (`Shell:startup`).

## Configuration

All settings can be changed by editing the constants at the top of the `AutoHotkey.ahk` script file.

```ahk
; === CONFIGURATION ===

; --- Feature Toggles ---
global ENABLE_LAYOUT_SWITCHER := true ; Set to false to disable the Layout Switcher
global ENABLE_PLAIN_PASTE := true     ; Set to false to disable Plain Text Paste
global ENABLE_INPUT_DIARY := true     ; Set to false to disable the Input Diary

; --- Layout Switcher ---
global LAYOUT_PRI := "en-US"          ; Primary layout (e.g., English)
global LAYOUT_SEC := "de-DE"          ; Secondary layout (e.g., German)
global LAYOUT_SWITCH_KEY := "LCtrl"   ; Key to tap for layout switching. LCtrl, RCtrl, CapsLock supported.

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
