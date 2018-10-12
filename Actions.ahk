
Class Action
{
  DoAction()
  {
    
  }
  
  Delay()
  {
    return -20
  }
}

Class Action_MouseClick extends Action
{
  x := 0
  y := 0
  button := ""
  
  DoAction()
  {
    MouseClick, % this.button, % this.x,  % this.y
  }
}

Class Action_KeyPress extends Action
{
  key := ""
  
  DoAction()
  {
    k := this.key
    SendInput {%k%}
  }
}

Class Action_Delay extends Action
{
  duration := 600
  
  DoAction()
  {
    
  }
  
  Delay()
  {
    return -this.duration
  }
}