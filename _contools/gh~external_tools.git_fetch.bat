@echo off

setlocal

rem extract name of sync directory from name of the script
set "?~nx0=%~nx0"

set "WCROOT_SUFFIX=%?~nx0:*.=%"

set "WCROOT=%?~nx0%."
if "%WCROOT_SUFFIX%" == "%?~nx0%" goto IGNORE_WCROOT_SUFFIX
call set "WCROOT=%%WCROOT:.%WCROOT_SUFFIX%.=%%"

:IGNORE_WCROOT_SUFFIX
if "%WCROOT:~-1%" == "." set "WCROOT=%WCROOT:~0,-1%"

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

pushd "%~dp0%WCROOT%" && (
  call :CMD git svn fetch %%* || ( popd & goto EXIT )
  popd
)

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b

:CMD
echo.^>%*
(%*)
echo.
