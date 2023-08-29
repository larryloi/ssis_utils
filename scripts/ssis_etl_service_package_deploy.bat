MAIN
CLS
ECHO.
ECHO OFF
setlocal enabledelayedexpansion
SET SERVER=STG0-BI-DB01
SET /P SERVER=Please enter SERVER Name[%SERVER%]:

SET PORT=1433
SET /P PORT=Please enter PORT Name[%PORT%]:

SET ENV=development
SET /P ENV=Please enter ENV Name[%ENV%]:
SET SSIS_UTILS_DB=ssis_utils_%ENV%

SET SSIS_FOLDER_NAME=anubis_dm
SET /P SSIS_FOLDER_NAME=Please enter SSIS_FOLDER_NAME Name[%SSIS_FOLDER_NAME%]:

SET SSIS_PROJECT_NAME=anubis_dm
SET /P SSIS_PROJECT_NAME=Please enter SSIS_PROJECT_NAME Name[%SSIS_PROJECT_NAME%]:

SET TAG_VERSION=staging0
SET /P TAG_VERSION=Please enter TAG_VERSION Name[%TAG_VERSION%]:


sqlcmd -S %SERVER%,%PORT% -E -d %SSIS_UTILS_DB% -Q  "EXEC [sp_ssis_package_deploy] %SSIS_FOLDER_NAME%, %SSIS_PROJECT_NAME%, %TAG_VERSION%"

IF ERRORLEVEL 1 goto err_handler

goto done
:err_handler
REM handle the error here
REM
:done
ECHO SSIS package deployment completed.
REM REM script completion code here
