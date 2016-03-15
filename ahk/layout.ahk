Debug := true
If (Debug)
{
  Traytip , AHK Restart, restarting %A_ScriptFullPath%

  ; Ctrl - Alt - r  will reload script.
  ^!r::Reload
}

; Get the monitor dimension which holds the current window
GetCurrentMonitor()
{
  WinGetPos, x, y, , , A
  SysGet, MonitorCount, MonitorCount
  Loop, %MonitorCount%
  {
    SysGet, Monitor, Monitor, %A_Index%
    If ((MonitorBottom > y && y >= MonitorTop)
      && (MonitorLeft <= x && x < MonitorRight))
    {
      SysGet, WorkArea, MonitorWorkArea, %A_Index%
      return { Top: WorkAreaTop, Bottom: WorkAreaBottom
             , Left: WorkAreaLeft, Right: WorkAreaRight }
    }
  }
}

; Tile Left(-1) or Right(1) the current window.
TileWin(Direction = -1, WidthRatio = 0.75)
{
  WorkArea := GetCurrentMonitor()
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
Traytip , Ctrl+Alt+Right triggered, id, 3
return

^!Left::
TileWin(-1)
Traytip , Ctrl+Alt+Right triggered, id, 3
return


