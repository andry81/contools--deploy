@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || exit /b

set "WCROOT=%SVN.WCROOT_DIR%"
if not defined WCROOT ( call :EXIT_B -254 & goto EXIT )

if not "%WCROOT_OFFSET%" == "" set "WCROOT=%WCROOT_OFFSET%/%WCROOT%"

if not exist "%~dp0%WCROOT%\" mkdir "%~dp0%WCROOT%"
if not exist "%~dp0%WCROOT%\.svn" ( call :CMD svn co "%%CONTOOLS_ROOT.SVN.REPOROOT%%/trunk" "%%~dp0%%WCROOT%%" || goto EXIT )

goto EXIT

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
