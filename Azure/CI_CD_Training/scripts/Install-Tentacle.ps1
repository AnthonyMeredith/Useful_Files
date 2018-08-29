param (

    [string] $SqlUsername,
    [string] $SqlPassword,
    [string] $OctopusFingerprint
)

$downloadUrl = "https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle"
$installBasePath = "D:\Install\"
$msiPath = $installBasePath + $msiFileName
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
    
  Write-Log "Downloading Tenticle installer '$downloadUrl' to '$msiPath' ..."
  msiexec /i $downloadUrl /quiet

  Write-Log "======================================"
  Write-Log " Waiting for Tenticale to install"
  Write-Log "======================================"
  Write-Log ""
  Start-Sleep -s 5
  
  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  $exe = 'C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe'

  Write-Log "Creating Tentacle instance ..."
  $args = @(
  'create-instance', 
  '--instance', 'Tentacle', 
  '--config', 'C:\Octopus\Tentacle.config'
  )

  $output = .$exe $args
  Write-CommandOutput $output


  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  $args =@(
    'new-certificate', 
    '--instance', 'Tentacle', 
    '--if-blank'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  Write-Log "======================================"
  Write-Log "Configuring Tentacle instance ..."
  Write-Log "======================================"
  Write-Log ""

  $args = @(
    'configure', 
    '--instance', 'Tentacle', 
    '--reset-trust'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  Write-Log "======================================"
  Write-Log "Configuring Tentacle instance ..."
  Write-Log "======================================"
  Write-Log ""

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

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

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

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  Write-Log "==========================================="
  Write-Log "Reconfigure and start Tentacle instance ..."
  Write-Log "==========================================="
  Write-Log ""

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

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""

  $args =@(
    'show-thumbprint', 
    '--nologo', 
    '--console'
  )

  $output = .$exe $args
  Write-CommandOutput $output

  Write-Log "======================================"
  Write-Log "done."
  Write-Log "======================================"
  Write-Log ""
}

try
{
  Write-Log "======================================"
  Write-Log " Installing Tentalce"
  Write-Log "======================================"
  Write-Log ""
  
  Install-Tentacle -OctopusFingerprint $OctopusFingerprint 

  Write-Log "======================================"
  Write-Log "Installation successful."
  Write-Log "======================================"
  Write-Log ""
}
catch
{
  Write-Log $_
}