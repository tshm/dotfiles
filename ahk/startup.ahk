;##### startup.ahk
Loop Files, %A_ScriptDir%\*.ahk
{
  If (A_LoopFileName != A_ScriptName)
  {
    Run, %A_LoopFileName%
  }
}
ExitApp
