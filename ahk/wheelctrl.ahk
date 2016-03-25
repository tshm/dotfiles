;#### wheelctrl.ahk
EnvGet, DebugP, DEBUG
If (DebugP)
{
  TrayTip, Loading %A_ScriptName% , Debug Mode On
}
Else
{
  Menu, Tray, NoIcon
}
return

#Persistent
;---------------------------------------------------------------
MButton::
  Scale := 10
  MouseGetPos, X0, Y0
  fn := Func("SendWheelEvent").bind(Y0, Scale)
  SetTimer, % fn, 100
return 

MButton Up::
  MouseGetPos, X1, Y1
  SetTimer, % fn, Off
  if (X1 == X0)  ; trigger middle click if cursor is not moved.
    MouseClick, Middle
return

SendWheelEvent(Y0, Scale)
{
  MouseGetPos, X, NewY
  Delta := NewY - Y0
  NumWheel := abs(Delta // Scale)
  If (NumWheel == 0)
    return
  WheelMove := (Delta > 0 ?  "WheelDown" : "WheelUp")

  Loop % NumWheel {
    Click, %WheelMove%
  }

  MouseMove, X, Y0
  ;Traytip, evt: %WheelMove% x %NumWheel%, mouse moving
  ;ListVars
  return
}

;--- some general key-bindings ---
#PgUp::Send {Volume_Up 2}
#PgDn::Send {Volume_Down 2}

#If DebugP
!^r::Reload

