# Developer Notes: Keyboard Helper

This file serves as a log of development notes, known issues, and future ideas for the project, consolidating information from the original `claude.md` and the setup process.

---

## Completed Milestones (v2.0.0 - 2026-10-27)

### ✅ Milestone: macOS-Style Dual Layout Switching
- **Goal Achieved:** Instead of a rigid cyclic toggle between English and one secondary language, the script dynamically tracks `current_layout` and `previous_layout`.
- **Behavior:** Tapping `LCtrl` seamlessly swaps between the two most recently used layouts (e.g. UK <-> EN, or UK <-> DE), fully matching macOS "Select previous input source".

### ✅ Milestone: CapsLock Reset to English & Long-Press
- **Goal Achieved:**
  - **Short Tap:** Unconditionally resets active layout to primary (`en-US`). Eliminates ambiguity when switching to enter code, passwords, or shell commands.
  - **Long Press (>350ms):** Toggles native `CapsLock` (uppercase mode). Prevents accidental CapsLock triggers during fast typing.

### ✅ Milestone: Purge Input Diary (Keylogger Removal)
- **Goal Achieved:** Completely removed `InputHook`, `diaryBuffer`, disk I/O, and `diary.txt`. Eliminates password security concerns, disk churn every 10 seconds, and sync conflicts.

### ✅ Milestone: Integrated Screen Color Picker
- **Goal Achieved:** Pressing `Win+Alt+C` (`#!c`) samples the pixel under the cursor using native `PixelGetColor` (GDI32 `GetPixel`) and copies `#RRGGBB` directly to clipboard with a 1-second tooltip.

---

## Solved Architecture: Layout Detection in Consoles
- **The Solution:** Uses `Imm32\ImmGetDefaultIMEWnd` to query the IME window associated with console applications (Command Prompt, PowerShell, Far Manager). The IME thread reliably retains the actual active input locale across all Windows builds.

---

## License
MIT License.
