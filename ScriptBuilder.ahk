
#include ScriptData.ahk

Fatal(a_str)
{
  MsgBox %a_str%
  ExitApp
}

Class KV
{
  key := ""
  value := ""  
}

GetKeyValue(a_text, a_delim)
{
  kv := New KV()
  wordArray := StrSplit(a_text, a_delim, " `t")
  
  sze := wordArray.MaxIndex()
  if (wordArray.MaxIndex() != 2)
  {
    MsgBox The line '%a_text%' is malformed. Must have the form 'key = value'
  }
  else
  {
    kv.key := Trim(wordArray[1], " `n`t")
    kv.value := Trim(wordArray[2], " `n`t")
  }
  return kv
}

IsInArray(a_array, a_item)
{
  for ind, ele in a_array
  {
    if (ele == a_item)
    {
      return True 
    }
  }
  return False
}

IsValidNumlockKey(a_array, a_item)
{
  if (IsInArray(a_array, a_item))
  {
    return False
  }
  
  allowed = ["Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5"
           , "Numpad6", "Numpad7", "Numpad8", "Numpad9", "Numpad0", "NumpadDot"
           , "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter"]
  if (IsInArray(allowed, a_item))
  {
    return False
  }
  
  return True
}

PrintMacro(a_macro)
{
  str := ""
  str .= "application: " . a_macro.application . "`n"
  str .= "toggle_active: " . a_macro.toggleActive . "`n"
  
  for ind, ele in a_macro.builds
  {
    str .= "{`n"
    str .= "  name: " . ele.name . "`n"
    str .= "  bind: " . ele.bind . "`n"
    
    str .= "  numlock keys: "
    for ind1, ele1 in ele.numlockKeys
    {
      str .= ele1 . " "
    }
    str .= "`n"
    
    for ind1, ele1 in ele.pauseKeys
    {
      str .= "  pause key: on = " . ele1.pauseOn . ", off = " . ele1.pauseOff . ", duration = " . ele1.duration . "`n"
    }
    
    for ind1, ele1 in ele.macros
    {
      str .= "  macro`n  {`n"
      str .= "    activation_key: " . ele1.activationKey . "`n"
      str .= "    activation type: " . ele1.activationType . "`n"
      
      for ind2, action in ele1.actionList
      {
        if (action.actionType == "key")
        {
          str .= "    key: " . action.key . "`n"
        }
        if (action.actionType == "delay")
        {
          str .= "    delay: " . action.delay . "`n"
        }
        if (action.actionType == "click")
        {
          str .= "    click: " . action.key . ", " . action.x . ", " . action.y . "`n"
        }
      }
      
      str .= "  }`n"
    }
    
    str .= "}`n"
  }
  
  MsgBox % str
}

IsValidMacroActivationType(a_str)
{
  tag := New Tags()
  types := [tag.activationTypeHold
          , tag.activationTypeToggleOn
          , tag.activationTypeToggleOff
          , tag.activationTypeAlwaysOn
          , tag.activationTypeNumber]
  
  if (IsInArray(types, a_str))
  {
    return True 
  }
  if a_str is integer
  {
    return True
  }
  
  return False
}

GetActionList(ByRef a_file)
{
  rawLine := "DUMMY"
  tag := New Tags()
  actionList := []
  while (rawLine)
  {
    rawLine := a_file.ReadLine()
    line := Trim(rawLine, " `t`n")
    
    StringLeft, leftChar, line, 1
    if (leftChar == tag.endBlock)
    {
      break
    }
    if (leftChar == tag.comment)
    {
      continue
    }
    if (leftChar == tag.startBlock)
    {
      continue
    }
    else if (StrLen(line) < 3)
    {
      continue
    }
    
    kv := GetKeyValue(line, tag.kvDelim)
    if (kv.key == tag.actionKey)
    {
      data := New ActionData
      data.actionType := kv.key
      data.key := kv.value
      actionList.Push(data)
    }
    else if (kv.key == tag.actionDelay)
    {
      data := New ActionData
      data.actionType := kv.key
      data.delay := kv.value
      actionList.Push(data)
    }
    else if (kv.key == tag.actionClick)
    {
      items := StrSplit(kv.value, tag.arrayDelim, " `t")
      if (items.MaxIndex() != 3)
      {
        MsgBox The line: `n`t%line% is a malformed pause key. Must have the form: `n`tclick = button, x, y
      }
      else
      {
        data := New ActionData
        data.actionType := kv.key
      
        data.key := items[1]
        data.x := items[2]
        data.y := items[3]
        
        actionList.Push(data)
      }
    }
  }
  return actionList
}

GetMacro(ByRef a_file)
{
  rawLine := "DUMMY"
  tag := New Tags()
  macro := New MacroData()
  while (rawLine)
  {
    rawLine := a_file.ReadLine()
    line := Trim(rawLine, " `t`n")
    
    StringLeft, leftChar, line, 1
    if (leftChar == tag.endBlock)
    {
      break
    }
    if (leftChar == tag.comment)
    {
      continue
    }
    if (leftChar == tag.startBlock)
    {
      continue
    }
    else if (StrLen(line) < 3)
    {
      continue
    }
    
    if (line == tag.blockActionList)
    {
      macro.actionList := GetActionList(a_file)
      continue
    }
    
    kv := GetKeyValue(line, tag.kvDelim)
    if (kv.key == tag.activationKey)
    {
      macro.activationKey := kv.value
    }
    else if (kv.key == tag.activationType)
    {
      if (!IsValidMacroActivationType(kv.value))
      {
        str := "Invalid activation type: " . kv.value
        Fatal(str)
      }
      macro.activationType := kv.value
    }
  }
  return macro
}

GetBuild(ByRef a_file)
{
  rawLine := "DUMMY"
  tag := New Tags()
  obj := New BuildData()
  while (rawLine)
  {
    rawLine := a_file.ReadLine()
    line := Trim(rawLine, " `t`n")
    
    StringLeft, leftChar, line, 1
    if (leftChar == tag.endBlock)
    {
      break
    }
    if (leftChar == tag.comment)
    {
      continue
    }
    if (leftChar == tag.startBlock)
    {
      continue
    }
    else if (StrLen(line) < 3)
    {
      continue
    }
    
    if (line == tag.blockMacro)
    {
      obj.macros.Push(GetMacro(a_file))
      continue
    }
    
    kv := GetKeyValue(line, tag.kvDelim)
    if (kv.key == tag.name)
    {
      obj.name := kv.value
    }
    else if (kv.key == tag.bind)
    {
      obj.bind := kv.value
    }
    else if (kv.key == tag.numlck)
    {
      if (IsValidNumlockKey(obj.numlockKeys, kv.value))
      {
        obj.numlockKeys.Push(kv.value)
      }
    }
    else if (kv.key == tag.pse)
    {
      items := StrSplit(kv.value, tag.arrayDelim, " `t")
      if (items.MaxIndex() != 3)
      {
        MsgBox The line: `n`t%line% is a malformed pause key. Must have the form: `n`tpause = onKey, offKey, duration
      }
      else
      {
        pseKey := New PauseData()
        pseKey.pauseOn := items[1]
        pseKey.pauseOff := items[2]
        
        ;values less then 0 are considered infinite
        duration := items[3]
        
        ;-ve duration as we need SetTimer to fire a single callback
        pseKey.duration := -duration
        
        obj.pauseKeys.Push(pseKey)
      }
    }
  }
  return obj
}

BuildScript(a_fileName)
{
  file := FileOpen(a_fileName, "r`r`n")
  if !IsObject(file)
  {
    Fatal("Can't open file: " + a_fileName)
  }
  
  script := New ScriptData()
  rawLine := "DUMMY"
  
  tag := New Tags()
  
  while (rawLine)
  {
    rawLine := file.ReadLine()
    line := Trim(rawLine, " `t`n")
    
    StringLeft, leftChar, line, 1
    if (leftChar == tag.comment)
    {
      continue
    }
    else if (StrLen(line) < 3)
    {
      continue
    }
    
    if (line == tag.blockBuild)
    {
      script.builds.Push(GetBuild(file))
      continue
    }
    
    kv := GetKeyValue(line, tag.kvDelim)
    if (kv.key == tag.application)
    {
      script.application := kv.value
    }
    else if (kv.key == tag.toggleActive)
    {
      script.toggleActive := kv.value
    }
  }
  
  return script
}