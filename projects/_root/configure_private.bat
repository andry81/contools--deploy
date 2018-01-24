@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  echo.@echo off
  echo.
  echo.set "SVN.HUB_ROOT=localhost"
  echo.
  echo.set "GIT.HUB_ROOT=localhost"
  echo.set "GIT.REPO_OWNER=owner"
  echo.set "GIT.USER=user"
  echo.set "GIT.EMAIL=user@mail.com"
  echo.
  echo.set "GIT2.HUB_ROOT=localhost"
  echo.set "GIT2.REPO_OWNER=owner"
  echo.set "GIT2.USER=user"
  echo.set "GIT2.EMAIL=user@mail.com"
  echo.
  echo.set "GIT3.HUB_ROOT=localhost"
  echo.set "GIT3.REPO_OWNER=owner"
  echo.set "GIT3.USER=user"
  echo.set "GIT3.EMAIL=user@mail.com"
  echo.
) > "%~dp0configureex.user.bat"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
