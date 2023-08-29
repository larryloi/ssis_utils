@ECHO off
cls
SET SCRIPT_PATH=%cd%
SET DEPLOYMENT_ROOT=%SCRIPT_PATH%\..
:main_menu
cls
ECHO.
ECHO ...............................................
ECHO              Deployment Menu
ECHO ...............................................
ECHO.
ECHO 1 - Run DB migration Scripts
ECHO 2 - Run ssis job deployment - SQL Server jobs
ECHO 3 - Run archive data job deploy - SQL Server jobs
ECHO 0 - END
ECHO.
set choice=
set /p choice=Please make a selection: 
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' goto db_migration
if '%choice%'=='2' goto ssis_job_deploy
if '%choice%'=='3' goto archive_data_job_deploy
IF '%choice%'=='0' goto end
ECHO "%choice%" is not valid, try again
pause
ECHO.
goto main_menu
:db_migration
%SCRIPT_PATH%\db_migrate.bat
PAUSE
GOTO main_menu
:ssis_job_deploy
%SCRIPT_PATH%\ssis_job_deploy.bat
REM powershell %SCRIPT_PATH%\ssis_job_deploy.ps1
goto main_menu
:archive_data_job_deploy
%SCRIPT_PATH%\archive_data_job_deploy.bat
REM powershell %SCRIPT_PATH%\archive_data_job_deploy
goto main_menu
:end
pause
ECHO Exited.
ECHO.
