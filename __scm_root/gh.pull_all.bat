@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

rem from leaf repositories to a root repository
echo contools--Tools pulling...
call "%%PROJECTS_ROOT%%\_contools\contools--Tools_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo svncmd--Scripts pulling...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd--Scripts_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo external_tools pulling...
call "%%PROJECTS_ROOT%%\_contools\external_tools_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo contools pulling...
call "%%PROJECTS_ROOT%%\_contools\contools_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo svncmd pulling...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupLib pulling...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupDev pulling...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupSamples pulling...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_gh.pull_all.bat" %%* || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
