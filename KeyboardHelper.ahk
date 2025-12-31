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

global SWITCH_DOWN_TIME := 0

SwitchKeyDown(*) {
    global SWITCH_TAP, SWITCH_DOWN_TIME
    
    ; Запам'ятати час тільки при ПЕРШОМУ натисканні
    if (!SWITCH_TAP) {
        SWITCH_TAP := true
        SWITCH_DOWN_TIME := A_TickCount
    }
}

_GetKeyboardLayout(HWnd) {
  ThreadId := DllCall("GetWindowThreadProcessId", "Ptr", HWnd, "Ptr", 0)
  If !ThreadId
    Return ""

  hkl := DllCall("GetKeyboardLayout", "UInt", ThreadId)
  lcid := hkl & 0xFFFF
  buf := Buffer(85*2, 0)
  DllCall("LCIDToLocaleName", "UInt", lcid, "Ptr", buf, "Int", 85, "UInt", 0)
  Return StrGet(buf)
}

_SetKeyboardLayout(HWnd, Layout) {
  LCID := DllCall("LocaleNameToLCID", "Str", Layout, "UInt", 0, "UInt")
  PostMessage 0x50, 0, LCID, , "ahk_id " HWnd
}

GetImeLayout() {
  WinGetClass wc, "A"
  If InStr(wc, "ConsoleWindowClass")
  {
    ime_hwnd := DllCall("Imm32\ImmGetDefaultIMEWnd", "Ptr", WinExist("A"), "Ptr")
    If ime_hwnd
      Return _GetKeyboardLayout(ime_hwnd)
  }
  Return ""
}

GetUwpLayout(Control) {
  If DllCall("GetClassName", "Ptr", Control, "Str", ClassName, "Int", 256)
  {
    If (ClassName ~= "Windows.UI.Core.CoreWindow|App[0-9A-Za-z]+")
    {
      Loop 50
      {
        PostMessage 0x50, 0, 0, , "ahk_id " Control ; WM_INPUTLANGCHANGEREQUEST
        Sleep 50
        If (layout := _GetKeyboardLayout(Control))
          Return layout
      }
    }
  }
  Return ""
}

SetImeLayout(Layout) {
  WinGetClass wc, "A"
  If InStr(wc, "ConsoleWindowClass")
  {
    ime_hwnd := DllCall("Imm32\ImmGetDefaultIMEWnd", "Ptr", WinExist("A"), "Ptr")
    If ime_hwnd
      _SetKeyboardLayout(ime_hwnd, Layout)
  }
}

SetUwpLayout(Control, Layout) {
  If DllCall("GetClassName", "Ptr", Control, "Str", ClassName, "Int", 256)
  {
    If (ClassName ~= "Windows.UI.Core.CoreWindow|App[0-9A-Za-z]+")
    {
      Loop 50
      {
        _SetKeyboardLayout(Control, Layout)
        Sleep 50
        If (_GetKeyboardLayout(Control) = Layout)
          Return
      }
    }
  }
}

GetCurrentLayout() {
  WinGetClass wc, "A"
  If (wc ~= "Windows.UI.Core.CoreWindow|ApplicationFrameWindow|CabinetWClass|ExploreWClass|WorkerW|Shell_TrayWnd")
  {
    If (Control := ControlGetFocus()) && (Control ~= "(DirectUIHWND|Windows.UI.Core.CoreWindow|App[0-9A-Za-z]+)")
    {
      WinGetPID PID, "A"
      For Process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId = " PID)
      {
        If InStr(Process.ExecutablePath, "\SystemApps\") || InStr(Process.ExecutablePath, "\Microsoft.Windows.Search_")
          Return GetUwpLayout(Control)
      }
    }
  }

  If InStr(wc, "ConsoleWindowClass")
    Return GetImeLayout()

  Return _GetKeyboardLayout(WinExist("A"))
}

LayoutSwitch(Layout) {
  WinGetClass wc, "A"
  If (wc ~= "Windows.UI.Core.CoreWindow|ApplicationFrameWindow|CabinetWClass|ExploreWClass|WorkerW|Shell_TrayWnd")
  {
    If (Control := ControlGetFocus()) && (Control ~= "(DirectUIHWND|Windows.UI.Core.CoreWindow|App[0-9A-Za-z]+)")
    {
      WinGetPID PID, "A"
      For Process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId = " PID)
      {
        If InStr(Process.ExecutablePath, "\SystemApps\") || InStr(Process.ExecutablePath, "\Microsoft.Windows.Search_")
        {
          SetUwpLayout(Control, Layout)
          Return
        }
      }
    }
  }

  If InStr(wc, "ConsoleWindowClass")
  {
    SetImeLayout(Layout)
    Return
  }

  _SetKeyboardLayout(WinExist("A"), Layout)
}

SwitchKeyUp(*) {
    global SWITCH_TAP, SWITCH_DOWN_TIME, LAYOUT_TIMEOUT
    global last_layout_sec, LAYOUT_PRI, LAYOUT_SWITCH_KEY

    if (!SWITCH_TAP)
        return
    
    ; Перевірити, чи пройшло більше ніж LAYOUT_TIMEOUT мс
    elapsed := A_TickCount - SWITCH_DOWN_TIME
    if (elapsed > LAYOUT_TIMEOUT) {
        SWITCH_TAP := false
        return
    }
    
    SWITCH_TAP := false
    
    cur := GetCurrentLayout()
    
    if (IsPrimaryLayout(cur)) {
        LayoutSwitch(last_layout_sec)
    } else {
        last_layout_sec := cur
        LayoutSwitch(LAYOUT_PRI)
    }
    
    if (LAYOUT_SWITCH_KEY = "CapsLock") {
        SetCapsLockState "Toggle"
    }
}

IsPrimaryLayout(locale) {
    global LAYOUT_PRI
    return (locale = LAYOUT_PRI)
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