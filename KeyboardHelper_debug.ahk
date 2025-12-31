#Requires AutoHotkey v2.0
#Include KeyboardHelper.ahk

F1:: {
    layout := GetCurrentLayout()
    ToolTip "Current Layout: " layout
    SetTimer () => ToolTip(), -2000
}
