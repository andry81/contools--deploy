@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.rem it must be from leaf repositories to a root repository
  echo.set SVN.PROJECT_PATH_LIST=orbittools\deploy ^^
  echo.  tacklelib\deploy ^^
  echo.  contools\deploy nsisplus\deploy svncmd\deploy ^^
  echo.  orbittools\orbittools orbittools\sgp4 orbittools\qd ^^
  echo.  tacklelib\tacklelib ^^
  echo.  contools\debug contools\3dparty contools\3dparty_scripts ^^
  echo.  contools\external_tools contools\contools svncmd\svncmd ^^
  echo.  contools\bittools ^^
  echo.  nsisplus\NsisSetupLib nsisplus\NsisSetupDev nsisplus\NsisSetupSamples
  echo.
  echo.rem it must be from leaf repositories to a root repository
  echo.set GIT.PROJECT_PATH_LIST=orbittools\deploy ^^
  echo.  tacklelib\deploy ^^
  echo.  contools\deploy nsisplus\deploy svncmd\deploy ^^
  echo.  orbittools\orbittools orbittools\sgp4 orbittools\qd ^^
  echo.  tacklelib\tacklelib ^^
  echo.  contools\debug contools\3dparty contools\3dparty_scripts ^^
  echo.  contools\Tools svncmd\Scripts ^^
  echo.  contools\external_tools contools\contools svncmd\svncmd ^^
  echo.  contools\bittools ^^
  echo.  nsisplus\NsisSetupLib nsisplus\NsisSetupDev nsisplus\NsisSetupSamples
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
