@echo off

setlocal

if not exist "%~dp0configure.user.bat" ( call "%~dp0configure.bat" || goto :EOF )

call "%~dp0configure.user.bat" || goto :EOF

set "?~n0=%~n0"

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "OP_NAME=%?~n0:*~=%"

set "HUB_ABBR=%?~n0%"
if "%OP_NAME%" == "%?~n0%" goto IGNORE_HUB_ABBR_SUFFIX
call set "HUB_ABBR=%%HUB_ABBR:%OP_NAME%=%%"
set "HUB_ABBR=%HUB_ABBR:~0,-1%"

:IGNORE_HUB_ABBR_SUFFIX
set "PROJECTS_ROOT=%~dp0"
if "%PROJECTS_ROOT:~-1%" == "\" set "PROJECTS_ROOT=%PROJECTS_ROOT:~0,-1%"

rem from leaf repositories to a root repository
call set "SVN.PROJECT_PATH_LIST=%%SVN.PROJECT_PATH_LIST:{{HUB_ABBR}}=%HUB_ABBR%%%"

for %%i in (%SVN.PROJECT_PATH_LIST%) do (
  echo.%%i: %OP_NAME%...
  call "%%PROJECTS_ROOT%%\%%i.%%OP_NAME%%.bat" %%* || goto EXIT
  echo.---
  echo.
)

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
