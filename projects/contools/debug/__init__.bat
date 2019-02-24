@echo off

call "%%~dp0..\__init__.bat" || exit /b

if not exist "%~dp0configure.user.bat" ( call "%%~dp0configure.bat" || exit /b )

call "%~dp0configure.user.bat" || exit /b
