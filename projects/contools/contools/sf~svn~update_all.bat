@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%CONFIGURE_ROOT%%\_common\svn\svn~update_all.bat" SVN "%%~dp0config.vars" || exit /b