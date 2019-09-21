@echo off

setlocal

set "CONFIGURE_DIR=%~1"
set "CMD_SCRIPT_FILE_NAME=%~2"

if not defined CONFIGURE_DIR (
  echo.%~nx0: error: CONFIGURE_DIR directory is not defined.
  exit /b 1
) >&2

if not defined CMD_SCRIPT_FILE_NAME (
  echo.%~nx0: error: CMD_SCRIPT_FILE_NAME file name is not defined.
  exit /b 2
) >&2

if "%CONFIGURE_DIR:~-1%" == "\" set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

if not exist "%CONFIGURE_DIR%\" (
  echo.%~nx0: error: CONFIGURE_DIR directory does not exist: "%CONFIGURE_DIR%".
  exit /b 3
) >&2


call "%%CONTOOLS_ROOT%%\parse_cmd_script_name.bat" "%%CMD_SCRIPT_FILE_NAME%%" || exit /b

if not defined CMD_NAME (
  echo.%~nx0: error: CMD_NAME is not set.
  exit /b 3
) >&2
if not defined HUB_ABBR (
  echo.%~nx0: error: HUB_ABBR is not set.
  exit /b 4
) >&2
if not defined SCM_NAME (
  echo.%~nx0: error: SCM_NAME is not set.
  exit /b 5
) >&2

set "PROJECTS_ROOT=%CONFIGURE_ROOT%"

call set "SCM_PROJECT_PATH_LIST=%%%SCM_NAME%.PROJECT_PATH_LIST%%"

set ERROR_CMD_SCRIPT_COUNT=0

echo PROJECTS_ROOT=%PROJECTS_ROOT%
for %%i in (%SCM_PROJECT_PATH_LIST%) do (
  set "CMD_SCRIPT_REL_PATH=%%i\%HUB_ABBR%~%SCM_NAME%~%CMD_NAME%"
  call set "CMD_SCRIPT_ABS_PATH=%%PROJECTS_ROOT%%\%%CMD_SCRIPT_REL_PATH%%.bat"
  call :PROCESS_CMD_SCRIPT
)

if %ERROR_CMD_SCRIPT_COUNT% GTR 0 (
  echo Overall scripts failed: %ERROR_CMD_SCRIPT_COUNT%
  for /L %%i in (1,1,%ERROR_CMD_SCRIPT_COUNT%) do (
    call echo. - "%%ERROR_CMD_SCRIPT_PATH[%%i]%%"
  )
)

exit /b

:PROCESS_CMD_SCRIPT
echo.%CMD_SCRIPT_REL_PATH%...
if exist "%CMD_SCRIPT_ABS_PATH%" (
  call "%%CMD_SCRIPT_ABS_PATH%%" || call :REGISTER_SCRIPT_ERROR
) else (
  echo.%CMD_SCRIPT_REL_PATH%: info: ignored, script is not found
  call :REGISTER_SCRIPT_ERROR
)
echo.---
echo.

exit /b 0

:REGISTER_SCRIPT_ERROR
rem register error script to print it at the end
set /A ERROR_CMD_SCRIPT_COUNT+=1
set "ERROR_CMD_SCRIPT_PATH[%ERROR_CMD_SCRIPT_COUNT%]=%CMD_SCRIPT_ABS_PATH%"

exit /b 0
