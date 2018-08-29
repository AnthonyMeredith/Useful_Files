function Write-Log
{
  param (
    [string] $message
  )
  
  $timestamp = ([System.DateTime]::UTCNow).ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss")
  Write-Output "[$timestamp] $message"
}

function CreateSheduledTask {

  <#Write-Log ""
  Write-Log "=========================================="
  Write-Log "Moving sysprep startup script"
  Write-Log "=========================================="
  Write-Log ""

  move-item -path D:\scripts\sysprep.ps1 -destination C:\sysprep.ps1#>


  Write-Log ""
  Write-Log "=============================================="
  Write-Log "Creating sheduled task to start sysprep"
  Write-Log "=============================================="
  Write-Log ""

  $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'c:\sysprep.ps1'

  $trigger =  New-ScheduledTaskTrigger -AtStartup

  $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

  Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "sysprep" -Description "Starts sysprep"

  Write-Log ""
  Write-Log "=============================================="
  Write-Log "Sheduled task created"
  Write-Log "=============================================="
  Write-Log ""

}


try
{

  CreateSheduledTask

}
catch
{
  Write-Log $_
}