Import-Module PSReadLine
#Remove-Module SQLPS
Import-Module SqlServer

Clear-Host

Write-Host `n
Write-Host "====== Data Archive Jobs deployment. ======" -ForegroundColor Green
$defaultvalue='STG0-BI-DB01'
$SERVER = if(($result = Read-Host "Please enter server name [$defaultvalue]") -eq ''){$defaultvalue}else{$result}

$defaultvalue='1433'
$PORT = if(($result = Read-Host "Please enter TCP PORT [$defaultvalue]") -eq ''){$defaultvalue}else{$result}

$defaultvalue='development'
$ENV = if(($result = Read-Host "Please enter Environment [$defaultvalue]") -eq ''){$defaultvalue}else{$result}
$SSIS_UTILS_DB="ssis_utils_$ENV"

Write-Host `n
Write-Host "Server: $SERVER"
Write-Host "TCP Port: $PORT"
Write-Host "Environment: $ENV"
Write-Host "ssis_util_db: $SSIS_UTILS_DB"
$error.clear()

Write-Host `n

#sqlcmd -S %SERVER%,%PORT% -U %LOGIN% -P %SQLCMDPASSWORD% -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_archive_data_job_deploy] %ENV%"

try {
$sql = "EXEC [ds_sp_archive_data_job_deploy] $ENV"
Write-Host "Running below command to create jobs."
Write-Host $sql
Write-Host `n
#Invoke-Sqlcmd -ServerInstance $SERVER -Database $SSIS_UTILS_DB -Query $sql -Username sa -Password Cc123456 -Verbose
Invoke-Sqlcmd -ServerInstance $SERVER -Database $SSIS_UTILS_DB -Query $sql -Verbose
} catch {
        "error when running sql $sql"
        Write-Host($error) -ForegroundColor Red
        exit
        }

Write-Host `n
Write-Host "Job deploy completed."  -ForegroundColor Green
Write-Host `n
Read-Host -Prompt "Press Enter to continue"
Write-Host `n
