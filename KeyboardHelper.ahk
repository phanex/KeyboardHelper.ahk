#Requires AutoHotkey v2.0
; Keyboard Helper v1.0.0
; A compact AutoHotkey script for keyboard power-users, combining:
; - Keyboard Layout Switcher
; - Plain Text Paste
; - Input Diary (text recovery)

; ============================================================================
; CONFIGURATION
; ============================================================================

; --- Layout switcher ---
global ENABLE_LAYOUT_SWITCHER := true

; Primary / secondary layouts (locale names).
; Examples: "en-US", "en-GB", "uk-UA", "de-DE", "pl-PL"  (see: dism /online /get-intl)
global LAYOUT_PRI := "en-US"   ; primary layout
global LAYOUT_SEC := "uk-UA"   ; secondary layout

; Switch key: LCtrl, RCtrl, LShift, RShift, CapsLock, LAlt, RAlt, AppsKey ...
global LAYOUT_SWITCH_KEY := "LCtrl"

; Tap timeout (ms) for switch key
global LAYOUT_TIMEOUT := 500


; --- Plain text paste ---
global ENABLE_PLAIN_PASTE := true
global PLAIN_PASTE_KEY := "#v"   ; Win+V


; --- Input diary ---
global ENABLE_INPUT_DIARY := true
; Diary file path: use A_ScriptDir, A_MyDocuments or absolute path like "D:\Logs\diary.txt"
global DIARY_FILE := A_ScriptDir "\diary.txt"
global DIARY_BACKUP := A_ScriptDir "\diary.last.txt"
global DIARY_AUTO_SAVE_INTERVAL := 10    ; seconds
global DIARY_CLEAR_ON_START := true


; ============================================================================
; GLOBAL STATE
; ============================================================================

; Layout switcher
global last_layout_sec := LAYOUT_SEC
global SWITCH_TAP := false

; Input diary
global diaryBuffer := ""
global lastAutoSaveLength := 0


; ============================================================================
; INITIALIZATION
; ============================================================================

SetWorkingDir A_ScriptDir
Persistent

if (ENABLE_LAYOUT_SWITCHER) {
    Hotkey "~*" LAYOUT_SWITCH_KEY, SwitchKeyDown
    Hotkey "~*" LAYOUT_SWITCH_KEY " up", SwitchKeyUp
}

if (ENABLE_PLAIN_PASTE) {
    Hotkey PLAIN_PASTE_KEY, PlainPaste
}

if (ENABLE_INPUT_DIARY) {
    InitDiary()
}

OnExit ExitFunc


; ============================================================================
; FUNCTION 1: LAYOUT SWITCHER
; ============================================================================

SwitchKeyDown(*) {
    global SWITCH_TAP, LAYOUT_TIMEOUT
    SWITCH_TAP := true
    SetTimer () => SWITCH_TAP := false, -LAYOUT_TIMEOUT
}

SwitchKeyUp(*) {
    global SWITCH_TAP, last_layout_sec, LAYOUT_PRI, LAYOUT_SWITCH_KEY

    if (!SWITCH_TAP)
        return
    SWITCH_TAP := false

    cur := GetCurrentLayout()

    if (IsPrimaryLayout(cur)) {
        SetKeyboardLayout(last_layout_sec)
    } else {
        last_layout_sec := cur
        SetKeyboardLayout(LAYOUT_PRI)
    }

    ; For CapsLock as switch key: undo CapsLock toggle when layout was switched.
    if (LAYOUT_SWITCH_KEY = "CapsLock") {
        SetCapsLockState "Toggle"
    }
}

GetCurrentLayout() {
    ; Get current LCID for active window and convert to locale name like "en-US".
    t := DllCall("GetWindowThreadProcessId", "Ptr", WinExist("A"), "Ptr", 0, "UInt")
    l := DllCall("GetKeyboardLayout", "UInt", t, "Ptr") & 0xFFFF
    buf := Buffer(85*2, 0)
    DllCall("LCIDToLocaleName", "UInt", l, "Ptr", buf, "Int", 85, "UInt", 0)
    return StrGet(buf)
}

IsPrimaryLayout(locale) {
    global LAYOUT_PRI
    return (locale = LAYOUT_PRI)
}

SetKeyboardLayout(locale) {
    ; Switch layout via LCID and WM_INPUTLANGCHANGEREQUEST.
    LCID := DllCall("LocaleNameToLCID", "Str", locale, "UInt", 0, "UInt")
    w := WinExist("A")
    if !w
        return

    PostMessage 0x50, 0, LCID, , "ahk_id " w

    try {
        c := ControlGetHwnd(ControlGetFocus())
        PostMessage 0x50, 0, LCID, , "ahk_id " c
    }
}


; ============================================================================
; FUNCTION 2: PLAIN TEXT PASTE (Win+V)
; ============================================================================

PlainPaste(*) {
    clipSaved := ClipboardAll()
    A_Clipboard := Trim(A_Clipboard, " `t`n`r`f`v")

    if !ClipWait(0.5) {
        A_Clipboard := clipSaved
        clipSaved := ""
        return
    }

    Send "^v"
    Sleep 50

    A_Clipboard := clipSaved
    clipSaved := ""
}


; ============================================================================
; FUNCTION 3: INPUT DIARY
; ============================================================================

InitDiary() {
    global diaryBuffer, lastAutoSaveLength
    global DIARY_FILE, DIARY_BACKUP, DIARY_CLEAR_ON_START, DIARY_AUTO_SAVE_INTERVAL

    if (DIARY_CLEAR_ON_START) {
        if FileExist(DIARY_FILE) {
            try FileDelete DIARY_BACKUP
            try FileMove DIARY_FILE, DIARY_BACKUP, 1
        }
    }

    diaryBuffer := ""
    lastAutoSaveLength := 0

    ih := InputHook("V I")
    ih.VisibleText := true
    ih.VisibleNonText := true
    ih.KeyOpt("{All}", "N")
    ih.OnChar := RecordChar
    ih.OnKeyDown := CheckModifiers
    ih.Start()

    if (DIARY_AUTO_SAVE_INTERVAL > 0) {
        SetTimer AutoSaveDiary, DIARY_AUTO_SAVE_INTERVAL * 1000
    }
}

CheckModifiers(ih, vk, sc) {
    global diaryBuffer, SWITCH_TAP, LAYOUT_SWITCH_KEY

    ; Cancel layout tap if any other key pressed while switch key is active.
    if (SWITCH_TAP) {
        static vkSwitch := 0
        if (!vkSwitch) {
            vkSwitch := GetKeyVK(LAYOUT_SWITCH_KEY)
        }
        if (vk != vkSwitch) {
            SWITCH_TAP := false
        }
    }

    ; Do not log text while modifier keys are held.
    if GetKeyState("Ctrl") || GetKeyState("Alt") || GetKeyState("LWin") || GetKeyState("RWin") {
        return
    }

    ; Log Enter as newline.
    if (vk == 0x0D) {
        diaryBuffer .= "`n"
    }
}

RecordChar(ih, char) {
    global diaryBuffer

    if (Ord(char) < 32)
        return

    diaryBuffer .= char
}

AutoSaveDiary() {
    global diaryBuffer, lastAutoSaveLength, DIARY_FILE

    currentLength := StrLen(diaryBuffer)
    if (currentLength > lastAutoSaveLength) {
        newContent := SubStr(diaryBuffer, lastAutoSaveLength + 1)
        try FileAppend newContent, DIARY_FILE, "UTF-8"
        lastAutoSaveLength := currentLength
    }
}


; ============================================================================
; CLEANUP
; ============================================================================

ExitFunc(ExitReason, ExitCode) {
    global ENABLE_INPUT_DIARY, diaryBuffer, DIARY_FILE

    if (ENABLE_INPUT_DIARY && diaryBuffer != "") {
        try FileAppend diaryBuffer, DIARY_FILE, "UTF-8"
    }
}