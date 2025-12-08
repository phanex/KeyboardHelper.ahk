# Universal AHK Script v2.1

## Project Overview

A single AutoHotkey v2.0 script combining three productivity tools:
1. **Layout Switcher** - Toggle between two keyboard layouts using a single key (default: LCtrl)
2. **Plain Text Paste** - Paste clipboard content without formatting (Win+V)
3. **Input Diary** - Log all typed text to recover lost content after crashes

**Language:** AutoHotkey v2.0  
**Target OS:** Windows 10/11  
**License:** MIT  
**Status:** Feature-complete, ready for GitHub publication

## Architecture

### Core Principles
- Single file, no external dependencies
- Event-driven (hooks, not timers where possible)
- Minimal system load
- All settings configurable via constants at file top
- Each feature can be independently enabled/disabled

### File Structure
```
script.ahk          # Main script
diary.txt           # Current session log (auto-created)
diary.last.txt      # Previous session backup (auto-created)
README.md           # To be generated
LICENSE             # MIT license
```

## Feature Details

### 1. Layout Switcher
**Purpose:** Quick toggle between primary (usually English) and secondary (e.g., Ukrainian, German, Polish) keyboard layouts.

**Implementation:**
- Uses locale names (e.g., "en-US", "ru-RU") instead of language IDs
- Tap detection with 500ms timeout (holding key = modifier, tap = switch)
- InputHook cancels switch if any other key pressed while switch key held
- PostMessage WM_INPUTLANGCHANGEREQUEST (0x50) to active window + focused control
- **No broadcast** - switches only active window (preserves per-window layout in Windows)
- Special handling for CapsLock as switch key (undoes toggle)

**Key Challenge Solved:**
- AHK v2 lacks simple layout switching examples
- Most solutions use timers (high CPU) or don't work with per-window layouts
- Our solution: event-driven via InputHook + proper WinAPI calls

**Configuration:**
```ahk
LAYOUT_PRI := "en-US"          # Primary layout
LAYOUT_SEC := "uk-UA"          # Secondary layout (Ukrainian)
LAYOUT_SWITCH_KEY := "LCtrl"   # LCtrl, RCtrl, CapsLock, etc.
LAYOUT_TIMEOUT := 500          # ms
```

### 2. Plain Text Paste
**Purpose:** Paste clipboard content as plain text, removing all formatting (fonts, colors, etc.).

**Implementation:**
- Save full clipboard (ClipboardAll) including all formats
- Convert to plain text, trim whitespace
- Paste via Send "^v"
- Restore original clipboard (doesn't break Windows clipboard history)

**Use Case:** Copy formatted text from Word/browser → paste into plain text editor without formatting.

**Configuration:**
```ahk
PLAIN_PASTE_KEY := "#v"   # Win+V
```

### 3. Input Diary
**Purpose:** Log all typed text to a file for recovery after browser crashes, unexpected shutdowns, etc.

**Implementation:**
- InputHook captures characters **after** layout processing (real text, not scancodes)
- Auto-save every 10 seconds (appends only new content since last save)
- Enter key adds newline to log
- Filters out Ctrl/Alt/Win combinations (doesn't log hotkeys)
- **No window headers** - removed due to implementation complexity (milestone for future)
- Backup system: on startup, moves existing diary.txt → diary.last.txt

**Security Note:** Logs everything including passwords. Users should disable script when entering sensitive data.

**Configuration:**
```ahk
DIARY_FILE := A_ScriptDir "\diary.txt"
DIARY_BACKUP := A_ScriptDir "\diary.last.txt"
DIARY_AUTO_SAVE_INTERVAL := 10   # seconds
DIARY_CLEAR_ON_START := true     # Move old diary to backup on startup
```

## Known Issues & Limitations

### Current
- **No window headers in diary** - text is continuous, not separated by application/window
- Backspace doesn't delete from log (all keystrokes recorded, including corrections)
- CapsLock as switch key has minor quirk (must press twice to enable CapsLock normally)

### By Design
- Diary logs passwords - user responsibility to manage
- Layout switcher requires exact locale names (not user-friendly language names)
- Auto-save overwrites in-place (no undo for diary mistakes)

## Milestones & Future Work

### Milestone: Window Headers in Diary (Postponed)
**Goal:** Add headers like `[14:30:15] chrome.exe — GitHub - AutoHotkey` before each text block.

**Attempted approaches that failed:**
- Shell Hook + comparing window titles: headers weren't written or were duplicated
- Flush buffer on window change: timing issues caused missing text or wrong headers
- Various flush/header write order combinations: still buggy

**Why postponed:**
- Core functionality (text recovery) works without headers
- Headers are cosmetic - user can still find lost text by reading full log
- Risk of introducing bugs to working core feature

**Possible future solution:**
- Revisit with simpler approach: write header on first keystroke in new window
- Or use separate metadata file with timestamps/window info
- Or add manual markers via hotkey (user presses key to insert "--- [window] ---" marker)

### Milestone: Multiple Backup Files
**Current:** Only one backup (diary.last.txt)  
**Future:** Keep N last backups (diary.last.1.txt, diary.last.2.txt, etc.)  
**Config:** `DIARY_MAX_BACKUPS := 5`

### Milestone: Password Field Detection
**Idea:** Detect password input fields (via accessibility API) and auto-pause logging  
**Challenge:** Complex, requires window introspection, may not work in all apps  
**Alternative:** Add pause/resume hotkey (Ctrl+Alt+D), but risks hotkey conflicts

## Development Notes

### Testing Checklist
- [ ] Layout switch: tap LCtrl in various apps (browser, notepad, terminal)
- [ ] Layout switch: verify Ctrl+C, Ctrl+V don't trigger switch
- [ ] Layout switch: test with Windows per-window layout setting ON
- [ ] Plain paste: copy formatted text from Word → paste in notepad
- [ ] Plain paste: verify Windows clipboard history (Win+V) still works
- [ ] Diary: type text, switch windows, verify diary.txt has content
- [ ] Diary: kill script via Task Manager, restart, verify diary.last.txt exists
- [ ] Diary: verify Enter adds newlines in log
- [ ] Diary: verify Ctrl+V doesn't appear in log

### Code Style
- Constants: UPPER_SNAKE_CASE
- Globals: camelCase
- Functions: PascalCase
- Comments: describe **why**, not **what** (code is self-documenting)
- AHK v2 syntax: `:=` for assignment, `global` keyword for globals

### Git Workflow
Main script is ready. Need to generate:
1. `README.md` - installation, configuration, usage examples, security warnings
2. `LICENSE` - MIT license text
3. `.gitignore` - ignore diary.txt, diary.last.txt, any *.bak files

## Usage Example

```ahk
; In configuration section at top of script:
global LAYOUT_PRI := "en-US"
global LAYOUT_SEC := "de-DE"      ; German
global LAYOUT_SWITCH_KEY := "CapsLock"
global DIARY_CLEAR_ON_START := false   ; Keep history across restarts
```

Run script → minimize to tray → use:
- **CapsLock (tap):** toggle English ↔ German
- **Win+V:** paste without formatting  
- **Diary:** automatic, check diary.txt after any crash

## Questions for Future Maintainers

1. Should we add GUI for configuration instead of editing script?
2. Should diary support Markdown formatting (# headers, ** bold)?
3. Should we split into 3 separate scripts for modularity?
4. Should we create installer (e.g., InnoSetup)?

## Resources

- [AHK v2 Documentation](https://www.autohotkey.com/docs/v2/)
- Windows locale names: `dism /online /get-intl` in PowerShell
- WinAPI messages: [WM_INPUTLANGCHANGEREQUEST](https://learn.microsoft.com/en-us/windows/win32/intl/wm-inputlangchangerequest)

---

**Note to Claude Code:** This project was developed through iterative problem-solving. The layout switcher took significant effort to get working correctly with AHK v2 (most online examples are for v1). The diary window headers feature was attempted but postponed due to complexity vs. value. Focus on stability and simplicity over feature creep.
