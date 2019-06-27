@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

if not defined NEST_LVL set NEST_LVL=0

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

set "BASE_SCRIPTS_ROOT=%CONFIGURE_ROOT%\_common"
set "CONTOOLS_ROOT=%BASE_SCRIPTS_ROOT%\tools"

call "%%BASE_SCRIPTS_ROOT%%\load_config.bat" "%%CONFIGURE_ROOT%%" "config.private.vars" || exit /b
call "%%BASE_SCRIPTS_ROOT%%\load_config.bat" "%%CONFIGURE_ROOT%%" "config.vars" || exit /b

rem no local logging if nested call
if %NEST_LVL%0 EQU 0 ^
if not exist "%CONFIGURE_ROOT%\.log" mkdir "%CONFIGURE_ROOT%\.log"

set __BASE_INIT__=1
