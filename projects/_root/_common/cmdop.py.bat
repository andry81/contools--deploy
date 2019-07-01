@echo off

rem CAUTION:
rem   Temporary disabled because of issues in the python xonsh module.
rem   See details in the `README_EN.known_issues.txt` file.
rem
rem rem implementation through the `python` 3.x + `xonsh` module
rem 
rem setlocal
rem 
rem call "%%~dp0__init__.bat" || exit /b
rem 
rem "%PYTHON_EXE_PATH%" -m xonsh "%~dp0cmdop.xsh" %*
rem exit /b

setlocal

call "%%~dp0__init__.bat" || exit /b

if %NEST_LVL%0 EQU 0 goto WITH_LOGGING

rem no local logging if nested call
"%PYTHON_EXE_PATH%" -m xonsh "%~dp0cmdop.xsh" %*
exit /b

:WITH_LOGGING
set /A NEST_LVL+=1

rem logging for all output if not nested call
call "%%CONTOOLS_ROOT%%\get_datetime.bat"
set "LOG_FILE_NAME_SUFFIX=%RETURN_VALUE:~0,4%_%RETURN_VALUE:~4,2%_%RETURN_VALUE:~6,2%_%RETURN_VALUE:~8,2%_%RETURN_VALUE:~10,2%_%RETURN_VALUE:~12,2%_%RETURN_VALUE:~15,3%"

(
  "%PYTHON_EXE_PATH%" -m xonsh "%~dp0cmdop.xsh" %*
) 2>&1 | "%CONTOOLS_ROOT%\wtee.exe" "%CONFIGURE_DIR%\.log\%~n0.%LOG_FILE_NAME_SUFFIX%.log"

set LASTERROR=%ERRORLEVEL%

rem to prevent pause call under logging
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b %LASTERROR%
