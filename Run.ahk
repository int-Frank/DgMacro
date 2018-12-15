#SingleInstance Force

#Include Engine.ahk
#Include jsonHandler.ahk

; TODO + remove numlock code (don't need it - can spam keys instead)

try
{
  FileRead, jsonStr, builds.json
}
catch obj
{
  MsgBox Failed to open builds.json
  Return
}

scriptObject := json(jsonStr)
InitAndRun(scriptObject)

;----------------------------------------------------------------------------
; Additional bindings
;----------------------------------------------------------------------------

;Kill Key: alt + x
!x::ExitApp

;Party chat
!a::
  Send /p
  Send {Return}
Return

;Clan chat
!c::
  Send /c
  Send {Return}
Return