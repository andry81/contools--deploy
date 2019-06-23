@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%CONFIGURE_ROOT%%\_common\configure_directory.bat" "%%~dp0" || exit /b
