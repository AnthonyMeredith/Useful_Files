Write-Host ""
Write-Host "======================================"
Write-Host "Installing Chocolatey"
Write-Host "======================================"
Write-Host ""

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host ""
Write-Host "============================================="
Write-Host "Setting region and keyboard settings to GB"
Write-Host "============================================="
Write-Host ""

Set-WinSystemLocale en-GB

Write-Host ""
Write-Host "======================================"
Write-Host "Setting time to UK time"
Write-Host "======================================"
Write-Host ""

Set-TimeZone -Name "GMT Standard Time"

Write-Host ""
Write-Host "==========================================="
Write-Host "Installing Internet Information Services"
Write-Host "==========================================="
Write-Host ""

Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

Write-Host ""
Write-Host "======================================"
Write-Host "Installing Chrome"
Write-Host "======================================"
Write-Host ""

choco install -y googlechrome

Write-Host ""
Write-Host "======================================"
Write-Host "Installing Visual Studio Code"
Write-Host "======================================"
Write-Host ""

choco install -y visualstudiocode

Write-Host ""
Write-Host "======================================"
Write-Host "Installing tortoisegit"
Write-Host "======================================"
Write-Host ""

choco install -y tortoisegit

Write-Host ""
Write-Host "======================================"
Write-Host "Installing Git"
Write-Host "======================================"
Write-Host ""

choco install -y git