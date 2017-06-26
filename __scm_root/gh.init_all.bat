@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

set "PROJECTS_ROOT=%~dp0.."

rem from leaf repositories to a root repository
echo contools--Tools Initing...
call "%%PROJECTS_ROOT%%\_contools\contools--Tools_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo svncmd--Scripts Initing...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd--Scripts_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo external_tools Initing...
call "%%PROJECTS_ROOT%%\_contools\external_tools_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo contools Initing...
call "%%PROJECTS_ROOT%%\_contools\contools_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo svncmd Initing...
call "%%PROJECTS_ROOT%%\_svncmd\svncmd_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupLib Initing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupLib_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupDev Initing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupDev_gh.init.bat" %%* || goto EXIT
echo.---
echo.

echo NsisSetupSamples Initing...
call "%%PROJECTS_ROOT%%\_nsisplus\NsisSetupSamples_gh.init.bat" %%* || goto EXIT
echo.---
echo.

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause
