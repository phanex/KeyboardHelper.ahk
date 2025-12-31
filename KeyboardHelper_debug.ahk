#Requires AutoHotkey v2.0
#Include KeyboardHelper.ahk

F1:: {
    hkl := GetCurrentLayout()
    lcid := hkl & 0xFFFF
    buf := Buffer(85*2, 0)
    DllCall("LCIDToLocaleName", "UInt", lcid, "Ptr", buf, "Int", 85, "UInt", 0)
    layout_name := StrGet(buf)

    ToolTip "Current HKL: " hkl "`nCurrent Layout: " layout_name
    SetTimer () => ToolTip(), -3000
}