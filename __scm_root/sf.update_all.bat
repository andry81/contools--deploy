@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

echo contools updating...
call "%%PROJECTS_ROOT%%\_contools\contools_sf.update_all.bat" || goto EXIT
echo.---
echo.

echo external_tools updating...
call "%%PROJECTS_ROOT%%\_contools\external_tools_sf.update_all.bat" || goto EXIT
echo.---
echo.

echo svncmd updating...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_sf.update_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupLib updating...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_sf.update_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupDev updating...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_sf.update_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupSamples updating...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_sf.update_all.bat" || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
