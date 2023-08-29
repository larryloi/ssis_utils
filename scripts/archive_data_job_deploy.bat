MAIN
CLS
ECHO.
ECHO OFF
setlocal enabledelayedexpansion
SET SERVER=STG0-BI-DB01
SET /P SERVER=Please enter SERVER Name[%SERVER%]: 

SET PORT=1433
SET /P PORT=Please enter PORT Name[%PORT%]: 

REM SET LOGIN=ssis
REM SET /P LOGIN=Please enter LOGIN Name[%LOGIN%]: 

REM SET SQLCMDPASSWORD=ssis
REM SET /P SQLCMDPASSWORD=Please enter PASSWORD Name[%SQLCMDPASSWORD%]: 

SET ENV=development
SET /P ENV=Please enter ENV Name[%ENV%]: 
SET SSIS_UTILS_DB=ssis_utils_%ENV%

REM sqlcmd -S %SERVER%,%PORT% -U %LOGIN% -P %SQLCMDPASSWORD% -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_archive_data_job_deploy] %ENV%"
sqlcmd -S %SERVER%,%PORT% -E -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_archive_data_job_deploy] %ENV%"

IF ERRORLEVEL 1 goto err_handler

goto done
:err_handler
REM handle the error here
REM
:done
ECHO Archive Data job deployment completed.
PAUSE
%SCRIPT_PATH%\menu.bat
