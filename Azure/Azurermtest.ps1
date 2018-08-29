<#Try {
    $content = Get-AzureRmContext
    if ($content.Account -eq $null)  {
        Login-AzureRmAccount
    }
    else {
        Write-Host "You are already logged in to an AzureRm account"
        Get-AzureRmContext
    }
  } Catch {
    
  }#>

  try {
    Import-Module AzureRm
    Write-Host "AzureRm exists"
} catch {
    Write-Host "AzureRm does not exist, Installing AzureRm"
    
}
