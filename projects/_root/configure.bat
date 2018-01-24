@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.set SVN.PROJECT_PATH_LIST=tacklelib\deploy\{{HUB_ABBR}}~ ^^
  echo.  contools\deploy\{{HUB_ABBR}}~ nsisplus\deploy\{{HUB_ABBR}}~ svncmd\deploy\{{HUB_ABBR}}~ ^^
  echo.  tacklelib\tacklelib\{{HUB_ABBR}}~ tacklelib\cmake\{{HUB_ABBR}}~ tacklelib\examples\{{HUB_ABBR}}~ ^^
  echo.  contools\debug\{{HUB_ABBR}}~ contools\3dparty\{{HUB_ABBR}}~ contools\3dparty_scripts\{{HUB_ABBR}}~ ^^
  echo.  contools\external_tools\{{HUB_ABBR}}~ contools\contools\{{HUB_ABBR}}~ svncmd\svncmd\{{HUB_ABBR}}~ ^^
  echo.  contools\bittools\{{HUB_ABBR}}~ ^^
  echo.  nsisplus\NsisSetupLib\{{HUB_ABBR}}~ nsisplus\NsisSetupDev\{{HUB_ABBR}}~ nsisplus\NsisSetupSamples\{{HUB_ABBR}}~
  echo.
  echo.rem from leaf repositories to a root repository
  echo.set GIT.PROJECT_PATH_LIST=tacklelib\deploy\{{HUB_ABBR}}~ ^^
  echo.  contools\deploy\{{HUB_ABBR}}~ nsisplus\deploy\{{HUB_ABBR}}~ svncmd\deploy\{{HUB_ABBR}}~ ^^
  echo.  tacklelib\tacklelib\{{HUB_ABBR}}~ tacklelib\cmake\{{HUB_ABBR}}~ tacklelib\examples\{{HUB_ABBR}}~ ^^
  echo.  contools\debug\{{HUB_ABBR}}~ contools\3dparty\{{HUB_ABBR}}~ contools\3dparty_scripts\{{HUB_ABBR}}~ ^^
  echo.  contools\Tools\{{HUB_ABBR}}~ svncmd\Scripts\{{HUB_ABBR}}~ ^^
  echo.  contools\external_tools\{{HUB_ABBR}}~ contools\contools\{{HUB_ABBR}}~ svncmd\svncmd\{{HUB_ABBR}}~ ^^
  echo.  contools\bittools\{{HUB_ABBR}}~ ^^
  echo.  nsisplus\NsisSetupLib\{{HUB_ABBR}}~ nsisplus\NsisSetupDev\{{HUB_ABBR}}~ nsisplus\NsisSetupSamples\{{HUB_ABBR}}~
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
