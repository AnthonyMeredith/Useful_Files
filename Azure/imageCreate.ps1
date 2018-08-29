$vmName =     "CICD-server"
$rgName =     "TestResourceGroup"
$imgStoreRg = "blobStorageRg"
$location =   "WestUS2"
$imageName =  "CiCdImg"

Write-Host ""
Write-Host "============================================"
Write-Host "Sysprep has been competed now creating image"
Write-Host "============================================"
Write-Host ""

Start-Sleep -Seconds 180

Write-Host "======================"
Write-Host "Deallocating VM"
Write-Host "======================"
Write-Host ""

#az vm deallocate --resource-group $rgName --name $vmName

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host "======================"
Write-Host "Generalizing VM"
Write-Host "======================"
Write-Host ""

#az vm generalize --resource-group $rgName --name $vmName

Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized

$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName
$diskID = $vm.StorageProfile.OsDisk.ManagedDisk.Id
$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsState Generalized -OsType Windows -ManagedDiskId $diskID

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""

Write-Host "======================"
Write-Host "Creating custom image"
Write-Host "======================"
Write-Host ""

#az image create --resource-group $rgName --name $imageName --source $vmName

New-AzureRmImage -ImageName $imageName -ResourceGroupName $imgStoreRg -Image $imageConfig

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

Remove-AzureRmResourceGroup -Name $rgName -Force

Write-Host ""
Write-Host "============================================"
Write-Host "done"
Write-Host "============================================"
Write-Host ""