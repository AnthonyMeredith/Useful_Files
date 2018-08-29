function Write-Log
{
  param (
    [string] $message
  )
  
  $timestamp = ([System.DateTime]::UTCNow).ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss")
  Write-Output "[$timestamp] $message"
}

function Set-ServiceStartupType
{

  $hostname = hostname
  Start-Sleep -Seconds 10

  Write-Log ""
  Write-Log "==================================================="
  Write-log "Changing service startup types to automatic delayed"
  Write-Log "==================================================="
  Write-Log ""

  Write-Log ""
  Write-Log "========================================================="
  Write-log "Changing Octopus Deploy startup type to automatic delayed"
  Write-Log "========================================================="
  Write-Log ""

  SC.EXE \\$hostname Config 'OctopusDeploy' Start= Delayed-Auto

  Start-Sleep -Seconds 10

  Write-Log ""
  Write-Log "==================================================="
  Write-log "Changing Tentacle startup type to automatic delayed"
  Write-Log "==================================================="
  Write-Log ""

  SC.EXE \\$hostname Config 'OctopusDeploy Tentacle'  Start= Delayed-Auto

}

function CreateSheduledTask {
  
  Write-Log ""
  Write-Log "=========================================="
  Write-log "Service startup type successfully changed"
  Write-Log "=========================================="
  Write-Log ""

  Write-Log ""
  Write-Log "=========================================="
  Write-Log "Moving startup script"
  Write-Log "=========================================="
  Write-Log ""

  move-item -path D:\scripts\OctoStart.ps1 -destination C:\OctoStart.ps1
  move-item -path D:\scripts\StartTask.ps1 -destination C:\StartTask.ps1

  Write-Log ""
  Write-Log "=============================================="
  Write-Log "Creating sheduled task to start OctopusDeploy"
  Write-Log "=============================================="
  Write-Log ""

  $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\StartTask.ps1'

  $trigger =  New-ScheduledTaskTrigger -AtStartup

  $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

  Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "Start Task" -Description "Starts Octo Start task"

  $action1 = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument 'C:\OctoStart.ps1'

  $trigger1 =  New-ScheduledTaskTrigger -AtStartup

  #$principal = New-ScheduledTaskPrincipal -UserID $env:UserName -LogonType ServiceAccount -RunLevel Highest

  Register-ScheduledTask -Action $action1 -Trigger $trigger1 -User "$env:USERDOMAIN\$env:USERNAME" -Password 'Password1234' -TaskName "Octopus Start" -Description "restart octopus deploy"  

  Write-Log ""
  Write-Log "=============================================="
  Write-Log "Sheduled task created"
  Write-Log "=============================================="
  Write-Log ""

}


try
{
  Write-Log ""
  Write-Log "=================================================="
  Write-Log " Changing Service configuration for Octopus Deploy"
  Write-Log "=================================================="
  Write-Log ""
  
  Set-ServiceStartupType
  CreateSheduledTask

  Write-Log ""
  Write-Log "======================================"
  Write-Log "Service configuration successful."
  Write-Log "======================================"
  Write-Log ""

}
catch
{
  Write-Log $_
}