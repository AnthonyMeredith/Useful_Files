param (
  [string] $SqlUsername,
  [string] $SqlPassword,
  [string] $OctopusAdminUsername,
  [string] $OctopusAdminPassword,
  [string] $LicenseFullName="techtest",
  [string] $LicenseOrganisationName="DevOpsGuys",
  [string] $LicenseEmailAddress="techtest@devopsguys.com",
  [string] $octopusServiceUsername = ".\packer",
  [string] $PackerPassword,
  [int16]  $OctopusPort=8080,
  [int16]  $OctopusDomain=127.0.0.1
)

#$SqlDbConnectionStringLogon = "Data Source=(local);Initial Catalog=octopus-db;Persist Security Info=False;User ID=${SqlUsername};Password=${SqlPassword};Connection Timeout=300;"
#$InitSqlDbConnectionString = "Data Source=(local);Initial Catalog=master;Persist Security Info=False;Trusted_Connection=yes;Connection Timeout=300;"
#$SqlDbConnectionString = "Data Source=(local);Initial Catalog=octopus-db;Persist Security Info=False;Trusted_Connection=yes;Connection Timeout=300;"
#$SqlDbConnectionString = "Data Source=(local);Initial Catalog=octopus-db;Integrated Security=True;User ID=buildserver\techtest;Password=Password1234"
$SqlDbConnectionString = "Data Source=(local);Initial Catalog=octopus-db;Integrated Security=False;User ID=${SqlUsername};Password=${SqlPassword}"
$config = @{}
$octopusDeployVersion = "Octopus.3.17.13-x64"
$msiFileName = "Octopus.3.17.13-x64.msi"
$downloadBaseUrl = "https://download.octopusdeploy.com/octopus/"
$downloadUrl = $downloadBaseUrl + $msiFileName
$installBasePath = "D:\Install\"
$msiPath = $installBasePath + $msiFileName
$msiLogPath = $installBasePath + $msiFileName + '.log'
$installerLogPath = $installBasePath + 'Install-OctopusDeploy.ps1.log'
$octopusLicenseUrl = "https://octopusdeploy.com/api/licenses/trial"
$octopusFingerprint = ""
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
function Get-Config
{
  Write-Log "======================================"
  Write-Log " Get Config"
  Write-Log ""
  Write-Log "Parsing script parameters ..."
  $config.Add("sqlDbConnectionString", $SqlDbConnectionString)
  $config.Add("licenseFullName", $LicenseFullName)
  $config.Add("licenseOrganisationName", $LicenseOrganisationName)
  $config.Add("licenseEmailAddress", $LicenseEmailAddress)
  $config.Add("octopusAdminUsername", $OctopusAdminUsername)
  $config.Add("octopusAdminPassword", $OctopusAdminPassword)
  Write-Log "connection string = $SqlDbConnectionString"
  Write-Log "done."
  Write-Log ""
}
function Create-InstallLocation
{
  Write-Log "======================================"
  Write-Log " Create Install Location"
  Write-Log ""
  if (!(Test-Path $installBasePath))
  {
    Write-Log "Creating installation folder at '$installBasePath' ..."
    New-Item -ItemType Directory -Path $installBasePath | Out-Null
    Write-Log "done."
  }
  else
  {
    Write-Log "Installation folder at '$installBasePath' already exists."
  }
  Write-Log ""
}
function Install-OctopusDeploy
{
  Write-Log "======================================"
  do {
    $Service = Get-Service -Name MSSQLSERVER
    Write-Host $service.Status
    if ($Service.status -ne "Running") {
        Write-Host "service not running"
          Start-Sleep -s 30
    }
    else {
          Write-Host "service is running"
    }
  }while ($Service.Status -ne "Running")
  do {
    $Service = Get-Service -Name WindowsAzureTelemetryService
    Write-Host $service.Status
    if ($Service.status -ne "Running") {
        Write-Host "service not running"
          Start-Sleep -s 60
    }
    else {
          Write-Host "service is running"
    }
  }while ($Service.Status -ne "Running")
  do {
    $Service = Get-Service -Name UALSVC
    Write-Host $service.Status
    if ($Service.status -ne "Running") {
        Write-Host "service not running"
          Start-Sleep -s 60
    }
    else {
          Write-Host "service is running"
    }
  }while ($Service.Status -ne "Running")
  do {
    $Service = Get-Service -Name MSDTC
    Write-Host $service.Status
    if ($Service.status -ne "Running") {
        Write-Host "service not running"
          Start-Sleep -s 60
    }
    else {
          Write-Host "service is running"
    }
  }while ($Service.Status -ne "Running")
  Write-Log "======================================"
  Write-Log " Install Octopus Deploy"
  Write-Log ""
  Write-Log "Downloading Octopus Deploy installer '$downloadUrl' to '$msiPath' ..."
  (New-Object Net.WebClient).DownloadFile($downloadUrl, $msiPath)
  Write-Log "done."
  Write-Log "Installing via '$msiPath' ..."
  $exe = 'msiexec.exe'
  $args = @(
    '/qn',
    '/i', $msiPath,
    '/l*v', $msiLogPath
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log ""
}
function Configure-OctopusDeploy
{
  Write-Log "======================================"
  Write-Log " Configure Octopus Deploy"
  Write-Log ""
  $exe = 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe'
  $count = 0
  while(!(Test-Path $exe) -and $count -lt 5)
  {
    Write-Log "$exe - not available yet ... waiting 10s ..."
    Start-Sleep -s 10
    $count = $count + 1
  }
  Write-Log "Creating Octopus Deploy instance ..."
  $args = @(
    'create-instance',
    '--instance', 'OctopusServer',
    '--config', 'C:\Octopus\OctopusServer.config'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Configuring Octopus Deploy instance ..."
  $args = @(
    'configure',
    '--instance', 'OctopusServer',
    '--home', 'C:\Octopus',
    '--storageConnectionString', $($config.sqlDbConnectionString),
    '--upgradeCheck', 'True',
    '--upgradeCheckWithStatistics', 'True',
    '--webAuthenticationMode', 'UsernamePassword',
    '--webForceSSL', 'False',
    '--webListenPrefixes', "http://${OctopusDomain}:${OctopusPort}/",
    '--commsListenPort', '10943'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Creating Octopus Deploy database ..."
  $args = @(
    'database',
    '--instance', 'OctopusServer',
    '--connectionString', $SqlDbConnectionString,
    '--create',
    '--grant', $SqlUsername
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Stopping Octopus Deploy instance ..."
  $args = @(
    'service',
    '--instance', 'OctopusServer',
    '--stop'
  )
  $output = .$exe $args
  sc.exe config "octopusdeploy" $OctopusServiceUsername password= $PackerPassword
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Creating Admin User for Octopus Deploy instance ..."
  $args = @(
    'admin',
    '--instance', 'OctopusServer',
    '--username', $($config.octopusAdminUserName),
    '--password', $($config.octopusAdminPassword)
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Obtaining a trial license for Full Name: $($config.licenseFullName), Organisation Name: $($config.licenseOrganisationName), Email Address: $($config.licenseEmailAddress) ..."
  $postParams = @{ FullName="$($config.licenseFullName)";Organization="$($config.licenseOrganisationName)";EmailAddress="$($config.licenseEmailAddress)" }
  $response = Invoke-WebRequest -UseBasicParsing -Uri "$octopusLicenseUrl" -Method POST -Body $postParams
  $utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
  $bytes  = $utf8NoBOM.GetBytes($response.Content)
  $licenseBase64 = [System.Convert]::ToBase64String($bytes)
  Write-Log "done."
  Write-Log "Installing license for Octopus Deploy instance ..."
  $args = @(
    'license',
    '--console',
    '--instance', 'OctopusServer',
    '--licenseBase64', $licenseBase64
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log "Reconfigure and start Octopus Deploy instance ..."
  $hostname = hostname
  $args = @(
    'service',
    '--instance', 'OctopusServer',
    '--install',
    '--reconfigure',
    '--start',
    '--dependOn', 'MSSQLSERVER',
    '--username', "$hostname\packer",
    '--password', $PackerPassword
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  Write-Log ""
}
function Configure-Firewall
{
  Write-Log "======================================"
  Write-Log " Configure Firewall"
  Write-Log ""
  $firewallRuleName = "Allow_Octopus_HTTP"
  if ((Get-NetFirewallRule -Name $firewallRuleName -ErrorAction Ignore) -eq $null)
  {
    Write-Log "Creating firewall rule to allow port ${OctopusPort} HTTP traffic ..."
    $firewallRule = @{
      Name=$firewallRuleName
      DisplayName ="Allow Port ${OctopusPort} (HTTP)"
      Description="Port ${OctopusPort} for HTTP traffic"
      Direction='Inbound'
      Protocol='TCP'
      LocalPort=${OctopusPort}
      Enabled='True'
      Profile='Any'
      Action='Allow'
    }
    $output = (New-NetFirewallRule @firewallRule | Out-String)
    Write-CommandOutput $output
    Write-Log "done."
  }
  else
  {
    Write-Log "Firewall rule to allow port ${OctopusPort} HTTP traffic already exists."
  }
  Write-Log ""
}
function OctoFingerprint {
  $exe = 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe'
  $args =@(
    'show-thumbprint',
    '--nologo',
    '--console'
  )
  $octopusFingerprint = .$exe $args
  return $octopusFingerprint
}
function Create-SQLUserAccount {
  ## Add Assemblies 
  Add-Type -AssemblyName "Microsoft.SqlServer.ConnectionInfo, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
  Add-Type -AssemblyName "Microsoft.SqlServer.Smo, Version=12.0.0.0,Culture=neutral,PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop 
  Add-Type -AssemblyName "Microsoft.SqlServer.SMOExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
  Add-Type -AssemblyName "Microsoft.SqlServer.SqlEnum, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
  Add-Type -AssemblyName "Microsoft.SqlServer.Management.Sdk.Sfc, Version=12.0.0.0,Culture=neutral, PublicKeyToken=89845dcd8080cc91" -ErrorAction Stop
  # Connect to the SQL Server 
  $sqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $env:hostname
  # Enable sql auth
  $sqlServer.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
  $sqlServer.Alter()
  # Creating SQL auth login
  $SQLLogin = [Microsoft.SqlServer.Management.Smo.Login]::New($sqlServer, "$SqlUsername")
  $SQLLogin.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
  $SQLLogin.PasswordPolicyEnforced = $False
  $SQLLogin.Create("$SqlPassword")
  $SQLLogin.AddToRole("sysadmin")
  $SQLLogin.Alter()
}
try
{
  Write-Log "======================================"
  Write-Log " Installing '$octopusDeployVersion'"
  Write-Log "======================================"
  Write-Log ""
  #Start-Sleep -Seconds 420
  $hostname = hostname
  Import-Module D:\scripts\UserRights.psm1
  Grant-UserRight -Account "$hostname\packer" -Right SeServiceLogonRight 
  Get-Config
  Create-InstallLocation
  Create-SQLUserAccount
  Install-OctopusDeploy
  Configure-OctopusDeploy
  Configure-Firewall
  $octopusFingerprint = OctoFingerprint
  D:\scripts\Install-Tentacle.ps1 -OctopusFingerprint $octopusFingerprint -SqlUsername $SqlUsername -SqlPassword $SqlPassword
  Write-Log "Installation successful."
  Write-Log ""
}
catch
{
  Write-Log $_
}
