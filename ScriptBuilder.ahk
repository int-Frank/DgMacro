
#Include Logger.ahk

;--------------------------------------------------------------------------------
; FUNCTIONS
;--------------------------------------------------------------------------------
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

DummyFunc()
{
  
}

IsValidHotKey(a_key)
{
  isValid := True
  try
  { 
   	HotKey, %a_key%, DummyFunc
   	HotKey, %a_key%, Off
  }
  catch obj
  {
    str := "Invalid key: " . a_key
    global g_Logger
    g_Logger.Warning(str)
	IsValid := False
  }
  Return isValid
}

IsValidInteger(a_val)
{
  if a_val is integer
  {
	return True
  }
  str := "Invalid integer: " . a_val
  global g_Logger
  g_Logger.Warning(str)
  return False
}
;--------------------------------------------------------------------------------
; CLASSES
;--------------------------------------------------------------------------------
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

Class DataBuilder
{
  BuildFromFile(ByRef a_file)
  {
    return True
  }
  
  BuildFromString(a_string)
  {
    return True
  }
  
  ToString()
  {
    return ""
  }
  
  WriteToFile(ByRef a_file)
  {
    a_file.Write(ToString())
  }
}

Class KeyValueBuilder extends DataBuilder
{
  static s_delim := "="
  m_key := ""
  m_value := ""
  
  GetKey()
  {
    return this.m_key 
  }
  
  GetValue()
  {
    return this.m_value 
  }
  
  BuildFromString(a_string)
  {
    isGood := True
    this.m_key := ""
    this.m_value := ""
    wordArray := StrSplit(a_string, this.s_delim, " `t")
    sze := wordArray.MaxIndex()
    if (wordArray.MaxIndex() != 2)
    {
      str := "Malformed key/value entry: " . a_string . ". Must have the form 'key " . this.s_delim . " value'"
      global g_Logger
      g_Logger.Warning(str)
      isGood := False
    }
    else
    {
      this.m_key := Trim(wordArray[1], " `n`t")
      this.m_value := Trim(wordArray[2], " `n`t")
    }
    return isGood
  }
  
  ToString()
  {
    tag := New Tags
    str := this.m_key . tag.kvDelim . this.m_value
  }
}

Class PauseBuilder extends DataBuilder
{
  m_pauseOn := ""
  m_pauseOff := ""
  m_duration := -1
  
  GetPauseOnKey()
  {
    return this.m_pauseOn 
  }
  
  GetPauseOffKey()
  {
    return this.m_pauseOff 
  }
  
  GetDuration()
  {
    return this.m_duration 
  }
  
  BuildFromTwo(a_items)
  {
    isGood := True
    validInput := IsValidHotKey(items[1])
    validInput &= IsValidHotKey(items[2])

    if (!validInput)
    {
      isGood := False
    }
    else
    {
      this.m_pauseOn := items[1]
      this.m_pauseOff := items[2]
      this.m_duration := -1
    }
    return isGood
  }
  
  BuildFromThree(a_items)
  {
    isGood := True
    validInput := IsValidHotKey(items[1])
    validInput &= IsValidHotKey(items[2])
    validInput &= IsValidInteger(items[3])
    
    if (!validInput)
    {
      isGood := False
    }
    else
    {
      this.m_pauseOn := items[1]
      this.m_pauseOff := items[2]
      
      if (items[3] < 0)
      {
        this.m_duration := -this.m_duration
      }
      else
      {
        this.m_duration := this.m_duration
      }
    }
    return isGood
  }
  
  BuildFromString(a_string)
  {
    tag := New Tags
    items := StrSplit(a_string, tag.arrayDelim, " `t")
    
    this.m_pauseOn := ""
    this.m_pauseOff := ""
    this.m_duration := -1
    
    isGood := False
    allowed := [2, 3]
    if (!IsInArray(allowed, items.MaxIndex()))
    {
      str := "Malformed pause entry: " . a_string . ". Must have the form: pause = onKey, offKey [, duration]"
      global g_Logger
      g_Logger.Warning(str)
    }
    else
    {
      if (items.MaxIndex() == 2)
      {
        isGood := this.BuildFromTwo(items)
      }
      else if (items.MaxIndex() == 3)
      {
        isGood := this.BuildFromThree(items)
      }
    }
    return isGood
  }
  
  ToString()
  {
    tag := New Tags
    str := tag.pse . tag.kvDelim . this.m_pauseOn . tag.arrayDelim . this.m_pauseOff
    if (this.m_duration != -1)
    {
      str .= tag.arrayDelim . this.m_duration 
    }
    return str
  }
}

Class ScriptOnOffBuilder extends DataBuilder
{
  m_onKey := ""
  m_offKey := ""
  
  GetOnKey()
  {
    return this.m_onKey 
  }
  
  GetOffKey()
  {
    return this.m_offKey 
  }
  
  BuildFromString(a_string)
  {
    tag := New Tags
    items := StrSplit(a_string, tag.arrayDelim, " `t")
    
    this.m_onKey := ""
    this.m_offKey := ""
    
    isGood := True
    if (items.MaxIndex() != 2)
    {
      str := "Malformed " . tag.onOff . " entry: " . a_string . ". Must have the form: on_off = onKey, offKey"
      global g_Logger
      g_Logger.Warning(str)
      isGood := False
    }
    else
    {
      validKeys := IsValidHotKey(items[1])
      validKeys |= IsValidHotKey(items[2])
      if (!validKeys)
      {
        isGood := False
      }
      else
      {
        this.m_onKey := items[1]
        this.m_offKey := items[2]
      }
    }
    return isGood
  }
  
  ToString()
  {
    tag := New Tags
    str := tag.onOff . tag.kvDelim . this.m_onKey. tag.arrayDelim . this.m_offKey
    return str
  }
}


Class ActionBuilder extends DataBuilder
{
  m_actionType := ""
  m_key := ""
  m_delay := 0
  m_x := 0
  m_y := 0
  
  GetType()
  {
    return this.m_actionType
  }
  
  GetKey()
  {
    return this.m_key
  }
  
  GetDelay()
  {
    return this.m_delay
  }
  
  GetX()
  {
    return this.m_x
  }
  
  GetY()
  {
    return this.m_y
  }
  
  BuildFromString(a_string)
  {
    tag := New Tags
    this.m_data := New ActionData
    
    this.m_actionType := ""
    this.m_key := ""
    this.m_delay := 0
    this.m_x := 0
    this.m_y := 0
    
    kv := New KeyValue
    if (!kv.BuildFromString(a_string))
    {
      return False
    }
    
    isGood := True
    if (kv.key == tag.actionKey)
    {
      this.m_actionType := kv.key
      this.m_key := kv.value
    }
    else if (kv.key == tag.actionDelay)
    {
      this.m_actionType := kv.key
      this.m_delay := kv.value
    }
    else if (kv.key == tag.actionClick)
    {
      items := StrSplit(kv.value, tag.arrayDelim, " `t")
      if (items.MaxIndex() != 3)
      {
        str := "Malformed " . tag.actionClick . " entry: " . a_string . ". Must have the form: " . tag.actionClick . " = button, x, y"
        global g_Logger
        g_Logger.Warning(str)
        isGood := False
      }
      else
      {
        this.actionType := kv.key
      
        validcoord := IsValidInteger(items[2])
        validcoord &= IsValidInteger(items[3])
      
        if (!validCoord)
        {
          isGood := False 
        }
        else
        {
          this.m_key := items[1]
          this.m_x := items[2]
          this.m_y := items[3]
        }
      }
    }
    else
    {
      str := "Unrecognised action: " . a_string
      global g_Logger
      g_Logger.Warning(str)
      isGood := False
    }
    return isGood
  }
  
  ToString()
  {
    tag := New Tags
    str := ""
    if (this.m_data.actionType == tag.actionKey)
    {
      str .=  tag.actionKey . tag.kvDelim . this.m_key
    }
    else if (this.m_data.actionType == tag.actionDelay)
    {
      str .=  tag.actionDelay . tag.kvDelim . this.m_delay
    }
    else if (this.m_data.actionType == tag.actionClick)
    {
      str .=  tag.actionClick . tag.kvDelim . this.m_key
      str .= tag.arrayDelim . this.m_x
      str .= tag.arrayDelim . this.m_y
    }
    return str
  }
}

Class ActionListBuilder extends DataBuilder
{
  m_items := []
  
  BuildFromFile(ByRef a_file)
  {
    rawLine := "DUMMY"
    tag := New Tags()
    
    this.m_items := []
    
    endOfBlockFound := False
    while (rawLine)
    {
      rawLine := a_file.ReadLine()
      line := Trim(rawLine, " `t`n")
    
      StringLeft, leftChar, line, 1
      if (leftChar == tag.endBlock)
      {
        endOfBlockFound := True
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
        ;unknown line, probably a blank line
        continue
      }
    
      actData := New ActionData
      if (actData.BuildFromString(line))
      {
        this.m_items.Push(actData) 
      }
      else
      {
        str := "Unrecognised line when building action list: " . line
        global g_Logger
        g_Logger.Warning(str)
      }
    }
    if (!endOfBlockFound)
    {
        str := "Action list not closed with a }"
        global g_Logger
        g_Logger.Warning(str)
    }
    return endOfBlockFound
  }
  
  ToString()
  {
    tag := New Tags
    str := tag.blockActionList . "`n" . tag.startBlock . "`n"
    for ind, ele in this.m_data.items
    {
      str .= ele.ToString() . "`n"
    }
    str .= tag.endBlock
  }
}

Class MacroBuilder extends DataBuilder
{
  m_activationKey := ""
  m_activationType := ""
  m_actionList := New ActionListBuilder
  
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
  
  BuildFromFile(ByRef a_file)
  {
    rawLine := "DUMMY"
    tag := New Tags()
    
    this.m_activationKey := ""
    this.m_activationType := ""
    this.m_actionList := New ActionListBuilder
    
    endOfBlockFound := False
    while (rawLine)
    {
      rawLine := a_file.ReadLine()
      line := Trim(rawLine, " `t`n")
    
      StringLeft, leftChar, line, 1
      if (leftChar == tag.endBlock)
      {
        endOfBlockFound := True
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
        ;unknown line, probably a blank line
        continue
      }
    
      if (line == tag.blockActionList)
      {
        actList := New ActionList
        if (actList.BuildFromString(a_file))
        {
          this.m_actionList := actList 
        }
        continue
      }
    
      kv := New KeyValue
      if (!kv.BuildFromString(a_string))
      {
        continue
      }
    
      if (kv.key == tag.activationKey)
      {
        if (this.IsValidHotkey(kv.value))
        {
          this.m_activationKey := kv.value
        }
        else
        {
          str := "Macro activation key not valid" . kv.value
          global g_Logger
          g_Logger.Warning(str)
        }
      }
      else if (kv.key == tag.activationType)
      {
        if (this.IsValidMacroActivationType(kv.value))
        {
          this.m_activationType := kv.value
        }
        else
        {
          str := "Invalid activation type: " . kv.value
          global g_Logger
          g_Logger.Warning(str)
        }
      }
      else
      {
        str := "Unrecognised line: " . line
        global g_Logger
        g_Logger.Warning(str)
      }
    }
    
    if (!endOfBlockFound)
    {
        str := "Macro not closed with a }"
        global g_Logger
        g_Logger.Warning(str)
    }
    return endOfBlockFound
  }
  
  ToString()
  {
    tag := New Tags
    str := tag.blockMacro . "`n" . tag.startBlock . "`n"
    str .= tag.activationKey . tag.kvDelim . this.m_activationKey . "`n"
    str .= tag.activationType . tag.kvDelim . this.m_activationType . "`n"
    str .= this.m_actionList.ToString()
  }
}


Class BuildBuilder extends DataBuilder
{
  m_name := ""
  m_bind := ""
  m_numlockKeys := []
  m_pauseKeys := []
  m_macros := []
  
  IsValidNumlockKey(a_item)
  {
    if (IsInArray(this.m_data.numlockKeys, a_item))
    {
      return False
    }
  
    allowed = ["Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5"
             , "Numpad6", "Numpad7", "Numpad8", "Numpad9", "Numpad0", "NumpadDot"
             , "NumpadDiv", "NumpadMult", "NumpadAdd", "NumpadSub", "NumpadEnter"]
    if (!IsInArray(allowed, a_item))
    {
      return False
    }
    return True
  }

  BuildFromFile(ByRef a_file)
  {
    rawLine := "DUMMY"
    tag := New Tags()
    this.m_data := New BuildData
    endBlockFound := False
    while (rawLine)
    {
      rawLine := a_file.ReadLine()
      line := Trim(rawLine, " `t`n")
    
      StringLeft, leftChar, line, 1
      if (leftChar == tag.endBlock)
      {
        endBlockFound := True
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
        this.m_data.macros.Push(GetMacro(a_file))
        continue
      }
    
      kv := GetKeyValue(line, tag.kvDelim)
      if (kv.key == tag.name)
      {
        this.m_data.name := kv.value
      }
      else if (kv.key == tag.bind)
      {
        if (this.IsValidHotkey(kv.value))
        {
          this.m_data.bind := kv.value
        }
        else
        {
          str := "Invalid Bind key for build: " . kv.value
          global g_Logger
          g_Logger.Warning(str)
        }
      }
      else if (kv.key == tag.numlck)
      {
        if (IsValidNumlockKey(kv.value))
        {
          this.m_data.numlockKeys.Push(kv.value)
        }
        else
        {
          str := "Invalid numlock key for build: " . kv.value
          global g_Logger
          g_Logger.Warning(str)
        }
      }
      else if (kv.key == tag.pse)
      {
        pseData := New PauseData
        if (pseData.BuildFromString(line))
        {
          this.m_data.pauseKeys.Push(pseData)
        }
      }
      else
      {
        str := "Unrecognised line: " . line
        global g_Logger
        g_Logger.Warning(str)
      }
    }
    if (!endOfBlockFound)
    {
      str := "Build not closed with a }"
      global g_Logger
      g_Logger.Warning(str)
    }
    return endBlockFOund
  }
  
  ToString()
  {
    return ""
  }
}

Class ScriptBuilder extends DataBuilder
{
  BuildFromString(a_fileName)
  {
    file := FileOpen(a_fileName, "r`r`n")
    if !IsObject(file)
    {
      str := "Can't open file: " + a_fileName
      global g_Logger
      g_Logger.Error(str)
      return False
    }
  
    this.m_data := New ScriptData
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
        this.m_data.builds.Push(GetBuild(file))
        continue
      }
    
      kv := GetKeyValue(line, tag.kvDelim)
      if (kv.key == tag.application)
      {
        this.m_data.application := kv.value
      }
      else if (kv.key == tag.toggleActive)
      {
        onOff := New ScriptOnOff
        if (onOff.BuildFromString(line))
        {
          this.onOff := onOff
        }
        continue
      }
    }
    return True
  }
  
  ToString()
  {
    return ""
  }
}