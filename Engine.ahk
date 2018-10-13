
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
DoPause(a_obj)
{
  a_obj.PauseOn()
  RequestStateChange("pauseOn")
}

DoUnpause(a_obj)
{
  a_obj.PauseOff()
  RequestStateChange("pauseOff")
}

DoUnpauseFromTimer(a_obj)
{
  a_obj.PauseOffFromTimer()
  RequestStateChange("pauseOff")
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
    g_stateData.currentBuild.Bind()
  }
  
  g_stateData.currentState := New StateOff
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
    g_stateData.currentBuild.Unbind()
    g_stateData.currentBuild := g_stateData.buildList[a_ind]
    g_stateData.currentBuild.Bind()
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
    g_stateData.currentBuild.Pause()
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

Class PauseObject
{
  m_pauseObjCollection := ""
  m_fPauseOn := ""
  m_fPauseOff := ""
  m_fOffFromTimer := ""
  m_pauseOnKey := ""
  m_pauseOffKey := ""
  m_duration := 1
  m_timerOn := False
  
  __New(a_on, a_off, a_duration, ByRef a_collection)
  {
    first := SubStr(a_on, 1, 1)
    if (first != "~")
    {
      a_on := "~" . a_on
    }
    
    first := SubStr(a_off, 1, 1)
    if (first != "~")
    {
      a_off := "~" . a_off
    }
    
    if (a_duration < 0)
    {
      this.m_duration := a_duration
    }
    
    this.m_pauseOnKey := a_on
    this.m_pauseOffKey := a_off
    this.m_fPauseOn := Func("DoPause").Bind(this)
    this.m_fPauseOff := Func("DoUnpause").Bind(this)
    this.m_fOffFromTimer := Func("DoUnpauseFromTimer").Bind(this)

    this.m_pauseObjCollection := a_collection
  }
  
  Bind()
  {
    onKey := this.m_pauseOnKey
    offKey := this.m_pauseOffKey
    fOn := this.m_fPauseOn
    fOff := this.m_fPauseOff
    Hotkey, %offKey%, %fOff%
    Hotkey, %onKey%, %fOn%
    HotKey, %offKey%, Off
    Hotkey, %onKey%, On
  }
  
  UnBind()
  {
    this.PauseOff()
    
    onKey := this.m_pauseOnKey
    offKey := this.m_pauseOffKey
    HotKey, %offKey%, Off
    Hotkey, %onKey%, Off
  }
  
  PauseOn()
  {
    for ind, ele in this.m_pauseObjCollection
    {
      ele.PauseOff()
    }
    
    onKey := this.m_pauseOnKey
    offKey := this.m_pauseOffKey
    fOff := this.m_fPauseOff
    HotKey, %onKey%, Off
    HotKey, %offKey%, %fOff%
    Hotkey, %offKey%, On
    
    if (this.m_duration < 0)
    {
      this.m_timerOn := True
      dur := this.m_duration
      fOffFromTimer := this.m_fOffFromTimer
      SetTimer, %fOffFromTimer%, %dur%
    }
  }
  
  PauseOffFromTimer()
  {
    this.m_timerOn := False
      
    onKey := this.m_pauseOnKey
    offKey := this.m_pauseOffKey
    fOn := this.m_fPauseOn
    
    HotKey, %offKey%, Off
    Hotkey, %onKey%, %fOn%
    Hotkey, %onKey%, On
  }
  
  PauseOff()
  {
    onKey := this.m_pauseOnKey
    offKey := this.m_pauseOffKey
    fOn := this.m_fPauseOn
    fOff := this.m_fPauseOff
    
    if (this.m_timerOn)
    {
      fOffFromTimer := this.m_fOffFromTimer
      SetTimer, %fOffFromTimer%, Delete
      this.m_timerOn := False
    }
    
    HotKey, %offKey%, Off
    Hotkey, %onKey%, %fOn%
    Hotkey, %onKey%, On
  }
}

Class StateData
{
  currentState := ""
  currentBuild := ""
  buildList := []
  isScriptOn := False  
}

Class Build
{
  m_pauseObjects := []
  m_numlockKeys := []
  m_macros := []
  
  __New(a_buildData)
  {
    for ind, ele in a_buildData.pauseKeys
    {
      this.m_pauseObjects.Push(New PauseObject(ele.pauseOn
                                             , ele.pauseOff
                                             , ele.duration
                                             , this.m_pauseObjects))
    }
  
    this.m_numlockKeys := a_buildData.numlockKeys
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
  
  Bind()
  {
    this.__BindPauseKeys()
  }
  
  Unbind()
  {
    this.__UnbindPauseKeys()
  }
  
  Start()
  {
    this.__TurnNumlockKeysOn()
    this.__StartMacros()
  }
  
  Stop()
  {
    this.__TurnNumlockKeysOff()
    this.__StopMacros()
    this.__ResetMacros()
  }
  
  Pause()
  {
    this.__StopMacros()
    this.__TurnNumlockKeysOff()
  }
  
  Unpause()
  {
    ;Something useful might go in here
  }
  
  ;----- private -----------------------------------------------------
  
  __BindPauseKeys()
  {
    for ind, ele in this.m_pauseObjects
    {
      ele.Bind()
    }
  }
  
  __UnbindPauseKeys()
  {
    for ind, ele in this.m_pauseObjects
    {
      ele.Unbind()
    }
  }
  
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
}
