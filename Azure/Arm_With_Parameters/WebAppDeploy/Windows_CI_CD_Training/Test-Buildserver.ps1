#! /usr/bin/env powershell
param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroup
)

. ${PSScriptRoot}/scripts/Common.ps1

Describe "Buildserver" {
  $buildserverIP = terraform output -state="./statefiles/${ResourceGroup}.tfstate" buildserver_fqdn

  It "Should run Teamcity" {
    Get-WebsiteStatus "http://${buildserverIP}:8111/" | Should Be 200
  }

  It "Should run Octopus" {
    Get-WebsiteStatus "http://${buildserverIP}:8080/" | Should Be 200
  }
}

az vm restart --resource-group $ResourceGroup --name CICDserver

