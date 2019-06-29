@echo off

setlocal

set "SCM_TOKEN=%~1"

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 1
) >&2

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR exit /b -254
if not defined WCROOT_OFFSET exit /b -253

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  call :CMD svn up || ( popd & exit /b )
  popd
)

exit /b

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:CMD
echo.^>%*
(%*)
echo.
