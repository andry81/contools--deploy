@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.set "SVN.WCROOT_DIR=sf~svn~contools--bittools"
  echo.set "GIT.WCROOT_DIR=gh~git~contools--bittools"
  echo.set "GIT2.WCROOT_DIR=bb~git~contools--bittools"
  echo.set "GIT3.WCROOT_DIR=gl~git~contools--bittools"
  echo.
) > "%~dp0configure.user.bat"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
