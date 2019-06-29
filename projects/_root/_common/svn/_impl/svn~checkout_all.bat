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

call set "SVN.CHECKOUT_URL=%%%SCM_TOKEN%.CHECKOUT_URL%%"

echo."%WCROOT%"...

if not exist "%WCROOT%\" mkdir "%WCROOT%"
if not exist "%WCROOT%\.svn" ( call :CMD svn co "%SVN.CHECKOUT_URL%" "%%WCROOT%%" || exit /b )

exit /b

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:CMD
echo.^>%*
(%*)
echo.
