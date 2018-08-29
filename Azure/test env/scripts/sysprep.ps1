Write-Host ""
Write-Host "==============================="
Write-Host "Starting sysprep"
Write-Host "==============================="
Write-Host ""

Unregister-ScheduledTask -TaskName sysprep -Confirm:$false

c:\Windows\System32\Sysprep\Sysprep.exe /oobe /generalize /shutdown


