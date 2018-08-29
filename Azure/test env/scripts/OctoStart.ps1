Set-Executionpolicy "Unrestricted" -Force
Set-ExecutionPolicy "Unrestricted" -Scope Process -Confirm:$false -Force

do {
	$Service = Get-Service -Name 'OctopusDeploy'
	$test = Invoke-WebRequest -Uri 127.0.0.1:8080

	if ($Service.status -eq "Stopped") {

		Start-Service $Service 
		Start-Sleep -Seconds 30
	}
	elseif($Service.status -eq "Running") {
		
		Stop-Process -Name 'Octopus.Server' -Force
		Start-Sleep -Seconds 30
		Start-Service $Service
		Start-Sleep -Seconds 30
	}

}while ($test.StatusCode -ne "200")