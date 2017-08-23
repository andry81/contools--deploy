@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.rem primary mirror: github.com
  echo.set "GIT.USER=user"
  echo.set "GIT.EMAIL=user@mail.com"
  echo.
  echo.rem secondary mirror: bitbucket.org
  echo.set "GIT2.USER=user"
  echo.set "GIT2.EMAIL=user@mail.com"
  echo.
) > "%~dp0configureex.user.bat"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
