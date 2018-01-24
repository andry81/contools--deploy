@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.set PROJECT_NAME=contools
  echo.set "WCROOT_OFFSET=../../../../_%%PROJECT_NAME%%"
  echo.
  echo.set "CONTOOLS_DEPLOY.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/deploy"
  echo.set "CONTOOLS_DEBUG.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/debug"
  echo.set "CONTOOLS_3DPARTY.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/3dparty"
  echo.set "CONTOOLS_3DPARTY_SCRIPTS.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/3dparty_scripts"
  echo.set "CONTOOLS_ROOT.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/contools"
  echo.set "CONTOOLS_TOOLS.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/contools/trunk/Scripts/Tools"
  echo.set "EXTERNAL_TOOLS.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/external_tools"
  echo.set "CONTOOLS_BITTOOLS.SVN.REPOROOT=https://%%SVN.HUB_ROOT%%/contools/bittools"
  echo.
  echo.set "CONTOOLS_DEPLOY.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--deploy.git"
  echo.set "CONTOOLS_DEBUG.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--debug.git"
  echo.set "CONTOOLS_3DPARTY.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--3dparty.git"
  echo.set "CONTOOLS_3DPARTY_SCRIPTS.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--3dparty_scripts.git"
  echo.set "CONTOOLS_ROOT.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools.git"
  echo.set "CONTOOLS_TOOLS.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--Tools.git"
  echo.set "CONTOOLS_TOOLS_SVN.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/svncmd--Scripts.git"
  echo.set "EXTERNAL_TOOLS.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/external_tools.git"
  echo.set "CONTOOLS_BITTOOLS.GIT.ORIGIN=https://%%GIT.USER%%@%%GIT.HUB_ROOT%%/%%GIT.REPO_OWNER%%/contools--bittools.git"
  echo.
  echo.set "CONTOOLS_DEPLOY.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-deploy.git"
  echo.set "CONTOOLS_DEBUG.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-debug.git"
  echo.set "CONTOOLS_3DPARTY.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-3dparty.git"
  echo.set "CONTOOLS_3DPARTY_SCRIPTS.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-3dparty_scripts.git"
  echo.set "CONTOOLS_ROOT.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools.git"
  echo.set "CONTOOLS_TOOLS.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-tools.git"
  echo.set "CONTOOLS_TOOLS_SVN.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/svncmd-scripts.git"
  echo.set "EXTERNAL_TOOLS.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/external_tools.git"
  echo.set "CONTOOLS_BITTOOLS.GIT2.ORIGIN=https://%%GIT2.USER%%@%%GIT2.HUB_ROOT%%/%%GIT2.REPO_OWNER%%/contools-bittools.git"
  echo.
  echo.set "CONTOOLS_3DPARTY.GIT3.ORIGIN=https://%%GIT3.USER%%@%%GIT3.HUB_ROOT%%/%%GIT3.REPO_OWNER%%/contools--3dparty.git"
  echo.set "CONTOOLS_3DPARTY_SCRIPTS.GIT3.ORIGIN=https://%%GIT3.USER%%@%%GIT3.HUB_ROOT%%/%%GIT3.REPO_OWNER%%/contools--3dparty_scripts.git"
  echo.set "CONTOOLS_BITTOOLS.GIT3.ORIGIN=https://%%GIT3.USER%%@%%GIT3.HUB_ROOT%%/%%GIT3.REPO_OWNER%%/contools--bittools.git"
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
