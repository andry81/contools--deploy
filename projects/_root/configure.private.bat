@echo off

setlocal

call "%%~dp0__init__.bat" || exit /b

set /A NEST_LVL+=1

(
  type "%~dp0config.private.vars.in" || exit /b 255
) > "%~dp0config.private.vars"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
