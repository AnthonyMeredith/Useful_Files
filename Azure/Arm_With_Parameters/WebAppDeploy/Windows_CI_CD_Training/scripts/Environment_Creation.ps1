Param (
    [string] $OctopusUsername,
    [string] $OctopusPassword
)
##CONFIGURATION##

$OctopusURI = "http://127.0.0.1:8080" #Octopus URL

$APIKeyPurpose = "Automate environment setup" #Brief text to describe the purpose of your API Key.

$machineDisplayName = "CICD-Tentacle" #Name that the Tentacle will have in Octopus
$MachineRoles = "CICD-Training" #Roles of the Tentacle
$machineHostname = "localhost" #hostname of the Tentacle you want to add. This can either be the ComputerName of the IP address of the Tentacle machine.
$machineEnvironments #Environment where this machine will be registered

Write-Output "Install nuget command line"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

##Installing octoposh##

Install-Module -Name Octoposh -force

Start-Sleep -s 10


##PROCESS of creating the octopus deploy environment##

#Adding libraries. Make sure to modify these paths acording to your environment setup.
Add-Type -Path "C:\Program Files\Octopus Deploy\Octopus\Newtonsoft.Json.dll"
Add-Type -Path "C:\Program Files\Octopus Deploy\Octopus\Octopus.Client.dll"

#Creating a connection
$endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURI
$repository = new-object Octopus.Client.OctopusRepository $endpoint

#Creating login object
$LoginObj = New-Object Octopus.Client.Model.LoginCommand 
$LoginObj.Username = $OctopusUsername
$LoginObj.Password = $OctopusPassword

#Loging in to Octopus
$repository.Users.SignIn($LoginObj)

#Getting current user logged in
$UserObj = $repository.Users.GetCurrent()

#Creating API Key for user. This automatically gets saved to the database.
$ApiObj = $repository.Users.CreateApiKey($UserObj, $APIKeyPurpose)

#Returns the API Key in clear text
$ApiKey = $ApiObj.ApiKey

Set-OctopusConnectionInfo -URL $OctopusURI -APIKey $ApiKey

#Create an instance of an environment Object
$Environment = Get-OctopusResourceModel -Resource Environment

#Add mandatory properties to the object
$Environment.name = "CI_CD_Training"

$machineEnvironments = $Environment.name

#Create the resource
New-OctopusResource -Resource $Environment



##PROCESS of registering the tentacle thumbprint##
#Create an instance of a Machine Object
$machine = Get-OctopusResourceModel -Resource Machine

#Get Environment to use the ID to create the project
$environments = Get-OctopusEnvironment -EnvironmentName $machineEnvironments -ResourceOnly

#Add mandatory properties to the object
$machine.name = $machineDisplayName #Display name of the machine on Octopus

foreach($environment in $environments){
    $machine.EnvironmentIds.Add($environment.id)
}
foreach ($role in $MachineRoles){
    $machine.Roles.Add($role)    
}
#Use the Discover API to get the machine thumbprint.
$discover = (Invoke-WebRequest "$env:OctopusURL/api/machines/discover?host=$machineHostname&type=TentaclePassive" -Headers (New-OctopusConnection).header).content | ConvertFrom-Json

$machineEndpoint = New-Object Octopus.Client.Model.Endpoints.ListeningTentacleEndpointResource
$machine.EndPoint = $machineEndpoint
$machine.Endpoint.Uri = $discover.Endpoint.Uri
$machine.Endpoint.Thumbprint = $discover.Endpoint.Thumbprint

New-OctopusResource -Resource $machine