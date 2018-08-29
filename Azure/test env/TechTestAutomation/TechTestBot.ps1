workflow TechTestBot {
  $connectionName = "AzureRunAsConnection"
  try
  {
      # Get the connection "AzureRunAsConnection "
      $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

      "Logging in to Azure..."
      Add-AzureRmAccount `
          -ServicePrincipal `
          -TenantId $servicePrincipalConnection.TenantId `
          -ApplicationId $servicePrincipalConnection.ApplicationId `
          -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
  }
  catch {
      if (!$servicePrincipalConnection)
      {
          $ErrorMessage = "Connection $connectionName not found."
          throw $ErrorMessage
      } else{
          Write-Error -Message $_.Exception
          throw $_.Exception
      }
  }

  Select-AzureRMSubscription -SubscriptionName "Tech Test Subscription"

  $ResourceGroups = Get-AzureRmResourceGroup 

  foreach ($ResourceGroup in $ResourceGroups)
  {   
      $ResourceGroupName = $ResourceGroup.ResourceGroupName
      $test_date_tag = ($ResourceGroup.Tags | ? { $_.Name -eq "test_date"}).Value
      "Processing ${ResourceGroupName}"

      if($test_date_tag){
          
          $test_date = [DateTime]::ParseExact($test_date_tag, 'd/M/yyyy', $null)
          "Tech Test date: ${test_date}"
          
          if($test_date.Date -eq [DateTime]::Today){
              Write-Output "Starting VMs required today in resource group ${ResourceGroupName}"
              $VMs = $ResourceGroup | Get-AzureRMVM        
              Foreach -parallel ($VM in $VMs) 
              {
                $VM | Start-AzureRmVM
              }
          }
      
          if($test_date.Date -lt [DateTime]::Today){
              Write-Output "Deleting VMs in ${ResourceGroupName} that were required on $($test_date.Date)"
              $ResourceGroup | Remove-AzureRMResourceGroup -Force
          }

          if($test_date.Date -gt [DateTime]::Today){
              Write-Output "Stopping VMs in ${ResourceGroupName} that are not required until $($test_date.Date)"
              $VMs = $ResourceGroup | Get-AzureRMVM        
              Foreach -parallel ($VM in $VMs) 
              {
                $VM | Stop-AzureRmVM -Force
              }
          }
      }else{
          Write-Output "No test_date tag for ${ResourceGroupName}"
          Write-Output "Stopping VMs in ${ResourceGroupName}"
          $VMs = $ResourceGroup | Get-AzureRMVM        
          Foreach -parallel ($VM in $VMs) 
          {
              $VM | Stop-AzureRmVM -Force
          }
      }
  } 
}

