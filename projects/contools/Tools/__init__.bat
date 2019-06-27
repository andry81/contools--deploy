@echo off

call "%%~dp0..\__init__.bat" || exit /b

set "CONFIGURE_DIR=%~dp0"
set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

call "%%BASE_SCRIPTS_ROOT%%\load_config.bat" "%%CONFIGURE_DIR%%" "config.vars" || exit /b

rem no local logging if nested call
if %NEST_LVL%0 EQU 0 ^
if not exist "%CONFIGURE_DIR%\.log" mkdir "%CONFIGURE_DIR%\.log"
