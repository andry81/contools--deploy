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

set ERROR_OP_SCRIPT_COUNT=0

echo PROJECTS_ROOT=%PROJECTS_ROOT%
for %%i in (%SCM_PROJECT_PATH_LIST%) do (
  set "OP_SCRIPT_REL_PATH=%%i%OP_NAME%"
  call set "OP_SCRIPT_ABS_PATH=%%PROJECTS_ROOT%%\%%OP_SCRIPT_REL_PATH%%.bat"
  call :PROCESS_OP_SCRIPT
)

if %ERROR_OP_SCRIPT_COUNT% GTR 0 (
  echo Overall scripts failed: %ERROR_OP_SCRIPT_COUNT%
  for /L %%i in (1,1,%ERROR_OP_SCRIPT_COUNT%) do (
    call echo. - "%%ERROR_OP_SCRIPT_PATH[%%i]%%"
  )
)

goto :EXIT

:PROCESS_OP_SCRIPT
echo.%OP_SCRIPT_REL_PATH%...
if exist "%OP_SCRIPT_ABS_PATH%" (
  call "%%OP_SCRIPT_ABS_PATH%%" || call :REGISTER_SCRIPT_ERROR
) else (
  echo.%"OP_SCRIPT_REL_PATH%: info: ignored, script is not found
  call :REGISTER_SCRIPT_ERROR
)
echo.---
echo.

exit /b 0

:REGISTER_SCRIPT_ERROR
rem register error script to print it at the end
set /A ERROR_OP_SCRIPT_COUNT+=1
set "ERROR_OP_SCRIPT_PATH[%ERROR_OP_SCRIPT_COUNT%]=%OP_SCRIPT_ABS_PATH%"

exit /b 0

:EXIT
set /A NEST_LVL-=1

exit /b 0
