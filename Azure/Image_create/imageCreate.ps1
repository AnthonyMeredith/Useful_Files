#$imgresourceGroup
$ResourceGroup
$imageName
#$imgStoreRg
$vmName = "buildserver"

Write-Host ""
Write-Host "============================================"
Write-Host "Sysprep has been competed now creating image"
Write-Host "============================================"
Write-Host ""

#Start-Sleep -Seconds 90

Write-Host ""
Write-Host "============================================"
Write-Host "Creating new resource group to store image"
Write-Host "============================================"
Write-Host ""

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host "======================"
Write-Host "Deallocating VM"
Write-Host "======================"
Write-Host ""

az vm deallocate --resource-group $ResourceGroup --name $vmName

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host "======================"
Write-Host "Generalizing VM"
Write-Host "======================"
Write-Host ""

az vm generalize --resource-group $ResourceGroup --name $vmName

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host "======================"
Write-Host "Creating custom image"
Write-Host "======================"
Write-Host ""

az image create --resource-group $ResourceGroup --name $imageName --source $vmName

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host ""
Write-Host "============================================"
Write-Host "Deleting Resource Group"
Write-Host "============================================"
Write-Host ""

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""