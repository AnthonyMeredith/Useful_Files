Function Get-WebsiteStatus {
  param(
    [string]$url
  )

  try{
    $status = Invoke-WebRequest $url -TimeoutSec 10 | % {$_.StatusCode}
  }catch{
    $status = $_.Exception.Response.StatusCode.Value__
  }
  
  return $status
}
