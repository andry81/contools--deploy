@echo off

setlocal

set "__CONFIGURE_DIR=%~1"

if not defined __CONFIGURE_DIR (
  echo.%~nx0: error: configure directory is not defined.
  exit /b 1
) >&2

if "%__CONFIGURE_DIR:~-1%" == "\" set "__CONFIGURE_DIR=%__CONFIGURE_DIR:~0,-1%"

if not exist "%__CONFIGURE_DIR%\" (
  echo.%~nx0: error: configure directory does not exist: "%__CONFIGURE_DIR%".
  exit /b 2
) >&2

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  type "%__CONFIGURE_DIR%\config.vars.in" || exit /b 255
) > "%__CONFIGURE_DIR%\config.vars"

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /A:D /B "%__CONFIGURE_DIR%\*.*"`) do (
  set "DIR=%%i"
  call :PROCESS_DIR
)

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b 0

:PROCESS_DIR
rem ignore directories beginning by `.`
if "%DIR:~0,1%" == "." exit /b 0

if exist "%__CONFIGURE_DIR%\%DIR%\configure.bat" call :CMD "%%__CONFIGURE_DIR%%\%%DIR%%\configure.bat"

exit /b

:CMD
echo.^>%*
(%*)