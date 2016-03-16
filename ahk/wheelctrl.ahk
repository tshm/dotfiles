;#### wheelctrl.ahk
;#NoTrayIcon
; Scale for converting Y-motion -> NumWheel
Scale := 5

CoordMode, Mouse, Screen
Traytip, AHK Restart, restarting %A_ScriptFullPath%
return

#Persistent
;---------------------------------------------------------------
MButton::
  MouseGetPos,, Y0
  fn := Func("SendWheelEvent").bind(Y0, Scale)
  SetTimer, % fn, 100
return

MButton Up::
  MouseGetPos,, Y1
  SetTimer, % fn, Off
  if (Y1 - Y0 == 0)  ; trigger middle click if cursor is not moved.
    MouseClick, Middle
return

SendWheelEvent(Y0, Scale)
{
  MouseGetPos,, NewY
  Delta := NewY - Y0
  NumWheel := abs(Delta // Scale)
  If (NumWheel == 0)
    return
  WheelMove := (Delta > 0 ?  "WheelDown" : "WheelUp")

  Loop % NumWheel {
    Click, %WheelMove%
  }

  ;Traytip, evt: %WheelMove% x %NumWheel%, mouse moving
  ;ListVars
  return
}

; Ctrl - Alt - r  will reload script.
^!r::Reload

