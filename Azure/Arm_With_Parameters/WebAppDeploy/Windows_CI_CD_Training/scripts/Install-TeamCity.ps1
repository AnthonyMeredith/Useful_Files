param (
  [string] $AdminPassword
)

. ${PSScriptRoot}/Common.ps1

# Set the keyboard and region settings to GB
Write-Output "Setting region and keyboard settings to GB"
Set-WinSystemLocale en-GB

Write-Output "Setting time to UK time"
Set-TimeZone -Name "GMT Standard Time"

Write-Output "Installing Chocolatey"
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Output "Installing Internet Information Services"
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

Write-Output "Installing Chrome"
choco install -y googlechrome

Write-Output "Installing Visual Studio Code"
choco install -y visualstudiocode

Write-Output "Installing tortoisegit"
choco install -y tortoisegit

Write-Output "Installing Git"
choco install -y git

Write-Output "Installing JRE"
choco install -y jre8

$PublicIP=get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1} 

$jreVersion = (Get-ChildItem "C:\Program Files\Java")[0].fullname

[Environment]::SetEnvironmentVariable( "JAVA_HOME", "$jreVersion", [System.EnvironmentVariableTarget]::Machine )

Write-Output "Installing Teamcity and PhantomJS"
choco install -y teamcity phantomjs

Write-Output "Install nuget command line"
choco install -y nuget.commandline

Write-Output "Restoring TeamCity data directory"
Expand-Archive -LiteralPath D:\scripts\TeamCity.Zip -DestinationPath C:\ProgramData\JetBrains -Force

Write-Output "Updating Teamcity root URL"
$config_file = "C:\ProgramData\JetBrains\TeamCity\config\main-config.xml"
$xml = [xml](Get-Content $config_file)
$xml.server.rootUrl = "http://${PublicIP.address[0]}:8111"
$xml.InnerXml | Out-File -FilePath $config_file -Encoding ascii

Push-Location "C:\TeamCity\webapps\ROOT\WEB-INF\lib"
Write-Output "Setting password for TeamCity user 'techtest'"
$jre = $(get-childitem "$jreVersion\bin\java.exe" -Recurse)[0].FullName
& $jre -cp 'server.jar;common-api.jar;commons-codec-1.3.jar;util.jar;hsqldb.jar;commons-codec.jar;log4j-1.2.12.jar' ChangePassword techtest $AdminPassword C:\ProgramData\JetBrains\TeamCity\
Pop-Location

Write-Output "Installing plugins"
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://plugins.jetbrains.com/plugin/download?rel=true&updateId=41430","C:\ProgramData\JetBrains\TeamCity\plugins\Octopus.TeamCity.zip")

Write-Output "Starting TeamCity"
Start-Service "TeamCity"

$TeamcityPort = 8111
$firewallRuleName = "Allow_Teamcity_HTTP"
if ((Get-NetFirewallRule -Name $firewallRuleName -ErrorAction Ignore) -eq $null)
{
  Write-Output "Creating firewall rule to allow port ${TeamcityPort} HTTP traffic ..."
  $firewallRule = @{
    Name=$firewallRuleName
    DisplayName ="Allow Port ${TeamcityPort} (HTTP)"
    Description="Port ${TeamcityPort} for HTTP traffic"
    Direction='Inbound'
    Protocol='TCP'
    LocalPort=${TeamcityPort}
    Enabled='True'
    Profile='Any'
    Action='Allow'
  }
  $output = (New-NetFirewallRule @firewallRule | Out-String)
  Write-Output $output
  Write-Output "done."
}
else
{
  Write-Output "Firewall rule to allow port ${TeamcityPort} HTTP traffic already exists."
}

$statusCode = 500

Write-Output "Clicking the 'Proceed' button on the TeamCity install UI using PhantomJS"
Write-Output "You can see the progress on http://${PublicIP}:8111/mnt - if this is taking a while, it may require manual intervention"
Write-Output "If you see COM errors, these are expected and do not cause any issues"

while($statusCode -ne 200){
  $statusCode = Get-WebsiteStatus "http://localhost:8111"
  Start-Sleep -s 30
  phantomjs "${PSScriptRoot}\Install-TeamCity.js"
}

Write-Output "Teamcity install complete"

Write-Output "Installing Visual Studio build tools"
choco install -y visualstudio2017buildtools

Write-Output "Installing Windows 8 SDK"
choco install -y windows-sdk-8.1

Write-Output "Installing TeamCity Build Agent"
choco install -y teamcityagent -params 'serverurl=http://localhost:8111' --allow-empty-checksums
