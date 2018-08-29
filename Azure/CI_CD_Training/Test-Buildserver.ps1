#! /usr/bin/env powershell
param(
  [Parameter(Mandatory=$true)]
  [String]$ResourceGroup
)

. ${PSScriptRoot}/scripts/Common.ps1

Describe "CICD" {
  $CICD_ip = terraform output -state="./statefiles/${ResourceGroup}.tfstate" CICD_fqdn

  It "Should run Teamcity" {
    Get-WebsiteStatus "http://${CICD_ip}:8111/" | Should Be 200
  }

  It "Should run Octopus" {
    Get-WebsiteStatus "http://${CICD_ip}:8080/" | Should Be 200
  }
}

#az vm restart --resource-group $ResourceGroup --name CICDserver

