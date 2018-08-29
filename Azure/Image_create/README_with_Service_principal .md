# VM image creation automation

## What this repo contains
* Terraform to create a Windows server and a MSSQL DB
* Powershell scripts to fully orchestrate Sysdprep

## Prerequisites
* [Powershell 5](https://www.microsoft.com/en-us/download/details.aspx?id=50395)
* [Terraform](https://www.terraform.io/intro/getting-started/install.html)
* [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Usage
1) Ensure you have set an environment variable TECHTEST_SUBSCRIPTION to the value of the target Azure subscription ID
2) Run `az login` to create a login session for Terraform
3) Run `.\Deploy.ps1` with the following parameters;
4) DO NOT edit any of the script unless you change all related variables and names associated with the the data you are looking to edit 

| Parameter           | Description                                                                                                          | Optional? | 
|---------------------|------------------------------------------------------------------------------------------------|-----------|
| ResourceGroup              | The name of the resource group to create in Azure                        |    No     |    
| BuildServerPassword    | The password assigned to the techtest user                                     |    No     |    
| TechTestDate                  | The date that the test will take place on in dd/MM/yyyy format |    No     |
| imageName                    | The name you want to call your custom image                                |    No     |    
| $imageName					 | The name of the Image you want to use
| $client_id						 | The client Id
|  $client_secret				 | The client key
|  $subscription_id			 | The Azure subscription Id
|  $tenant_id						 | The Azure tenant id
|  $app_id							 | The application Id
|  $sp_password               | Service principal password                                                      


 