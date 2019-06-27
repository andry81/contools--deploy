@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%BASE_SCRIPTS_ROOT%%\git\git~svn_fetch.bat" GIT2 "%%~dp0repos.lst" %%* || exit /b
