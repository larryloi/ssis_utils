REM create_svc_path.bat aino_ndm cert D:\temp\export_4_report 2017-05-01_12

@ECHO OFF
ECHO.

SETLOCAL enabledelayedexpansion

SET SVC=%1
SET PROJECT=%2
SET WORK_BASE=%3
SET SCRIPT_PATH=%WORK_BASE%\scripts
SET TIMESTAMP=%4
SET SVC_PATH=%WORK_BASE%\report\%SVC%_%TIMESTAMP%

CALL :CREATE_PATH %SVC_PATH%
ECHO Create path %SVC_PATH% ; return code %ERRORLEVEL%

CALL :CREATE_PATH %SVC_PATH%\dtsx
ECHO Create path %SVC_PATH%\dtsx ; return code %ERRORLEVEL%
CALL :CREATE_PATH %SVC_PATH%\dtsx\%PROJECT%
ECHO Create path %SVC_PATH%\dtsx\%PROJECT% ; return code %ERRORLEVEL%

CALL :CREATE_PATH %SVC_PATH%\sp
ECHO Create path %SVC_PATH%\sp ; return code %ERRORLEVEL%
CALL :CREATE_PATH %SVC_PATH%\sp\%PROJECT%
ECHO Create path %SVC_PATH%\sp\%PROJECT% ; return code %ERRORLEVEL%

CALL :CREATE_PATH %SVC_PATH%\rdl
ECHO Create path %SVC_PATH%\rdl ; return code %ERRORLEVEL%
CALL :CREATE_PATH %SVC_PATH%\rdl\%PROJECT%
ECHO Create path %SVC_PATH%\rdl\%PROJECT% ; return code %ERRORLEVEL%

EXIT /b


:CREATE_PATH
IF EXIST %1 (
    RD /S /Q %1
    MKDIR %1
    ) ELSE (
    MKDIR %1
    )
EXIT /b %rtn%