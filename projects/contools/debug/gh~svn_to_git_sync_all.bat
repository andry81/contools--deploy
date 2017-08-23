@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

if not exist "%~dp0..\configure.user.bat" ( call "%%~dp0..\configure.bat" || goto :EOF )
if not exist "%~dp0..\configureex.user.bat" ( call "%%~dp0..\configureex.bat" || goto :EOF )
if not exist "%~dp0configure.user.bat" ( call "%%~dp0configure.bat" || goto :EOF )

call "%%~dp0..\configure.user.bat" || goto :EOF
call "%%~dp0..\configureex.user.bat" || goto :EOF
call "%%~dp0configure.user.bat" || goto :EOF

rem extract name of sync directory from name of the script
set "?~nx0=%~nx0"
set "?~n0=%~n0"

set "WCROOT=%GIT.WCROOT_DIR%"
if not defined WCROOT ( call :EXIT_B -254 & goto EXIT )

if not "%WCROOT_OFFSET%" == "" set "WCROOT=%WCROOT_OFFSET%/%WCROOT%"

pushd "%~dp0%WCROOT%" && (
  rem check ref on existance
  git ls-remote -h --exit-code "%CONTOOLS_DEBUG.GIT.ORIGIN%" master > nul && (
    call :CMD git pull origin master || ( popd & goto EXIT )
  )
  call :CMD git svn fetch || ( popd & goto EXIT )
  call :CMD git svn rebase || ( popd & goto EXIT )
  call :CMD git push origin master || ( popd & goto EXIT )
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
