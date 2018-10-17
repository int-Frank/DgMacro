#SingleInstance Force

#Include Engine.ahk
#Include jsonHandler.ahk

try
{
  FileRead, jsonStr, builds.json
}
catch obj
{
  MsgBox Failed to open builds.json
}

scriptObject := json(jsonStr)
InitAndRun(scriptObject)

;Kill Key: alt + x
!x::ExitApp