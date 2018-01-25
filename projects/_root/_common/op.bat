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

set "OP_NAME=%~1"
set "HUB_ABBR=%~2"
set "HUB_TYPE=%~3"

if not defined OP_NAME (
  echo.%?~nx0%: error: OP_NAME is not set.
  exit /b 1
) >&2
if not defined HUB_ABBR (
  echo.%?~nx0%: error: HUB_ABBR is not set.
  exit /b 2
) >&2
if not defined HUB_TYPE (
  echo.%?~nx0%: error: HUB_TYPE is not set.
  exit /b 3
) >&2

set "PROJECTS_ROOT=%CONFIGURE_ROOT%"

rem from leaf repositories to a root repository
if defined %HUB_TYPE%.PROJECT_PATH_LIST (
  call set "%%HUB_TYPE%%.PROJECT_PATH_LIST=%%%HUB_TYPE%.PROJECT_PATH_LIST:{{HUB_ABBR}}=%HUB_ABBR%%%"
) else (
  set "%HUB_TYPE%.PROJECT_PATH_LIST="
)

call set "SCM_PROJECT_PATH_LIST=%%%HUB_TYPE%.PROJECT_PATH_LIST%%"

for %%i in (%SCM_PROJECT_PATH_LIST%) do (
  echo.%%i%OP_NAME%...
  if exist "%PROJECTS_ROOT%\%%i%OP_NAME%.bat" (
    call "%%PROJECTS_ROOT%%\%%i%%OP_NAME%%.bat" || goto EXIT
  ) else (
    echo.%%i%OP_NAME%: info: ignored, script is not found
  )
  echo.---
  echo.
)

:EXIT
set /A NEST_LVL-=1

exit /b 0
