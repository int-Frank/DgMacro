
#Include ScriptData.ahk
#Include Actions.ahk
#Include MacroClasses.ahk

;--------------------------------------------------------------------------------
; GLOBALS
;--------------------------------------------------------------------------------
g_stateData := ""

;--------------------------------------------------------------------------------
; CALLBACKS
;--------------------------------------------------------------------------------
RequestPause(a_key)
{
  RequestStateChange("pauseOn", a_key)
}

RequestUnpause()
{
  RequestStateChange("pauseOff")
}

CancelPause(a_key)
{
  RequestStateChange("pauseOff", a_key)
  global g_stateData
  g_stateData.currentBuild.Unpause(a_key)
}

RequestStateChange(a_state, a_data := 0)
{
  global g_stateData
  g_stateData.currentState := g_stateData.currentState.NewState(a_state, a_data)
}

ToggleScript()
{
  global g_stateData
  if (g_stateData.isScriptOn)
  {
    RequestStateChange("StateOff", 0)
  }
  else
  {
    RequestStateChange("StateOn", 0)
  }
}

ChangeBuild(a_val)
{
  global g_stateData
  g_stateData.currentState.SwitchBuild(a_val)
}

;--------------------------------------------------------------------------------
; FUNCTIONS
;--------------------------------------------------------------------------------
InitAndRun(a_scriptData)
{
  global g_stateData
  g_stateData := New StateData()

  ;Add app specific hotkeying
  appName := a_scriptData.application
  GroupAdd, Group, %appName%
  Hotkey, IfWinActive, ahk_group Group

  ;Script toggle
  HotKey, % a_scriptData.toggleActive, ToggleScript
  
  ;Switch builds
  for ind, ele in a_scriptData.builds
  {
    funct := Func("ChangeBuild").Bind(ind)
    bindKey := ele.bind
    HotKey, %bindKey%, %funct%
    
    g_stateData.buildList.Push(New Build(ele))
  }
  
  if (g_stateData.buildList.MaxIndex() > 0)
  {
    g_stateData.currentBuild :=  g_stateData.buildList[1]
  }
}

BuildActionList(a_data)
{
  result := []
  for ind, ele in a_data
  {
    if (ele.actionType == "key")
    {
      act := New Action_KeyPress()
      act.key := ele.key
      result.Push(act)
    }
    else if (ele.actionType == "delay")
    {
      act := New Action_Delay()
      act.duration := ele.delay
      result.Push(act)
    }
    else if (ele.actionType == "click")
    {
      act := New Action_MouseClick()
      act.x := ele.x
      act.y := ele.y
      act.button := ele.key
      result.Push(act)
    }
  }
  return result
}

;--------------------------------------------------------------------------------
; SCRIPT STATES
;--------------------------------------------------------------------------------
Class BaseState
{
  __New(a_data)
  {
  
  }

  __Delete()
  {
  
  }
  
  NewState(a_state, a_data)
  {
	
  }
	
  SwitchBuild(a_ind)
  {
  
  }
}
  
Class StateOff extends BaseState
{
  __New(a_data)
  {
    global g_stateData
    g_stateData.isScriptOn := False
    g_stateData.currentBuild.Stop()
  }
	
  NewState(a_state, a_data)
  {
    newState := This
    if (a_state == "StateOn")
    {
      newState := New StateOn(a_data)
    }
    return newState
  }
	
  SwitchBuild(a_ind)
  {
    global g_stateData
    g_stateData.currentBuild := g_stateData.buildList[a_ind]
  }
}
  
Class StateOn extends BaseState
{
  __New(a_data)
  {
    global g_stateData
    g_stateData.isScriptOn := True
    g_stateData.currentBuild.Start()
  }
	
  NewState(a_state, a_data)
  {
    newState := This
    if (a_state == "StateOff")
    {
      newState := New StateOff(a_data)
    }
    else if (a_state == "pauseOn")
    {
      newState := New StatePause(a_data)
    }
    return newState
  }
}

Class StatePause extends BaseState
{
  __New(a_data)
  {
    global g_stateData
    g_stateData.currentBuild.Pause(a_data)
  }
	
  __Delete()
  {
    
  }
  
  NewState(a_state, a_data)
  {
    newState := This
    if (a_state == "pauseOff")
    {
      newState := New StateOn(a_data)
    }
    else if (a_state == "StateOff")
    {
      newState := New StateOff(a_data)
    }
    return newState
  }
}

;--------------------------------------------------------------------------------
; OTHER CLASSES
;--------------------------------------------------------------------------------
Class StateData
{
  currentState := New StateOff
  currentBuild := ""
  buildList := []
  isScriptOn := False  
}

Class Build
{
  m_currentUnpauseFuncts := []
  m_pauseKeys := []
  m_numlockKeys := []
  m_macros := []
  
  __New(a_buildData)
  {
    this.m_pauseKeys := a_buildData.pauseKeys
    this.m_numlockKeys := a_buildData.numlockKeys
    this.__BindPauseKeys()
    tag := New Tags
    for ind, ele in a_buildData.macros
    {
      actionList :=  BuildActionList(ele.actionList)
      if (ele.activationType == tag.activationTypeAlwaysOn)
      {
        macro := New Macro_KeySpam_AlwaysOn
        macro.SetActionList(actionList)
        this.m_macros.Push(macro)
      }
      else if (ele.activationType == tag.activationTypeHold)
      {
        macro := New Macro_KeySpam_Hold
        macro.SetActionList(actionList)
        macro.SetActivationKey(ele.activationKey)
        this.m_macros.Push(macro)
      }
      else if (ele.activationType == tag.activationTypeToggleOn Or ele.activationType == tag.activationTypeToggleOff)
      {
        macro := New Macro_KeySpam_Toggle
        macro.SetActionList(actionList)
        macro.SetActivationKey(ele.activationKey)
        
        if (ele.activationType == tag.activationTypeToggleOn)
        {
          macro.SetBaseState(True) 
        }
        else
        {
          macro.SetBaseState(False) 
        }
        
        this.m_macros.Push(macro)
      }
      else
      {
        macro := New Macro_KeySpam_Repeat
        macro.SetActionList(actionList)
        macro.SetActivationKey(ele.activationKey)
        macro.SetCount(ele.activationType)
        this.m_macros.Push(macro)
      }
    }
  }
  
  Start()
  {
    this.__BindPauseKeys()
    this.__TurnNumlockKeysOn()
    this.__StartMacros()
    
    ;SetTimer, RequestUnpause, Delete
  }
  
  Stop()
  {
    this.__UnbindPauseKeys()
    this.__TurnNumlockKeysOff()
    this.__StopMacros()
    this.__ResetMacros()
  }
  
  Pause(a_key)
  {
    this.__UnbindPauseKeys()
    this.__StopMacros()
    this.__TurnNumlockKeysOff()
    
    for ind, ele in this.m_pauseKeys
    {
      if (ele.pauseOn == a_key)
      {
        funct := Func("CancelPause").Bind(ele.pauseOff)
        pseOff := "~" . ele.pauseOff
        Hotkey, %pseOff%, %funct%
        Hotkey, %pseOff%, On
        
        if (ele.duration < 0)
        {
          funct := Func("RequestUnpause")
          SetTimer, %funct%, % ele.duration
        }
        break
      }
    }
  }
  
  Unpause(a_key)
  {
    ;Try to fire the unpause key in case it's used by any other macro 
    for ind, ele in this.m_macros
    {
      if (ele.IsActivationKey(a_key))
      {
        ele.ForceStart()
      }
    }
  }
  
  ;----- private -----------------------------------------------------
  
  __StartMacros()
  {
    for ind, ele in this.m_macros
    {
      ele.Start() 
    }
  }
  
  __StopMacros()
  {
    for ind, ele in this.m_macros
    {
      ele.Stop() 
    }
  }
  
  __ResetMacros()
  {
    for ind, ele in this.m_macros
    {
      ele.Reset() 
    }
  }
  
  __TurnNumlockKeysOn()
  {
    SetNumLockState, On
    for ind, ele in this.m_numlockKeys
    {
      SendInput {%ele% down}
    }
    SetNumLockState, Off
  }
  
  __TurnNumlockKeysOff()
  {
    SetNumLockState, On
    for ind, ele in this.m_numlockKeys
    {
      SendInput {%ele% up}
    }
  }
  
  __BindPauseKeys()
  {
    for ind, ele in this.m_pauseKeys
    {
      pseOn := "~" . ele.pauseOn
      pseOff := "~" . ele.pauseOff
      functOn := Func("RequestPause").Bind(ele.pauseOn)
      functOff := Func("RequestUnpause")
      Hotkey, %pseOff%, %functOff%
      Hotkey, %pseOff%, Off
      Hotkey, %pseOn%, %functOn%
      Hotkey, %pseOn%, On
    }
  }
  
  __UnbindPauseKeys()
  {
    for ind, ele in this.m_pauseKeys
    {
      pseOn := "~" . ele.pauseOn
      pseOff := "~" . ele.pauseOff
      Hotkey, %pseOn%, Off
      Hotkey, %pseOff%, Off
    }
  }
}
