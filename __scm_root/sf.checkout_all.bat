@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

echo contools checkouting...
call "%%PROJECTS_ROOT%%\_contools\contools_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

echo external_tools checkouting...
call "%%PROJECTS_ROOT%%\_contools\external_tools_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

echo svncmd checkouting...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupLib checkouting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupDev checkouting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupSamples checkouting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_sf.checkout_all.bat" || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
