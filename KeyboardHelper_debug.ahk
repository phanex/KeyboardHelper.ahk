#Requires AutoHotkey v2.0
#Include KeyboardHelper.ahk

; ============================================================================
; DEBUG & TESTING HARNESS
; ============================================================================

; Press F1 to inspect current and previous layout
F1:: {
    layout := GetCurrentLayout()
    ToolTip "Current Layout: " layout "`nPrevious Layout: " previous_layout
    SetTimer () => ToolTip(), -2000
}
