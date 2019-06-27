@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%BASE_SCRIPTS_ROOT%%\git\git~reset_all.bat" GIT "%%~dp0repos.lst" %%* || exit /b
