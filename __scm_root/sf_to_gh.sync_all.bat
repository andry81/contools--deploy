@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

rem from leaf repositories to a root repository
echo contools--Tools syncing...
call "%%PROJECTS_ROOT%%\_contools\contools--Tools_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo svncmd--Scripts syncing...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd--Scripts_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo external_tools syncing...
call "%%PROJECTS_ROOT%%\_contools\external_tools_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo contools syncing...
call "%%PROJECTS_ROOT%%\_contools\contools_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo svncmd syncing...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupLib syncing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupDev syncing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_gh.sync_all.bat" || goto EXIT
echo.---
echo.

echo NsisSetupSamples syncing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_gh.sync_all.bat" || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
