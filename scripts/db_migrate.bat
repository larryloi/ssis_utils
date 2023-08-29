@ECHO off
cls
ECHO.
SET ENV=
SET ENV=development
SET /P ENV=Please enter ENV Name [%ENV%]: 
SET SCRIPT_PATH=%cd%
SET DEPLOYMENT_ROOT=%SCRIPT_PATH%\..
:DB_MIGRATE_MENU
ECHO.
ECHO ...............................................
ECHO Please make a selection. Environment: %ENV%
ECHO ...............................................
ECHO.
ECHO 1 - Run rake db:seed
ECHO 2 - Run rake db:migrate:status
ECHO 3 - Run rake db:migrate:up by version
ECHO 4 - Run rake db:migrate:down by version
ECHO 5 - Run rake db:migrate
ECHO 0 - Back
ECHO.
set choice=
set /p choice=Please make a selection: 
if not '%choice%'=='' set choice=%choice:~0,1%
if '%choice%'=='1' GOTO DB_SEED
if '%choice%'=='2' GOTO DB_MIGRATION_STATUS
if '%choice%'=='3' GOTO DB_MIGRATION_UP_VERSION
if '%choice%'=='4' GOTO DB_MIGRATION_DOWN_VERSION
if '%choice%'=='5' GOTO DB_MIGRATION
IF '%choice%'=='0' GOTO back
ECHO "%choice%" is not valid, try again
pause
ECHO.
GOTO db_migrate_menu
:DB_SEED
SET RAILS_ROOT=%DEPLOYMENT_ROOT%/DDL
CD %RAILS_ROOT%
call bundle exec rake db:seed RAILS_ENV=%ENV%
PAUSE
CD %SCRIPT_PATH%
GOTO DB_MIGRATE_MENU

:DB_MIGRATION_STATUS
SET RAILS_ROOT=%DEPLOYMENT_ROOT%/DDL
CD %RAILS_ROOT%
call bundle exec rake db:migrate:status RAILS_ENV=%ENV%
PAUSE
CD %SCRIPT_PATH%
GOTO DB_MIGRATE_MENU

:DB_MIGRATION_UP_VERSION
SET VER=
SET /P VER=Please enter version number: 
SET RAILS_ROOT=%DEPLOYMENT_ROOT%/DDL
CD %RAILS_ROOT%
call bundle exec rake db:migrate:up RAILS_ENV=%ENV% VERSION=%VER%
PAUSE
CD %SCRIPT_PATH%
GOTO DB_MIGRATE_MENU

:DB_MIGRATION_DOWN_VERSION
SET VER=
SET /P VER=Please enter version number: 
SET RAILS_ROOT=%DEPLOYMENT_ROOT%/DDL
CD %RAILS_ROOT%
call bundle exec rake db:migrate:down RAILS_ENV=%ENV% VERSION=%VER%
PAUSE
CD %SCRIPT_PATH%
GOTO DB_MIGRATE_MENU

:DB_MIGRATION
SET RAILS_ROOT=%DEPLOYMENT_ROOT%/DDL
CD %RAILS_ROOT%
call bundle exec rake db:migrate RAILS_ENV=%ENV%
PAUSE
CD %SCRIPT_PATH%
GOTO DB_MIGRATE_MENU

:back
%SCRIPT_PATH%\menu.bat
