@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

if not exist "%~dp0configure_private.user.bat" ( call "%%~dp0configure_private.bat" || exit /b )
if not exist "%~dp0configure.user.bat" ( call "%%~dp0configure.bat" || exit /b )

call "%%~dp0configure_private.user.bat" || exit /b
call "%%~dp0configure.user.bat" || exit /b

set __BASE_INIT__=1
