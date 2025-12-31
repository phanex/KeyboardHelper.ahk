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

### Milestone: Dual-Shortcut Switching Logic (Proposed)
**Goal:** Implement a more advanced layout management system using two distinct shortcuts, providing more control than the current cyclic toggle.

**New Logic Explained:**

1.  **Shortcut 1: "Reset to Primary & Remember"** (e.g., `LShift`)
    *   **Action:** When you press this key, the script checks your current keyboard layout.
    *   **Behavior:**
        *   If you are already using the primary layout (e.g., `en-US`), nothing happens.
        *   If you are using any other layout (e.g., a third language like `de-DE`), the script will **remember** that layout and immediately switch you back to your **primary** layout.
    *   **Purpose:** This acts as a reliable "home" button to get back to your main typing language, while intelligently saving your last-used secondary language.

2.  **Shortcut 2: "Switch to Secondary"** (e.g., `LCtrl`)
    *   **Action:** When you press this key, the script switches you to the secondary layout.
    *   **Behavior:**
        *   If Shortcut 1 was used recently to remember a layout (like `de-DE`), this shortcut will switch you to that **remembered** layout.
        *   If you haven't used Shortcut 1 yet, it will switch you to your **pre-defined** secondary layout (the one set as `LAYOUT_SEC` in the configuration).
    *   **Purpose:** This gives you a dedicated key to activate your secondary/last-used language.

3.  **Special Case: Single Shortcut**
    *   If you configure both shortcuts to use the **same key**, the script will revert to its current behavior: a simple two-way toggle that cycles between your primary and pre-defined secondary layouts.


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

---

## Bug Fixes and Discoveries

### Solved: Layout Detection in Console Windows (e.g., PowerShell)

- **The Bug:** The layout switcher failed to correctly identify the active keyboard layout in console applications. It would always report the system's default layout (e.g., `en-US`), causing the switcher logic to fail.

- **The Investigation:** A long and arduous debugging process revealed that no standard method of *querying* the layout state works reliably for console windows. The following attempts failed:
    1.  **`GetKeyboardLayout(threadID)`:** Using the thread ID of the active console window via `GetWindowThreadProcessId` or `GetForegroundWindow` always returned the default layout.
    2.  **`GetKeyboardLayout(0)`:** Using the script's own thread ID was also unreliable.
    3.  **`WorkerW` Fallback:** An attempt to query the desktop's thread (`WorkerW`) failed due to AHK v1/v2 syntax conversion errors during implementation.
    4.  **WinRT API:** A test using the modern `Windows.Globalization.Language.CurrentInputMethodLanguageTag` also failed, proving that even modern APIs do not reliably report the state when queried from an external process.

- **The Breakthrough:** The user's persistence was key. They discovered a forum thread that suggested a different approach: targeting the **Input Method Manager (IME)**.

- **The Solution:** The final, working solution does not query the console window directly. Instead, it uses a function from `Imm32.dll` to find the specific "Input Method Editor" window that is associated with the active application. The thread of *this* IME window correctly holds the true, current keyboard layout state.

- **Final Implementation:** The `GetCurrentLayout()` function in the main `KeyboardHelper.ahk` was replaced with the new `Imm32.dll`-based logic. This solution is self-contained, requires no external libraries, and is compatible with the stable AutoHotkey v2.0 release.
    
This method works reliably across all applications tested, including PowerShell, finally resolving the bug.

### Solved: Timeout Regression and Auto-Repeat Handling

- **The Bug:** After implementing the `Imm32.dll` layout detection fix, the original `LAYOUT_TIMEOUT` mechanism (which prevented switching on long key presses) ceased to function correctly. The layout would switch even when the hotkey was held down. This was due to blocking WinAPI calls within the new `GetCurrentLayout()` function, which prevented the timer from invalidating the `SWITCH_TAP` flag on time. Initial attempts to fix this (`A_TickCount`-based logic) inadvertently broke the handling of modifier key combinations (like `Ctrl+C`).

- **The Solution (User-Provided):** The user themselves provided a robust and elegant fix that correctly handles both long presses and auto-repeat keydown events, making the timeout mechanism reliable and resilient to blocking calls. The solution involves:
    1.  A new global variable `SWITCH_DOWN_TIME` to store the exact time of the *initial* key press (recorded only once per press in `SwitchKeyDown`, ignoring auto-repeat events).
    2.  In `SwitchKeyUp`, performing a dual check: first, the `SWITCH_TAP` flag (to abort if an interrupted combo like `Ctrl+C` occurred via `CheckModifiers`), and second, comparing `A_TickCount - SWITCH_DOWN_TIME` against `LAYOUT_TIMEOUT` to detect a long press.
    
This combined logic ensures that the layout only switches on a quick, clean tap, completely resolving the timeout regression and auto-repeat issues.

### Solved: Merging Good Detection with Good Switching (Session 2)

- **The Bug:** After several attempts to implement a robust layout switcher for Console and UWP apps, the script was left in a state where layout *detection* was excellent, but the layout *switching* was broken. The user had a separate `AutoHotkey.ahk` file where the switching logic was perfect, but the detection was flawed for modern apps.

- **The Investigation:** The core of the problem was an incompatibility between the two "good" pieces of code. The user's preferred switching logic operated on **locale name strings** (e.g., "en-US"), while the new, robust detection logic returned a **keyboard layout handle (HKL)** (e.g., a number like `0x4090409`). A direct merge was not possible.

- **The Solution:** The resolution was to act as a bridge between the two systems. The advanced `GetCurrentLayout` function (which correctly identifies the layout in Console/UWP/Steam apps) was modified. After getting the correct HKL, it was programmed to convert that HKL back into a standard locale name string before returning its value.

- **Final Implementation:** The main `KeyboardHelper.ahk` script was built using the user's preferred `AutoHotkey.ahk` as a base. Its simple `GetCurrentLayout` function was then replaced with the new, advanced, and compatible version. This resulted in a final script that has both the user's desired switching behavior and the wide-ranging detection capabilities required for modern Windows applications.
