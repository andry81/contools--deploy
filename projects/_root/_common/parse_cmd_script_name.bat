@echo off

setlocal

set "CMD_SCRIPT_FILE_NAME=%~1"

set "CMD_SCRIPT_NAME=%~n1"
set "CMD_SCRIPT_EXT=%~x1"

set "CMD_SCRIPT_NAME_SUFFIX=%CMD_SCRIPT_NAME:*~=%"
if "%CMD_SCRIPT_NAME_SUFFIX%" == "%CMD_SCRIPT_NAME%" exit /b 255

set "HUB_ABBR=%CMD_SCRIPT_NAME%"
call set "HUB_ABBR=%%HUB_ABBR:%CMD_SCRIPT_NAME_SUFFIX%=%%"
set "HUB_ABBR=%HUB_ABBR:~0,-1%"

set "CMD_NAME=%CMD_SCRIPT_NAME_SUFFIX:*~=%"
if "%CMD_NAME%" == "%CMD_SCRIPT_NAME_SUFFIX%" exit /b 255

call set "SCM_NAME=%%CMD_SCRIPT_NAME_SUFFIX:%CMD_NAME%=%%"
set "SCM_NAME=%SCM_NAME:~0,-1%"

rem return only predefined set of variables
(
  endlocal
  set "HUB_ABBR=%HUB_ABBR%"
  set "SCM_NAME=%SCM_NAME%"
  set "CMD_NAME=%CMD_NAME%"
)

exit /b 0
