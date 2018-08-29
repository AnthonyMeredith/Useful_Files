# ASOS Tech Test automation

## What this repo contains
* Terraform to create a Windows server and a MSSQL DB
* Powershell scripts to fully orchestrate the installation of TeamCity and Octopus Deploy

## Prerequisites
* [Powershell 5](https://www.microsoft.com/en-us/download/details.aspx?id=50395)
* [Terraform](https://www.terraform.io/intro/getting-started/install.html)
* [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Usage
1) Ensure you have set an environment variable TECHTEST_SUBSCRIPTION to the value of the target Azure subscription ID
2) Run `az login` to create a login session for Terraform
3) Run `.\Deploy.ps1` with the following parameters;

| Parameter           | Description                                                    | Optional? | 
|---------------------|----------------------------------------------------------------|-----------|
| ResourceGroup       | The name of the resource group to create in Azure              |    No     |    
| BuildServerPassword | The password assigned to the techtest user                     |    No     |    
| TechTestDate        | The date that the test will take place on in dd/MM/yyyy format |    No     |    

4) You can test the deployment worked by running `.\Test-BuildServer.ps1 -ResourceGroup <your resource group`
