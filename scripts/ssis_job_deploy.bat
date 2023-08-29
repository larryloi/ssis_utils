MAIN
CLS
ECHO.
ECHO OFF
setlocal enabledelayedexpansion
SET SCRIPT_PATH=%cd%
SET DEPLOYMENT_ROOT=%SCRIPT_PATH%\..

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

ECHO Available ssis_folder, ssis_project for environment: %ENV%
REM sqlcmd -S %SERVER%,%PORT% -U %LOGIN% -P %SQLCMDPASSWORD% -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_etl_job_ssis_config_list] %ENV%"
sqlcmd -S %SERVER%,%PORT% -E -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_etl_job_ssis_config_list] %ENV%"

IF ERRORLEVEL 1 goto err_handler

SET SSIS_FOLDER=anubis_dm
SET /P SSIS_FOLDER=Please enter SSIS_FOLDER name [%SSIS_FOLDER%]: 

SET SSIS_PROJECT=anubis_dm
SET /P SSIS_PROJECT=Please enter SSIS_PROJECT name [%SSIS_PROJECT%]: 
REM sqlcmd -S %SERVER%,%PORT% -U %LOGIN% -P %SQLCMDPASSWORD% -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_etl_job_deploy] %ENV%, %SSIS_FOLDER%, %SSIS_PROJECT%"
sqlcmd -S %SERVER%,%PORT% -E -d %SSIS_UTILS_DB% -Q "EXEC [ds_sp_etl_job_deploy] %ENV%, %SSIS_FOLDER%, %SSIS_PROJECT%"

IF ERRORLEVEL 1 goto err_handler

goto done
:err_handler
REM handle the error here
REM
:done 
ECHO SSIS job deployment completed.
PAUSE
%SCRIPT_PATH%\menu.bat
