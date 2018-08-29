. ${PSScriptRoot}/Common.ps1

Write-Host "======================================"
Write-Host "Installing Chocolatey"
Write-Host "======================================"
Write-Host ""

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Write-Host "======================================"
Write-Host "Installing Chrome"
Write-Host "======================================"
Write-Host ""

choco install -y Firefox

Restart-Computer -Force
