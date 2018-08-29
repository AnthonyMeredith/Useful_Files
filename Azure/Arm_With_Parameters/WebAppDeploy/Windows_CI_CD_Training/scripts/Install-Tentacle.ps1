param (

    [string] $SqlUsername,
    [string] $SqlPassword,
    [string] $OctopusFingerprint
)

$downloadUrl = "https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle"
$installBasePath = "D:\Install\"
$msiPath = $installBasePath + $msiFileName
$TentacleFingerprintOutfile = "C:\Users\techtest\Desktop\Tenticle_Fingerprint.txt"
$OFS = "`r`n"

function Write-Log
{
  param (
    [string] $message
  )
  
  $timestamp = ([System.DateTime]::UTCNow).ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss")
  Write-Output "[$timestamp] $message"
}

function Write-CommandOutput 
{
  param (
    [string] $output
  )    
  
  if ($output -eq "") { return }
  
  Write-Output ""
  $output.Trim().Split("`n") |% { Write-Output "`t| $($_.Trim())" }
  Write-Output ""
}

function Install-Tentacle
{

  param (
      [Parameter(Mandatory=$True,
	    ValueFromPipeline=$True)]
	    [string[]] $OctopusFingerprint
  )

  Write-Log "======================================"
  Write-Log " Install Tentacle"
  Write-Log ""
    
  Write-Log "Downloading Tenticle installer '$downloadUrl' to '$msiPath' ..."
  msiexec /i $downloadUrl /quiet

  Write-Log "======================================"
  Write-Log " Waiting for Tenticale to install"
  Start-Sleep -s 5
  Write-Log "done."

  $exe = 'C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe'

  Write-Log "Creating Tentacle instance ..."
  $args = @(
  'create-instance', 
  '--instance', 'Tentacle', 
  '--config', 'C:\Octopus\Tentacle.config'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  $args =@(
    'new-certificate', 
    '--instance', 'Tentacle', 
    '--if-blank'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "Configuring Tentacle instance ..."
  $args = @(
    'configure', 
    '--instance', 'Tentacle', 
    '--reset-trust'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "Configuring Tentacle instance ..."
  $args = @(
    'configure', 
    '--instance', 'Tentacle', 
    '--app', 'C:\Octopus\Applications', 
    '--port', '10933', 
    '--noListen', 'False',
    '--trust', $octopusFingerprint
  )

  $output = .$exe $args
  Write-CommandOutput $output

  netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933

  $args = @(
    'service', 
    '--instance', 'Tentacle', 
    '--install', 
    '--stop', 
    '--start'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "Reconfigure and start Tentacle instance ..."
  $args = @(
    'service', 
    '--reconfigure', 
    '--start',
    '--dependOn', 'MSSQLSERVER', 
    '--username', $SqlUsername, 
    '--password', $SqlPassword
  )
  $output = .$exe $args
  Write-CommandOutput $output

  $args =@(
    'show-thumbprint', 
    '--nologo', 
    '--console'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "done."
  Write-Log ""
}

try
{
  Write-Log "======================================"
  Write-Log " Installing Tentalce"
  Write-Log "======================================"
  Write-Log ""
  
  Install-Tentacle -OctopusFingerprint $OctopusFingerprint 

  Write-Log "Installation successful."
  Write-Log ""
}
catch
{
  Write-Log $_
}

