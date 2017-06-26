@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

rem from leaf repositories to a root repository
echo contools--Tools resetting...
call "%%PROJECTS_ROOT%%\_contools\contools--Tools_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

echo svncmd--Scripts resetting...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd--Scripts_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

echo external_tools resetting...
call "%%PROJECTS_ROOT%%\_contools\external_tools_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

echo contools resetting...
call "%%PROJECTS_ROOT%%\_contools\contools_gh.reset_all.bat" || %%* goto EXIT
echo.---
echo.

echo svncmd resetting...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_gh.reset_all.bat" || %%* goto EXIT
echo.---
echo.

echo NsisSetupLib resetting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupDev resetting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupSamples resetting...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_gh.reset_all.bat" %%* || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
