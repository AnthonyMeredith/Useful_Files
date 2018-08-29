Start-Transcript -Path C:\artsql-deploy.Log

choco install sql2014.clrtypes sql2014.smo sql2014-powershell -y
$env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
Invoke-Sqlcmd -Database ${sql_db} -ServerInstance ${sql_host} -Username ${sql_user} -Password ${sql_pass} -OutputSqlErrors $True -InputFile c:\artweb.sql

Stop-Transcript