@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

call "%%CONFIGURE_ROOT%%\_common\load_config.bat" "%%CONFIGURE_ROOT%%" "config.private.vars" || exit /b
call "%%CONFIGURE_ROOT%%\_common\load_config.bat" "%%CONFIGURE_ROOT%%" "config.vars" || exit /b

set __BASE_INIT__=1
