@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%CONFIGURE_ROOT%%\_common\git\git~init.bat" GIT2 "%%~dp0config.vars" "%%~dp0repos.lst" || exit /b
