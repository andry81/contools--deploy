@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

if not defined NEST_LVL set NEST_LVL=0

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

set "BASE_SCRIPTS_ROOT=%CONFIGURE_ROOT%\_common"
set "CONTOOLS_ROOT=%BASE_SCRIPTS_ROOT%\tools"
set "TACKLELIB_ROOT=%BASE_SCRIPTS_ROOT%\tools\tacklelib"
set "CMDOPLIB_ROOT=%BASE_SCRIPTS_ROOT%\tools\cmdoplib"

rem call "%%CONTOOLS_ROOT%%\load_config.bat" "%%CONFIGURE_ROOT%%" "config.private.vars" || exit /b
call "%%CONTOOLS_ROOT%%\load_config.bat" "%%CONFIGURE_ROOT%%" "config.vars" || exit /b

if defined CHCP chcp %CHCP%

set __BASE_INIT__=1
