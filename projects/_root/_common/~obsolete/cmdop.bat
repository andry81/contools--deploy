@echo off

setlocal

set "CONFIGURE_DIR=%~1"
set "CMD_SCRIPT_FILE_NAME=%~2"

set "CONFIGURE_DIR=%CONFIGURE_DIR:\=/%"

call "%%~dp0__init__.bat" || exit /b

if not defined NEST_LVL set NEST_LVL=0

(
  set /A NEST_LVL+=1
  if %NEST_LVL% EQU 0 goto WITH_LOGGING
)

rem no local logging if nested call
call "%%~dp0_impl\%%~nx0" %%*
goto EXIT

:WITH_LOGGING
rem logging for all output if not nested call
call "%%CONTOOLS_ROOT%%\get_datetime.bat"
set "LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

(
  call "%~dp0_impl\%~nx0" %*
) 2>&1 | "%CONTOOLS_ROOT%\wtee.exe" "%CONFIGURE_DIR%\.log\%CMD_SCRIPT_FILE_NAME%.%LOG_FILE_NAME_SUFFIX%.log"

:EXIT
set LASTERROR=%ERRORLEVEL%

rem to prevent pause call under logging
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b %LASTERROR%
