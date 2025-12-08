# Developer Notes: Keyboard Helper

This file serves as a log of development notes, known issues, and future ideas for the project, consolidating information from the original `claude.md` and the setup process.

---

## Known Issues & Limitations

### Current
- **No window headers in diary** - text is continuous, not separated by application/window.
- **Backspace doesn't delete from log** - all keystrokes are recorded, including corrections.
- **CapsLock as switch key has minor quirk** - may require a second press to enable CapsLock normally after a layout switch.

### By Design
- **Diary logs passwords** - this is a critical security point noted in the README. User responsibility is required.
- **Layout switcher requires exact locale names** - not user-friendly language names (e.g., "en-US" not "English").
- **Auto-save overwrites in-place** - no versioning or undo for the diary log.

---

## Milestones & Future Work

### Milestone: Window Headers in Diary (Postponed)
**Goal:** Add headers like `[14:30:15] chrome.exe — GitHub - AutoHotkey` before each text block.
**Why postponed:** The core feature (text recovery) works without it, and implementation attempts were buggy, risking the stability of the script. This is a cosmetic feature that adds significant complexity.
**Possible future solution:** Revisit with a simpler approach, like writing a header only on the first keystroke in a new window, or adding manual markers via a hotkey.

### Milestone: Multiple Backup Files
**Current:** Only one backup (`diary.last.txt`).
**Future Idea:** Keep N last backups (`diary.last.1.txt`, `diary.last.2.txt`, etc.). Could be configured with a `DIARY_MAX_BACKUPS := 5` variable.

### Milestone: Password Field Detection
**Idea:** Detect password input fields (possibly via accessibility APIs) and automatically pause logging.
**Challenge:** This is complex, requires window introspection, and may not work reliably in all applications. A simpler alternative would be a dedicated "pause/resume logging" hotkey, but that could introduce hotkey conflicts.

---

## Questions for Future Maintainers

1.  Should a GUI be added for configuration instead of requiring users to edit the script?
2.  Should the diary support Markdown formatting (e.g., for headers, bold text)?
3.  Should the three features be split into separate, optional script files for modularity?
4.  Should an installer (e.g., InnoSetup) be created for easier deployment?

---

## Initial Setup Log (Gemini)

This is a brief log of the steps taken to initialize the repository:
- Generated initial `README.md`, `LICENSE`, and `.gitignore` based on `claude.md`.
- Added developer notes (`claude.md`, `gemini.md`) to `.gitignore`.
- Later reversed this decision, consolidating all developer notes into this file (`gemini.md`) and deleting `claude.md`.
- Renamed the project from "Universal AHK Script" to "AHK Keyboard Helper" and the main script file to `KeyboardHelper.ahk` for clarity and consistency.
- Updated `README.md` multiple times to improve clarity, add security warnings, and synchronize it with the script's actual functionality.
- Reset the version to 1.0.0 for its first public release.
- Cleaned up the Git history into a single initial commit.