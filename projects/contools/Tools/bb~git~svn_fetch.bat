@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set "CONFIGURE_DIR=%~dp0"
set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

call "%%BASE_SCRIPTS_ROOT%%\git\git~svn_fetch.bat" GIT2 %%* || exit /b
