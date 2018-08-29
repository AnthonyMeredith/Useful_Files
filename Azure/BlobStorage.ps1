$location = "westus"
$resourceGroup = "blobStorageRg"

New-AzureRmResourceGroup -Name $resourceGroup -Location $location

$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
  -Name "trainingimgstorage" `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind Storage

$storageContext = $storageAccount.Context

$containerName = "imagestorage"
New-AzureStorageContainer -Name $containerName -Context $storageContext -Permission blob