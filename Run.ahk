
#Include ScriptBuilder.ahk
#Include Engine.ahk

scriptData := BuildScript("builds.ini")
;PrintMacro(scriptData)
InitAndRun(scriptData)
