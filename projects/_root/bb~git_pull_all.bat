@echo off

setlocal

set "?~n0=%~n0"
set "?~x0=%~x0"

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

set "OP_NAME=%?~n0:*~=%"
if "%OP_NAME%" == "%?~n0%" exit /b 255
set "HUB_ABBR=%?~n0%"
call set "HUB_ABBR=%%HUB_ABBR:%OP_NAME%=%%"
set "HUB_ABBR=%HUB_ABBR:~0,-1%"

call "%%~dp0_common\op.bat" "%%OP_NAME%%" "%%HUB_ABBR%%" GIT2

if %NEST_LVL%0 EQU 0 pause
