@echo off

call "%%~dp0..\__init__.bat" || exit /b
call "%%CONFIGURE_ROOT%%\_common\load_config.bat" "%%~dp0" "config.vars" || exit /b
