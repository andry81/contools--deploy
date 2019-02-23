@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b
call "%%CONFIGURE_ROOT%%\_common\cmdop.bat" "%%~nx0" || exit /b

if %NEST_LVL%0 EQU 0 pause
