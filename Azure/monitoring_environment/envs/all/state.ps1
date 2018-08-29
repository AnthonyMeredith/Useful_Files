
$rel_env = $env:RELEASE_ENVIRONMENTNAME
$arm_subscription_id = $env:ARM_SUBSCRIPTION_ID
$arm_client_id       = $env:ARM_CLIENT_ID
$arm_client_secret   = $env:ARM_CLIENT_SECRET
$arm_tenant_id       = $env:ARM_TENANT_ID

$resource_group_name  = "alex-glo-tfstate"
$storage_account_name = "alexglotfstate"
$container_name       = "alex-glo-tfstate"
$key                  = "alex-$rel_env-tfstate.tfstate"

$output = @"
terraform {
    backend "azurerm" {
      arm_subscription_id = "$arm_subscription_id"
      arm_client_id       = "$arm_client_id"
      arm_client_secret   = "$arm_client_secret"
      arm_tenant_id       = "$arm_tenant_id"
  
      resource_group_name  = "$resource_group_name"
      storage_account_name = "$storage_account_name"
      container_name       = "$container_name"
      key                  = "$key"
    }
  }
"@

Out-File -FilePath state.tf -InputObject $output -Encoding ASCII