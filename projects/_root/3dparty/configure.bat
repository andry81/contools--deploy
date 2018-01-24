@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.set PROJECT_NAME=3dparty
  echo.set "WCROOT_OFFSET=../../../../_%%PROJECT_NAME%%"
  echo.
  echo.set "_3DPARTY_DEV.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/3dparty"
  echo.set "_3DPARTY_SCRIPTS.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/3dparty_scripts"
  echo.
  echo.set "_3DPARTY_DEV.GIT3.ORIGIN=https://%%GIT3.USER%%@%%GIT3.HUB_ROOT%%/%%GIT3.REPO_OWNER%%/3dparty--dev.git"
  echo.set "_3DPARTY_SCRIPTS.GIT3.ORIGIN=https://%%GIT3.USER%%@%%GIT3.HUB_ROOT%%/%%GIT3.REPO_OWNER%%/3dparty--scripts.git"
  echo.
) > "%~dp0configure.user.bat"

for /F "usebackq eol=	 tokens=* delims=" %%i in (`dir /A:D /B "%~dp0*.*"`) do (
  set "DIR=%%i"
  call :PROCESS_DIR
)

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b 0

:PROCESS_DIR
rem ignore directories beginning by `.`
if "%DIR:~0,1%" == "." exit /b 0

if exist "%~dp0%DIR%\configure.bat" call :CMD "%%~dp0%%DIR%%\configure.bat"

exit /b

:CMD
echo.^>%*
(%*)
