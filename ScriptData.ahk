
#Include Logger.ahk

Class DataObject
{
  BuildFromFile(ByRef a_file)
  {
  
  }
  
  BuildFromString(a_string)
  {
  
  }
  
  WriteToFile(ByRef a_out)
  {
    
  }
}

Class PauseData extends DataObject
{
  pauseOn := ""
  pauseOff := ""
  duration := 1
  
  BuildFromString(a_string)
  {
  
  }
  
  WriteToFile(ByRef a_out)
  {
    
  }
}

Class ActionData
{
  ;action types are key, delay, click. Data belongs to the items like this:
  ; key: key
  ; delay: delay
  ; click: key, x, y
  actionType := ""
  key := ""
  delay := 0
  x := 0
  y := 0
}

Class MacroData
{
  activationKey := ""
  activationType := ""
  actionList := []
}

Class BuildData
{
  name := ""
  bind := ""
  numlockKeys := []
  pauseKeys := []
  macros := []
}

Class ScriptData
{
  application := ""
  toggleActive := ""
  builds := []
}

Class Tags
{
  comment := "#"
  application := "application"
  toggleActive := "toggle_active"
  startBlock := "{"
  endBlock := "}"
  name := "name"
  bind := "bind"
  pse := "pause"
  numlck := "numlock"
  blockBuild := "build"
  blockMacro := "macro"
  blockActionList := "action_list"
  activationKey := "activation_key"
  activationType := "activation_type"
  activationTypeHold := "hold"
  activationTypeToggleOn := "toggle_on"
  activationTypeToggleOff := "toggle_off"
  activationTypeAlwaysOn := "always_on"
  actionKey := "key"
  actionDelay := "delay"
  actionClick := "click"
  kvDelim := "="
  arrayDelim := ","
}