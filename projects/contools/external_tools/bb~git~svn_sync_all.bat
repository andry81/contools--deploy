@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || exit /b

set "WCROOT=%GIT2.WCROOT_DIR%"
if not defined WCROOT ( call :EXIT_B -254 & goto EXIT )

if not "%WCROOT_OFFSET%" == "" set "WCROOT=%WCROOT_OFFSET%/%WCROOT%"

pushd "%~dp0%WCROOT%" && (
  rem check ref on existance
  git ls-remote -h --exit-code "%EXTERNAL_TOOLS.GIT2.ORIGIN%" trunk > nul && (
    call :CMD git pull origin trunk:master || ( popd & goto EXIT )
  )
  call :CMD git svn fetch || ( popd & goto EXIT )
  call :CMD git svn rebase || ( popd & goto EXIT )
  call :CMD git push origin master:trunk || ( popd & goto EXIT )
  popd
)

goto EXIT

:EXIT_B
exit /b %*

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b

:CMD
echo.^>%*
(%*)
echo.
