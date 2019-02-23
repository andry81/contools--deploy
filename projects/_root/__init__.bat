@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

if not exist "%CONFIGURE_ROOT%\configure_private.user.bat" ( call "%%CONFIGURE_ROOT%%\configure_private.bat" || exit /b )
if not exist "%CONFIGURE_ROOT%\configure.user.bat" ( call "%%CONFIGURE_ROOT%%\configure.bat" || exit /b )

call "%%CONFIGURE_ROOT%%\configure_private.user.bat" || exit /b
call "%%CONFIGURE_ROOT%%\configure.user.bat" || exit /b

set __BASE_INIT__=1
