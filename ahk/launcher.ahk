;#### launcher.ahk
#NoTrayIcon
Debug := true
If (Debug)
{
  Traytip , AHK Restart, restarting %A_ScriptFullPath%
}

LaunchOffice()
{
  ;Run, C:\Users\satake\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Cygwin64 Terminal.lnk
  ;Run, Firefox
}

!^1::LaunchOffice()

; Ctrl - Alt - r  will reload script.
;^!r::Reload
