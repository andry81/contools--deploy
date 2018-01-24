@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

if not exist "%CONFIGURE_ROOT%\configure_private.user.bat" ( call "%%CONFIGURE_ROOT%%\configure_private.bat" || goto :EOF )
if not exist "%CONFIGURE_ROOT%\configure.user.bat" ( call "%%CONFIGURE_ROOT%%\configure.bat" || goto :EOF )

call "%%CONFIGURE_ROOT%%\configure_private.user.bat" || goto :EOF
call "%%CONFIGURE_ROOT%%\configure.user.bat" || goto :EOF

set "?~n0=%~n0"
set "?~nx0=%~nx0"

set "OP_NAME=%?~n0%"
set "HUB_ABBR=%~1"
set "VAR_PREFIX=%~2"

if not defined HUB_ABBR (
  echo.%?~nx0%: error: HUB_ABBR is not set.
  exit /b 1
) >&2
if not defined VAR_PREFIX (
  echo.%?~nx0%: error: VAR_PREFIX is not set.
  exit /b 2
) >&2

set "PROJECTS_ROOT=%CONFIGURE_ROOT%"

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
