#Requires AutoHotkey v2.0
#DllLoad "Imm32"

; ============================================================================
; Keyboard Helper v2.0.0
; A lightweight AutoHotkey script combining:
; - macOS-style Layout Switcher (toggles between last two active layouts)
; - CapsLock Reset & Long-press (tap = switch to en-US, hold = CapsLock toggle)
; - Plain Text Paste (Win+V)
; - Screen Color Picker (Win+Alt+C)
; ============================================================================

; --- Configuration ---
global LAYOUT_PRI := "en-US"         ; Primary layout (reset target for CapsLock)
global LAYOUT_SWITCH_KEY := "LCtrl"  ; Quick tap switch key
global LAYOUT_TIMEOUT := 400         ; Max tap duration in ms for switch key
global CAPSLOCK_HOLD_TIME := 350     ; Min duration in ms to trigger native CapsLock

global ENABLE_PLAIN_PASTE := true
global PLAIN_PASTE_KEY := "#v"       ; Win+V

global ENABLE_COLOR_PICKER := true
global COLOR_PICKER_KEY := "#!c"     ; Win+Alt+C

; --- Global State ---
global current_layout := ""
global previous_layout := ""
global SWITCH_TAP := false
global SWITCH_DOWN_TIME := 0
global getDefIMEWnd := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "Imm32", "Ptr"), "AStr", "ImmGetDefaultIMEWnd", "Ptr")

; --- Initialization ---
SetWorkingDir A_ScriptDir
Persistent
SetCapsLockState "AlwaysOff"  ; Prevent accidental CapsLock toggle on short tap

current_layout := GetCurrentLayout()
previous_layout := (current_layout = LAYOUT_PRI) ? "uk-UA" : LAYOUT_PRI

Hotkey "~*" LAYOUT_SWITCH_KEY, SwitchKeyDown
Hotkey "~*" LAYOUT_SWITCH_KEY " up", SwitchKeyUp

if (ENABLE_PLAIN_PASTE) {
    Hotkey PLAIN_PASTE_KEY, PlainPaste
}

if (ENABLE_COLOR_PICKER) {
    Hotkey COLOR_PICKER_KEY, PickColor
}

; ============================================================================
; 1. LAYOUT SWITCHER (macOS-style: Toggles between last two used layouts)
; ============================================================================
SwitchKeyDown(*) {
    global SWITCH_TAP, SWITCH_DOWN_TIME
    if (!SWITCH_TAP) {
        SWITCH_TAP := true
        SWITCH_DOWN_TIME := A_TickCount
    }
}

SwitchKeyUp(*) {
    global SWITCH_TAP, SWITCH_DOWN_TIME, LAYOUT_TIMEOUT
    global current_layout, previous_layout

    if (!SWITCH_TAP)
        return

    elapsed := A_TickCount - SWITCH_DOWN_TIME
    SWITCH_TAP := false

    if (elapsed > LAYOUT_TIMEOUT)
        return

    UpdateLayouts()
    target := (previous_layout != "" && previous_layout != current_layout) ? previous_layout : LAYOUT_PRI
    SetKeyboardLayout(target)
}

; ============================================================================
; 2. CAPSLOCK: TAP = RESET TO EN-US, HOLD (>350ms) = REAL CAPSLOCK
; ============================================================================
*CapsLock::
{
    start := A_TickCount
    KeyWait "CapsLock"
    held := A_TickCount - start

    ; If any other key was pressed while holding CapsLock, do nothing
    if (A_PriorKey != "CapsLock")
        return

    if (held >= CAPSLOCK_HOLD_TIME) {
        ; Long press: toggle native uppercase CapsLock state
        SetCapsLockState !GetKeyState("CapsLock", "T")
    } else {
        ; Short tap: immediately reset layout to English
        UpdateLayouts()
        SetKeyboardLayout(LAYOUT_PRI)
    }
}

; ============================================================================
; HELPER FUNCTIONS FOR LAYOUTS
; ============================================================================
UpdateLayouts() {
    global current_layout, previous_layout
    cur := GetCurrentLayout()
    if (cur != "" && cur != current_layout) {
        previous_layout := current_layout
        current_layout := cur
    }
}

GetCurrentLayout() {
    fgWin := DllCall("GetForegroundWindow")
    if WinActive("ahk_class ConsoleWindowClass") {
        IMEWnd := DllCall(getDefIMEWnd, "Ptr", fgWin)
        if (IMEWnd != 0)
            fgWin := IMEWnd
    } else if WinActive("ahk_class vguiPopupWindow") or WinActive("ahk_class ApplicationFrameWindow") {
        Focused := ControlGetFocus("A")
        if (Focused != 0) {
            CtrlID := ControlGetHwnd(Focused, "A")
            fgWin := CtrlID
        }
    }
    threadID := DllCall("GetWindowThreadProcessId", "Ptr", fgWin, "Ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "UInt", threadID, "Ptr")

    lcid := hkl & 0xFFFF
    buf := Buffer(85 * 2, 0)
    DllCall("LCIDToLocaleName", "UInt", lcid, "Ptr", buf, "Int", 85, "UInt", 0)
    return StrGet(buf)
}

SetKeyboardLayout(locale) {
    global current_layout, previous_layout
    LCID := DllCall("LocaleNameToLCID", "Str", locale, "UInt", 0, "UInt")
    w := WinExist("A")
    if !w
        return

    PostMessage 0x50, 0, LCID, , "ahk_id " w
    try {
        c := ControlGetHwnd(ControlGetFocus())
        PostMessage 0x50, 0, LCID, , "ahk_id " c
    }

    if (locale != current_layout) {
        previous_layout := current_layout
        current_layout := locale
    }
}

; ============================================================================
; 3. PLAIN TEXT PASTE (WIN+V)
; ============================================================================
PlainPaste(*) {
    clipSaved := ClipboardAll()
    A_Clipboard := Trim(A_Clipboard, " `t`n`r`f`v")

    if !ClipWait(0.5) {
        A_Clipboard := clipSaved
        return
    }

    Send "^v"
    Sleep 50
    A_Clipboard := clipSaved
}

; ============================================================================
; 4. SCREEN COLOR PICKER (WIN+ALT+C)
; ============================================================================
PickColor(*) {
    MouseGetPos &x, &y
    color := PixelGetColor(x, y, "RGB")
    hex := SubStr(color, 3)  ; Strip "0x" prefix, keeping RRGGBB
    A_Clipboard := hex
    ToolTip "Copied: #" hex
    SetTimer () => ToolTip(), -1000
}
