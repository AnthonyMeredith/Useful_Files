param (
  [String] $AdminPassword,
  [string] $LocalHost = "localhost"
)

. ${PSScriptRoot}/Common.ps1

Write-Host "======================================"
Write-Host "Installing Chocolatey"
Write-Host "======================================"
Write-Host ""

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Set the keyboard and region settings to GB
Write-Host "============================================="
Write-Host "Setting region and keyboard settings to GB"
Write-Host "============================================="
Write-Host ""

Set-WinSystemLocale en-GB

Write-Host "======================================"
Write-Host "Setting time to UK time"
Write-Host "======================================"
Write-Host ""

Set-TimeZone -Name "GMT Standard Time"

Write-Host "==========================================="
Write-Host "Installing Internet Information Services"
Write-Host "==========================================="
Write-Host ""

Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

Write-Host "======================================"
Write-Host "Installing Chrome"
Write-Host "======================================"
Write-Host ""

choco install -y googlechrome

Write-Host "======================================"
Write-Host "Installing Visual Studio Code"
Write-Host "======================================"
Write-Host ""

choco install -y visualstudiocode

Write-Host "======================================"
Write-Host "Installing tortoisegit"
Write-Host "======================================"
Write-Host ""

choco install -y tortoisegit

Write-Host "======================================"
Write-Host "Installing Git"
Write-Host "======================================"
Write-Host ""

choco install -y git

Write-Host "======================================"
Write-Host "Installing JRE"
Write-Host "======================================"
Write-Host ""

choco install -y jre8

$jreVersion = (Get-ChildItem "C:\Program Files\Java")[0].fullname

[Environment]::SetEnvironmentVariable( "JAVA_HOME", "$jreVersion", [System.EnvironmentVariableTarget]::Machine )

Write-Host "======================================"
Write-Host "Installing Teamcity and PhantomJS"
Write-Host "======================================"
Write-Host ""

choco install -y teamcity phantomjs

Write-Host "======================================"
Write-Host "Install nuget command line"
Write-Host "======================================"
Write-Host ""

choco install -y nuget.commandline

Write-Host "======================================"
Write-Host "Restoring TeamCity data directory"
Write-Host "======================================"
Write-Host ""

Expand-Archive -LiteralPath D:\scripts\TeamCity.Zip -DestinationPath C:\ProgramData\JetBrains -Force

Write-Host "======================================"
Write-Host "Updating Teamcity root URL"
Write-Host "======================================"
Write-Host ""

$config_file = "C:\ProgramData\JetBrains\TeamCity\config\main-config.xml"
$xml = [xml](Get-Content $config_file)
$xml.server.rootUrl = "http://${LocalHost}:8111"
$xml.InnerXml | Out-File -FilePath $config_file -Encoding ascii

Push-Location "C:\TeamCity\webapps\ROOT\WEB-INF\lib"

Write-Host "================================================"
Write-Host "Setting password for TeamCity user 'techtest'"
Write-Host "================================================"
Write-Host ""

$jre = $(get-childitem "$jreVersion\bin\java.exe" -Recurse)[0].FullName
& $jre -cp 'server.jar;common-api.jar;commons-codec-1.3.jar;util.jar;hsqldb.jar;commons-codec.jar;log4j-1.2.12.jar' ChangePassword techtest $AdminPassword C:\ProgramData\JetBrains\TeamCity\
Pop-Location
Write-Host "======================================"
Write-Host "Installing plugins"
Write-Host "======================================"
Write-Host ""

$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile("https://plugins.jetbrains.com/plugin/download?rel=true&updateId=41430","C:\ProgramData\JetBrains\TeamCity\plugins\Octopus.TeamCity.zip")

Write-Host "======================================"
Write-Host "Starting TeamCity"
Write-Host "======================================"
Write-Host ""

Start-Service "TeamCity"

$TeamcityPort = 8111
$firewallRuleName = "Allow_Teamcity_HTTP"
if ((Get-NetFirewallRule -Name $firewallRuleName -ErrorAction Ignore) -eq $null)
{
  Write-Host "========================================================================"
  Write-Host "Creating firewall rule to allow port ${TeamcityPort} HTTP traffic ..."
  Write-Host "========================================================================"
  Write-Host ""

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
  Write-Host "==========================================================================="
  Write-Host "Firewall rule to allow port ${TeamcityPort} HTTP traffic already exists."
  Write-Host "==========================================================================="
  Write-Host ""

}

$statusCode = 500

Write-Host "==========================================================================================================================="
Write-Host "Clicking the 'Proceed' button on the TeamCity install UI using PhantomJS"
Write-Host "You can see the progress on http://${LocalHost}:8111/mnt - if this is taking a while, it may require manual intervention"
Write-Host "If you see COM errors, these are expected and do not cause any issues"
Write-Host "==========================================================================================================================="
Write-Host ""


while($statusCode -ne 200){
  $statusCode = Get-WebsiteStatus "http://localhost:8111"
  Start-Sleep -s 30
  phantomjs "${PSScriptRoot}\Install-TeamCity.js"
}

Write-Host "======================================"
Write-Host "Teamcity install complete"
Write-Host "======================================"
Write-Host ""

Write-Host "======================================="
Write-Host "Installing Visual Studio build tools"
Write-Host "====================================== "
Write-Host ""

choco install -y visualstudio2017buildtools

Write-Host "======================================"
Write-Host "Installing Windows 8 SDK"
Write-Host "======================================"
Write-Host ""

choco install -y windows-sdk-8.1

Write-Host "======================================"
Write-Host "Installing TeamCity Build Agent"
Write-Host "======================================"
Write-Host ""

choco install -y teamcityagent -params 'serverurl=http://localhost:8111' --allow-empty-checksums
