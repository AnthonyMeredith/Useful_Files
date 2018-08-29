Install-Module AzureRM -Force


New-AzureRmResourceGroup webAppService -Location "West Europe"

New-AzureRmResourceGroupDeployment -ResourceGroupName 'webAppService' -TemplateFile 'C:\Users\AnthonyMeredith\Desktop\WebApp\azuredeploy.json' -TemplateParameterFile 'C:\Users\AnthonyMeredith\Desktop\WebApp\azuredeploy.parameters.json'