@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%BASE_SCRIPTS_ROOT%%\cmdop.bat" "%%~nx0" || exit /b

if %NEST_LVL%0 EQU 0 pause
