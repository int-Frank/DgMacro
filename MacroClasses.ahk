
;--------------------------------------------------------------------------------
; CALLBACKS
;--------------------------------------------------------------------------------

DoNextAction(a_obj)
{
  a_obj.__DoNextAction()
}

MacroSetState(a_isOn, a_obj)
{
  a_obj.SetState(a_isOn)
}

MacroToggleState(a_obj)
{
  a_obj.ToggleState()
}


;--------------------------------------------------------------------------------
; CLASSES
;--------------------------------------------------------------------------------

Class Macro
{
  __New()
  {
    
  }
  
  Start()
  {
    
  }
  
  Stop()
  {
    
  }
  
  Reset()
  {
    
  }
  
  ForceStart()
  {
	
  }
  
  IsActivationKey(a_key)
  {
    return False
  }
}


Class Macro_KeySpam extends Macro
{
  m_actionList := []
  m_currentAction := -1
  
  SetActionList(a_list)
  {
    this.m_actionList := a_list
    if (this.m_actionList.MaxIndex() > 0)
    {
      this.m_currentAction := 0
    }
  }
}


Class Macro_KeySpam_AlwaysOn extends Macro_KeySpam
{
  m_fDoWork := ""
  
  __New()
  {
    this.m_fDoWork := Func("DoNextAction").Bind(this)
  }
  
  __DoNextAction()
  {
    ind := this.m_currentAction + 1
    delay := -this.m_actionList[ind].Delay()
    this.m_actionList[ind].DoAction()
    this.m_currentAction := Mod((this.m_currentAction + 1), this.m_actionList.MaxIndex())
    
    funct := this.m_fDoWork
    SetTimer, %funct%, %delay%
  }
  
  Start()
  {
    if (this.m_actionList.MaxIndex() > 0)
    {
      this.__DoNextAction()
    }
  }
  
  Stop()
  {
    funct := this.m_fDoWork
    SetTimer, %funct%, Delete
    this.m_currentAction := 0
  }
}


Class Macro_KeySpam_Hold extends Macro_KeySpam
{
  m_fDoWork := ""
  m_functOn := ""
  m_functOff := ""
  m_isActive := False
  
  m_activationKey := ""
  
  __New()
  {
    this.m_fDoWork := Func("DoNextAction").Bind(this)
    this.m_functOn := Func("MacroSetState").Bind(True, this)
    this.m_functOff := Func("MacroSetState").Bind(False, this)
  }
  
  __DoNextAction()
  {
    if (!this.m_isActive)
    {
      Return 
    }
    
    ind := this.m_currentAction + 1
    delay := -this.m_actionList[ind].Delay()
    this.m_actionList[ind].DoAction()
    this.m_currentAction := Mod((this.m_currentAction + 1), this.m_actionList.MaxIndex())
    
    funct := this.m_fDoWork
    SetTimer, %funct%, %delay%
  }
  
  ForceStart()
  {
	if (this.m_actionList.MaxIndex() > 0)
	{
	  this.__DoNextAction()
	}
  }
  
  SetActivationKey(a_key)
  {
    this.m_activationKey := a_key
    
    functOn := this.m_functOn
    functOff := this.m_functOff
    key := this.m_activationKey
    HotKey, %key%, %functOn%
    HotKey, %key%, Off
    HotKey, %key% up, %functOff%
    HotKey, %key% up, Off
  }
  
  SetState(a_isOn)
  {
    this.m_isActive := a_isOn
    if (a_isOn)
    {
      if (this.m_actionList.MaxIndex() > 0)
      {
        this.__DoNextAction()
      }
      
      KeyWait, % this.m_activationKey
    }
    else
    {
      this.m_currentAction := 0
    }
  }
  
  Start()
  {
    this.m_isActive := True
    functOn := this.m_functOn
    functOff := this.m_functOff
    key := this.m_activationKey
    HotKey, %key%, %functOn%
    HotKey, %key%, On
    HotKey, %key% up, %functOff%
    HotKey, %key% up, On
  }
  
  Stop()
  {
    functOn := this.m_functOn
    functOff := this.m_functOff
    key := this.m_activationKey
    HotKey, %key%, %functOn%
    HotKey, %key% up, %functOff%
    HotKey, %key%, Off
    HotKey, %key% up, Off
    
    this.m_isActive := False
    this.m_currentAction := 0
  }
  
  IsActivationKey(a_key)
  {
    return this.m_activationKey == a_key
  }
}


Class Macro_KeySpam_Toggle extends Macro_KeySpam
{
  m_fDoWork := ""
  m_funct := ""
  m_isOn := False
  m_isActive := False
  m_isOnBase := False
  m_activationKey := ""
  
  __New()
  {
    this.m_fDoWork := Func("DoNextAction").Bind(this)
    this.m_funct := Func("MacroToggleState").Bind(this)
  }
  
  __DoNextAction()
  {
    if (this.m_isOn && this.m_isActive)
    {
      ind := this.m_currentAction + 1
      delay := -this.m_actionList[ind].Delay()
      this.m_actionList[ind].DoAction()
      this.m_currentAction := Mod((this.m_currentAction + 1), this.m_actionList.MaxIndex())
    
      funct := this.m_fDoWork
      SetTimer, %funct%, %delay%
    }
  }
  
  SetActivationKey(a_key)
  {
    this.m_activationKey := a_key
  }
  
  SetBaseState(a_isOn)
  {
    this.m_isOn := a_isOn
    this.m_isOnBase := a_isOn
  }
  
  Reset()
  {
	this.m_isOn := this.m_isOnBase
  }
  
  ToggleState()
  {
    this.m_isOn := !this.m_isOn
    if (this.m_isOn)
    {
      if (this.m_actionList.MaxIndex() > 0)
      {
        this.__DoNextAction()
      }
      
      KeyWait, % this.m_activationKey
    }
    else
    {
      this.m_currentAction := 0
    }
  }
  
  Start()
  {
    funct := this.m_funct
    key := this.m_activationKey
    HotKey, %key%, %funct%
    HotKey, %key%, On
    
    this.m_isActive := True
    if (this.m_isOn)
    {
      if (this.m_actionList.MaxIndex() > 0)
      {
        this.__DoNextAction()
      }
    }
  }
  
  Stop()
  {
    funct := this.m_funct
    key := this.m_activationKey
    HotKey, %key%, %funct%
    HotKey, %key%, Off
    
    this.m_isActive := False
    this.m_currentAction := 0
  }
}


Class Macro_KeySpam_Repeat extends Macro_KeySpam
{
  m_fDoWork := ""
  m_activationKey := ""
  m_maxCount := 0
  m_currentCount := 0
  m_isActive := False
  
  __New()
  {
    this.m_fDoWork := Func("DoNextAction").Bind(this)
  }
  
  __DoNextAction()
  {
    if (!this.m_isActive)
    {
      Return 
    }
    
    ind := this.m_currentAction + 1
    delay := -this.m_actionList[ind].Delay()
    this.m_actionList[ind].DoAction()
    
    this.m_currentAction += 1
    if (this.m_currentAction == this.m_actionList.MaxIndex())
    {
      this.m_currentAction := 0
      this.m_currentCount += 1
    }
    
    if (this.m_currentCount < this.m_maxCount)
    {
      funct := this.m_fDoWork
      SetTimer, %funct%, %delay%
    }
    else
    {
      this.m_currentAction := 0
      this.m_currentCount := 0
    }
  }
  
  SetCount(a_count)
  {
    this.m_maxCount := a_count 
  }
  
  SetActivationKey(a_key)
  {
    this.m_activationKey := a_key
  }
  
  Start()
  {
    this.m_isActive := True
    funct := this.m_fDoWork
    key := this.m_activationKey
    HotKey, %key%, %funct%
    HotKey, %key%, On
  }
  
  Stop()
  {
    funct := this.m_fDoWork
    key := this.m_activationKey
    HotKey, %key%, %funct%
    HotKey, %key%, Off
    
    this.m_isActive := False
    this.m_currentAction := 0
    this.m_currentCount := 0
  }
}