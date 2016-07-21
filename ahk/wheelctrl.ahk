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

#Persistent
return
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

MouseOperation(op, acc:=1)
{
  step := 15 * acc
  if (op == "UP") {
    MouseMove, 0, -step, 0, R
  } else if (op == "DOWN") {
    MouseMove, 0,  step, 0, R
  } else if (op == "LEFT") {
    MouseMove, -step, 0, 0, R
  } else if (op == "RIGHT") {
    MouseMove,  step, 0, 0, R
  } else if (op == "LCLICK") {
    Click 
  } else if (op == "RCLICK") {
    Click, right
  } else if (op == "WHEELUP") {
    Click, WheelUp
  } else if (op == "WHEELDOWN") {
    Click, WheelDown
  }
}

MouseIsOver(WinTitle) {
  MouseGetPos,,, Win
  Return WinExist(WinTitle . " ahk_id " . Win)
}

;---------------------------------------------------------------

;--- sound volume control
#PgUp::Send {Volume_Up 2}
#PgDn::Send {Volume_Down 2}
#If MouseIsOver("ahk_class Shell_TrayWnd")
WheelUp::Send {Volume_Up 2}
WheelDown::Send {Volume_Down 2}
#If

;--- keyboard mouse
#If GetKeyState("CapsLock", "T")
~Space::Shift
k::MouseOperation("UP")
+k::MouseOperation("UP", 5)
j::MouseOperation("DOWN")
+j::MouseOperation("DOWN", 5)
h::MouseOperation("LEFT")
+h::MouseOperation("LEFT", 5)
l::MouseOperation("RIGHT")
+l::MouseOperation("RIGHT", 5)
f::MouseOperation("LCLICK")
s::MouseOperation("RCLICK")
r::MouseOperation("WHEELUP")
e::MouseOperation("WHEELDOWN")
#If ;GetKeyState("CapsLock", "T")

;--- IME switch
;; SC029::Send {vkF3sc029}

#If DebugP
!^r::Reload

