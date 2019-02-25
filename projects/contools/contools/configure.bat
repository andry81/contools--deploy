@echo off

echo.^>%~dpnx0

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

(
  type "%~dp0config.vars.in"
) > "%~dp0config.vars"

(
  type "%~dp0repos.lst.in"
) > "%~dp0repos.lst"

set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
