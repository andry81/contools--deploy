@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

rem from leaf repositories to a root repository
echo common leafs syncing...
call "%%PROJECTS_ROOT%%\_contools\contools--Tools.sync_all.bat" || goto EXIT
call "%%PROJECTS_ROOT%%\_svncmd\svncmd--Scripts.sync_all.bat" || goto EXIT
echo.---
echo.

echo contools syncing...
call "%%PROJECTS_ROOT%%\_contools\contools_git.sync_all.bat" || goto EXIT
echo.---
echo.

echo svncmd syncing...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_git.sync_all.bat" || goto EXIT
echo.---
echo.

echo nsisplus syncing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_git.sync_all.bat" || goto EXIT
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_git.sync_all.bat" || goto EXIT
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_git.sync_all.bat" || goto EXIT
echo.---
echo.

echo external_tools syncing...
call "%%PROJECTS_ROOT%%\_contools\external_tools_git.sync_all.bat" || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
