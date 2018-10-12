
Class Action
{
  DoAction()
  {
    
  }
  
  Delay()
  {
    ;It seems we need a short delay after sending an input, otherwise we see some strange behaviour.
    ;20ms seems to be enough
    return 20
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
    return this.duration
  }
}