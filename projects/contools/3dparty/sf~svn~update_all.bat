@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%BASE_SCRIPTS_ROOT%%\svn\svn~update_all.bat" SVN || exit /b
