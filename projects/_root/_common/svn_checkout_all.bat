@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

if not exist "%CONFIGURE_ROOT%\configure.user.bat" ( call "%%CONFIGURE_ROOT%%\configure.bat" || goto :EOF )

call "%%CONFIGURE_ROOT%%\configure.user.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

set "OP_NAME=%?~n0:*~=%"

set "HUB_ABBR=%?~n0%"
if "%OP_NAME%" == "%?~n0%" goto IGNORE_HUB_ABBR_SUFFIX
call set "HUB_ABBR=%%HUB_ABBR:%OP_NAME%=%%"
set "HUB_ABBR=%HUB_ABBR:~0,-1%"

:IGNORE_HUB_ABBR_SUFFIX
set "PROJECTS_ROOT=%~dp0"
if "%PROJECTS_ROOT:~-1%" == "\" set "PROJECTS_ROOT=%PROJECTS_ROOT:~0,-1%"

rem from leaf repositories to a root repository
call set "%VAR_PREFIX%.PROJECT_PATH_LIST=%%%VAR_PREFIX%.PROJECT_PATH_LIST:{{HUB_ABBR}}=%HUB_ABBR%%%"

call set "SCM_PROJECT_PATH_LIST=%%%VAR_PREFIX%.PROJECT_PATH_LIST%%"

for %%i in (%SCM_PROJECT_PATH_LIST%) do (
  echo.%%i%OP_NAME%...
  call "%%PROJECTS_ROOT%%\%%i%%OP_NAME%%.bat" || goto EXIT
  echo.---
  echo.
)

:EXIT
set /A NEST_LVL-=1

exit /b 0
