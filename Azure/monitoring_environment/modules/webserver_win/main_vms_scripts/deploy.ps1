Start-Transcript -Path C:\Deploy.Log


# If we've added an extra disk we need to attach and format it.

$offlinedisks = Get-Disk | Where-Object Number -gt 1 | Select-Object -ExpandProperty Number

foreach ($disk in $offlinedisks)
{
    Write-Host "Bringing disk number $disk online"
    Set-Disk -Number $disk -IsOffline $False

    Write-Host "Initializing disk number $disk"
    Initialize-Disk -Number $disk

    Write-Host "Creating default partition for disk number $disk"
    New-Partition -DiskNumber $disk -UseMaximumSize -AssignDriveLetter | Format-Volume
}

# Then we open up winRM for remote access.

winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'


netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow
net stop winrm
sc.exe config winrm start= auto
net start winrm
Set-ExecutionPolicy Unrestricted

$IISFeatures = "Web-WebServer","Web-Common-Http","Web-Default-Doc","Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content","Web-Http-Redirect","Web-Health","Web-Http-Logging","Web-Custom-Logging","Web-Log-Libraries","Web-ODBC-Logging","Web-Request-Monitor","Web-Http-Tracing","Web-Performance","Web-Stat-Compression","Web-Security","Web-Filtering","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Cert-Auth","Web-IP-Security","Web-Windows-Auth","Web-App-Dev","Web-Net-Ext","Web-Net-Ext45","Web-Asp-Net","Web-Asp-Net45","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Mgmt-Tools","Web-Mgmt-Console"
Install-WindowsFeature -Name $IISFeatures

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install webdeploy -y
choco install urlrewrite -y
choco install googlechrome -y

Remove-Item C:\inetpub\wwwroot\* -Recurse
#Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value Hello

Stop-Transcript