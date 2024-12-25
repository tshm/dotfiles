;#### layout.ahk
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

; Get the monitor dimension which holds the current window
GetCurrentMonitor(m)
{
  WinGetPos, x, y, , , A
  SysGet, MonitorCount, MonitorCount
  Loop, %MonitorCount%
  {
    SysGet, Monitor, Monitor, %A_Index%
    If ((MonitorBottom - m > y && y >= MonitorTop - m)
      && (MonitorLeft - m <= x && x < MonitorRight - m))
    {
      SysGet, WorkArea, MonitorWorkArea, %A_Index%
      return { Top: WorkAreaTop, Bottom: WorkAreaBottom
             , Left: WorkAreaLeft, Right: WorkAreaRight }
    }
  }
}

; Tile Left(-1) or Right(1) the current window.
TileWin(Direction = -1, WidthRatio = 0.65)
{
  WorkArea := GetCurrentMonitor(50)
  ScreenWidth := WorkArea["Right"] - WorkArea["Left"]
  ScreenHeight := WorkArea["Bottom"] - WorkArea["Top"]
  w := round(ScreenWidth * WidthRatio)
  h := ScreenHeight
  x := WorkArea["Left"]
  If (Direction == 1)
  {
    x := WorkArea["Right"] - w
  }
  WinMove, A, , x, 0, w, h
}

; Key bindings
^!Right::
TileWin(1)
return

^!Left::
TileWin(-1)
return

f6::
WinGetPos, , , Width, Height, A
MouseMove, (width/2), (height/2)
return

#If DebugP
!^r::Reload
