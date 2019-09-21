@echo off

setlocal

set "CONFIGURE_DIR=%~1"
set "SCM_TOKEN=%~2"

set "REPOS_LIST_FILE_PATH=%CONFIGURE_DIR%\repos.lst"

if not defined CONFIGURE_DIR (
  echo.%~nx0: error: CONFIGURE_DIR is not defined.
  exit /b 1
) >&2

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 2
) >&2

if "%CONFIGURE_DIR:~-1%" == "\" set "CONFIGURE_DIR=%CONFIGURE_DIR:~0,-1%"

if not exist "%CONFIGURE_DIR%\" (
  echo.%~nx0: error: CONFIGURE_DIR directory does not exist: "%CONFIGURE_DIR%"
  exit /b 3
) >&2

if not exist "%REPOS_LIST_FILE_PATH%" (
  echo.%~nx0: error: REPOS_LIST_FILE_PATH does not exist: "%REPOS_LIST_FILE_PATH%"
  exit /b 4
) >&2

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR exit /b -254
if not defined WCROOT_OFFSET exit /b -253

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  call :CMD git reset %%4 %%5 %%6 %%7 %%8 %%9 || ( popd & exit /b )
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
