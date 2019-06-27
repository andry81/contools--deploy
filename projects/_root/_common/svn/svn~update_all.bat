@echo off

setlocal

set "SCM_TOKEN=%~1"

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 1
) >&2

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || goto EXIT

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR ( call :EXIT_B -254 & goto EXIT )
if not defined WCROOT_OFFSET ( call :EXIT_B -253 & goto EXIT )

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  call :CMD svn up || ( popd & goto EXIT )
  popd
)

goto EXIT

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

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
