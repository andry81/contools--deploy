@echo off

setlocal

if "%NEST_LVL%" == "" set NEST_LVL=0

set /A NEST_LVL+=1

pushd "%~dp0contools_git" && (
  call :CMD git pull origin master || ( popd & goto EXIT )
  call :CMD git subtree pull --prefix=Scripts/Tools tools master || ( popd & goto EXIT )
  call :CMD git subtree pull --prefix=Scripts/Tools/scm/svn --squash tools-svn master || ( popd & goto EXIT )
  call :CMD git push origin master || ( popd & goto EXIT )
)

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b

:CMD
echo.^>%*
(%*)
echo.
