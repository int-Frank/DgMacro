
;TODO Macro_KeySpam_Toggle saves toggle state even after script is deactivated.
;     Reset

#Include ScriptBuilder.ahk
#Include Engine.ahk

scriptData := BuildScript("builds.ini")
;PrintMacro(scriptData)
InitAndRun(scriptData)
