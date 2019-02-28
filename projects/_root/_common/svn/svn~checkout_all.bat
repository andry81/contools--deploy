@echo off

setlocal

set "SCM_TOKEN=%~1"
set "CONFIG_VARS_FILE_PATH=%~2"

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 1
) >&2

if not exist "%CONFIG_VARS_FILE_PATH%" (
  echo.%~nx0: error: CONFIG_VARS_FILE_PATH is not exist: "%CONFIG_VARS_FILE_PATH%"
  exit /b 2
) >&2

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || goto EXIT

rem load configuration file
for /F "usebackq eol=# tokens=* delims=" %%i in ("%CONFIG_VARS_FILE_PATH%") do (
  set %%i
)

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR ( call :EXIT_B -254 & goto EXIT )
if not defined WCROOT_OFFSET ( call :EXIT_B -253 & goto EXIT )

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

call set "SVN_CHECKOUT_URL=%%%SCM_TOKEN%.CHECKOUT_URL%%"

echo."%WCROOT%"...

if not exist "%WCROOT%\" mkdir "%WCROOT%"
if not exist "%WCROOT%\.svn" ( call :CMD svn co "%SVN_CHECKOUT_URL%" "%%WCROOT%%" || goto EXIT )

goto EXIT

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:EXIT_B
exit /b %*

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b

:CMD
echo.^>%*
(%*)
echo.