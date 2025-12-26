# AHK Keyboard Helper

A compact AutoHotkey script designed to enhance your typing experience with a powerful layout switcher, plain-text pasting, and an essential input diary.

## Key Features

### 1. **Layout Switcher**
Effortlessly toggle between your primary and secondary keyboard layouts with a quick tap of a single key (e.g., `LCtrl`).
-   **Intelligent Switching:** Adapts the layout for the active window only, preserving settings elsewhere.
-   **Console Compatible:** Works reliably across all applications, including console windows like PowerShell.
-   **Smart Tap Detection:** Distinguishes between a quick tap (for switching) and a long press (to use as a modifier like `Ctrl`).

### 2. **Plain Text Paste**
Strip all formatting when pasting. Copy from anywhere, paste as clean text.
-   **Hotkey:** Uses `Win+V` by default.
-   **Non-intrusive:** Your original formatted content is restored to the clipboard immediately after pasting.

### 3. **Input Diary**
A continuous backup of everything you type, ensuring you never lose work to crashes or accidental closures.
-   **Automatic:** Logs keystrokes silently in the background.
-   **Easy Recovery:** Access `diary.txt` or `diary.last.txt` to retrieve lost text.

### ⚠️ **Privacy Notice (Input Diary)**
The Input Diary records **ALL** keystrokes, including **passwords** and sensitive information.
To prevent logging sensitive data, you must **disable**, **pause**, or **exit** the script before entering such information.

## Get Started

1.  **Install AutoHotkey:** Download and install [AutoHotkey v2.0](https://www.autohotkey.com/).
2.  **Download Script:** Place `KeyboardHelper.ahk` in a folder.
3.  **Run:** Double-click `KeyboardHelper.ahk`. An icon will appear in your system tray.

*Tip: For auto-start, place a shortcut in your Windows Startup folder (`Shell:startup`).*

## Customize

Edit settings directly in `KeyboardHelper.ahk` by modifying constants at the top of the file.

```ahk
; --- Feature Toggles ---
global ENABLE_LAYOUT_SWITCHER := true
global ENABLE_PLAIN_PASTE := true
global ENABLE_INPUT_DIARY := true

; --- Layout Switcher ---
global LAYOUT_PRI := "en-US"          ; Primary layout (e.g., English)
global LAYOUT_SEC := "uk-UA"          ; Secondary layout (e.g., Ukrainian)
global LAYOUT_SWITCH_KEY := "LCtrl"   ; Key to tap (e.g., LCtrl, CapsLock)

; --- Plain Text Paste ---
global PLAIN_PASTE_KEY := "#v"        ; Hotkey (Win+V)

; --- Input Diary ---
global DIARY_CLEAR_ON_START := true   ; Move old diary to backup on startup
```
*Find your layout's locale name (e.g., "en-US") with: `dism /online /get-intl` in PowerShell.*

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.