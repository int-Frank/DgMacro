
Class Tags
{
  comment := "#"
  application := "application"
  onOff := "on_off"
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

Class PauseData
{
  pauseOn := ""
  pauseOff := ""
  duration := 1
}

Class KeyValueData
{
  key := ""
  value := ""
}

Class ScriptOnOffData
{
  on := ""
  off := ""
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

Class ActionListData
{
  items := []
}

Class MacroData
{
  activationKey := ""
  activationType := ""
  actionList := ""
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
  onOff := ""
  builds := []
}

