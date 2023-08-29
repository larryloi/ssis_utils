Import-Module PSReadLine
#Remove-Module SQLPS
Import-Module SqlServer

Clear-Host

Write-Host `n
Write-Host "====== SSIS jobs deployment. ======" -ForegroundColor Green
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
try {
$sql = "EXEC [ds_sp_etl_job_ssis_config_list] $ENV;"
Write-Host "Available ssis_folder, ssis_project for environment: $ENV" -ForegroundColor Green
#$DS = Invoke-Sqlcmd -ServerInstance $SERVER -Database $SSIS_UTILS_DB -Query $sql -Username sa -Password Cc123456 -As DataSet -Verbose
$DS = Invoke-Sqlcmd -ServerInstance $SERVER -Database $SSIS_UTILS_DB -Query $sql -As DataSet -Verbose
Write-Host "ssis_folder ssis_project"
Write-Host "----------- ------------"
#$DS.Tables[0].Rows | %{ echo "{ $($_['ssis_folder']) , $($_['ssis_project']) }" }
$DS.Tables[0].Rows | %{ echo "$($_['ssis_folder']) , $($_['ssis_project']) " }
} catch {
        "error when running sql $sql"
        Write-Host($error) -ForegroundColor Red
        exit
        }

Write-Host `n

$defaultvalue='anubis_dm'
$SSIS_FOLDER = if(($result = Read-Host "Please enter SSIS_FOLDER [$defaultvalue]") -eq ''){$defaultvalue}else{$result}

$defaultvalue='anubis_dm'
$SSIS_PROJECT = if(($result = Read-Host "Please enter SSIS_PROJECT [$defaultvalue]") -eq ''){$defaultvalue}else{$result}
Write-Host `n

try {
$sql = "EXEC [ds_sp_etl_job_deploy] $ENV, $SSIS_FOLDER, $SSIS_PROJECT"
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
Read-Host -Prompt "Press Enter to continue"
Write-Host `n
