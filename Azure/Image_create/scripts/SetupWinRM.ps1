Start-Transcript -Path C:\SetupWinRM.log

Write-Host "Setup WinRM for $RemoteHostName"

winrm quickconfig -q

Write-Host "Set Maximum Timeout"
$Timeout = "@{MaxTimeoutms=`"1800000`"}"
winrm set winrm/config $Timeout

Write-Host "Allow unencrypted traffic"
$AllowUnencrypted = "@{AllowUnencrypted=`"true`"}"
winrm set winrm/config/service $AllowUnencrypted

Write-Host "Set Basic Auth in WinRM"
$WinRmBasic = "@{Basic=`"true`"}"
winrm set winrm/config/service/Auth $WinRmBasic

Stop-Transcript

