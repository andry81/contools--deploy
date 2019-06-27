@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

if %NEST_LVL%0 EQU 0 goto WITH_LOGGING

rem no local logging if nested call
call "%%BASE_SCRIPTS_ROOT%%\configure_directory.bat" "%~dp0" || exit /b

exit /b 0

:WITH_LOGGING
rem to prevent pause call under logging
set /A NEST_LVL+=1

rem logging for all output if not nested call
call "%%CONTOOLS_ROOT%%\get_datetime.bat"
set "LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

(
  call "%%BASE_SCRIPTS_ROOT%%\configure_directory.bat" "%~dp0" || exit /b
) 2>&1 | "%CONTOOLS_ROOT%\wtee.exe" "%CONFIGURE_DIR%\.log\%~n0_%LOG_NAME%.%LOG_FILE_NAME_SUFFIX%.log"

rem to prevent pause call under logging
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b 0
