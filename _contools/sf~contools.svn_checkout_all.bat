@echo off

setlocal

if not exist "%~dp0configure.user.bat" ( call "%~dp0configure.bat" || goto :EOF )

call "%~dp0configure.user.bat" || goto :EOF

rem extract name of sync directory from name of the script
set "?~nx0=%~nx0"

set "WCROOT_SUFFIX=%?~nx0:*.=%"

set "WCROOT=%?~nx0%."
if "%WCROOT_SUFFIX%" == "%?~nx0%" goto IGNORE_WCROOT_SUFFIX
call set "WCROOT=%%WCROOT:.%WCROOT_SUFFIX%.=%%"

:IGNORE_WCROOT_SUFFIX
if "%WCROOT:~-1%" == "." set "WCROOT=%WCROOT:~0,-1%"

if not "%WCROOT_OFFSET%" == "" set "WCROOT=%WCROOT_OFFSET%/%WCROOT%"

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

if not exist "%~dp0%WCROOT%" mkdir "%~dp0%WCROOT%"
if not exist "%~dp0%WCROOT%\.svn" ( call :CMD svn co "%%CONTOOLS_ROOT.SVN.REPOROOT%%/trunk" "%%~dp0%%WCROOT%%" || goto EXIT )

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b

:CMD
echo.^>%*
(%*)
echo.