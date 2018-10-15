Class LoggerBase
{
  Info(a_message)
  {
	
  }
  
  Warning(a_message)
  {
	
  }
  
  Error(a_message)
  {
	
  }
  
  Critical(a_message)
  {
	
  }
}

Class LoggerCumulate
{
  m_log := ""
  
  Info(a_message)
  {
	this.m_log .= "Info: " . a_message . "`n"
  }
  
  Warning(a_message)
  {
	this.m_log .= "Warning: " . a_message . "`n"
  }
  
  Error(a_message)
  {
	this.m_log .= "Error: " . a_message . "`n"
  }
  
  Critical(a_message)
  {
	this.m_log .= "Critical: " . a_message . "`n"
  }
  
  GetLog()
  {
    return this.m_log
  }
  
  Clear()
  {
   	this.m_log := ""
  }
}