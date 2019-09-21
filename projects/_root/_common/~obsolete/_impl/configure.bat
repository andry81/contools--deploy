@echo off

setlocal

set "CONFIGURE_DIR=%~1"

if not defined CONFIGURE_DIR (
  echo.%~nx0: error: CONFIGURE_DIR directory is not defined.
  exit /b 1
) >&2

if "%CONFIGURE_DIR:~-1%" == "\" set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

if not exist "%CONFIGURE_DIR%\" (
  echo.%~nx0: error: CONFIGURE_DIR directory does not exist: "%CONFIGURE_DIR%".
  exit /b 2
) >&2

if exist "%CONFIGURE_DIR%\config.yaml.in" (
  (
    type "%CONFIGURE_DIR%\config.yaml.in" || exit /b 255
  ) > "%CONFIGURE_DIR%\config.yaml"
)

if exist "%CONFIGURE_DIR%\repos.lst.in" (
  (
    type "%CONFIGURE_DIR%\repos.lst.in" || exit /b 255
  ) > "%CONFIGURE_DIR%\repos.lst"
)

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /A:D /B "%CONFIGURE_DIR%\*.*"`) do (
  set "DIR=%%i"
  call :PROCESS_DIR
)

exit /b 0

:PROCESS_DIR
rem ignore directories beginning by `.`
if "%DIR:~0,1%" == "." exit /b 0

rem ignore directories w/o config.vars.in
if not exist "%CONFIGURE_DIR%\%DIR%\config.vars.in" exit /b 0

if exist "%CONFIGURE_DIR%\%DIR%\configure.bat" call :CMD "%%CONFIGURE_DIR%%\%%DIR%%\configure.bat"

exit /b

:CMD
echo.^>%*
(%*)
