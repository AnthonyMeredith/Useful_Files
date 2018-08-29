#! /usr/bin/env powershell
param(
  [Parameter(Mandatory=$true)]
  [String] $ResourceGroup,
  [switch] $Login,
  [String] $BuildServerPassword,
  [String]$TechTestDate
)

try{

  [DateTime]::ParseExact($TechTestDate, 'd/M/yyyy', $null)

}catch{

  Throw "Parameter 'TechTestDate' should be in the format d/M/yyyy"
  break

}

$dependencies = $('terraform','az')

foreach ($dependency in $dependencies){
  if (-not (Get-Command $dependency -errorAction SilentlyContinue))
  {
      throw "$dependency is not installed. Run the bootstrap script for your operating system."
  }
}

$adminPublicIP = Invoke-RestMethod -Uri http://ipv4bot.whatismyipaddress.com/ -Method Get;

Write-Output "Checking login status"
az vm list 2>&1 > $null
if(-not ($?)){
  Write-Output Generating auth code...
  az login
}

if( -not (Test-Path env:/AZURE_TECHTEST_SUBSCRIPTION)){
  throw "Set the value of `$ENV:AZURE_TECHTEST_SUBSCRIPTION to the ID of the techtest subscription"
}
az account set --subscription="${ENV:AZURE_TECHTEST_SUBSCRIPTION}"

rm $PSScriptRoot/.terraform -Recurse -Force -ErrorAction SilentlyContinue
terraform init terraform/

New-Item -Item Directory statefiles -ErrorAction SilentlyContinue
terraform apply -auto-approve -var "resourcegroup_name=$ResourceGroup" -var "buildserver_password=${BuildServerPassword}" -var "sql_password=${BuildServerPassword}" -var "admin_public_ip=${adminPublicIP}" -var "test_date=${TechTestDate}" -state "$PSScriptRoot/statefiles/$ResourceGroup.tfstate" ./terraform/ *>&1 | Tee-Object -file "${ResourceGroup}.log"

& ${PSScriptRoot}/Test-Buildserver.ps1 -ResourceGroup $ResourceGroup
do
{
    $test = az vm list -g $ResourceGroup -d --query "[?powerState=='VM stopped']"
	if($test -eq "[]")
	{
       	   Write-Host "VM is not stopped"
           Start-Sleep -s 60
	}
	else 
	{
           Write-Host "VM is stopped, creating image"  
           Start-Sleep -s 90
	   ./imageCreate.ps1 -recourceGroup $ResourceGroup -imageName $imageName -imgStoreRg $imgStoreRg  
	}
}while($test -eq "[]")