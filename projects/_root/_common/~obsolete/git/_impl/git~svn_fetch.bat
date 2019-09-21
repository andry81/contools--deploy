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

call :MAIN %~4 %~5 %~6 %~7 %~8 %~9
exit /b

:MAIN
call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR exit /b -254
if not defined WCROOT_OFFSET exit /b -253

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

set HAS_AT_LEAST_ONE_REMOTE=0
set FIRST_TIME_SYNC=0

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  rem # <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<git_path_prefix>|<svn_path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    if /i "%SCM_TOKEN%" == "%%i" if /i "root" == "%%j" set HAS_AT_LEAST_ONE_REMOTE=1
  )

  call :IF_ %%HAS_AT_LEAST_ONE_REMOTE%% EQU 0 && ( popd & exit /b -128 )

  call :CMD git svn fetch %%* || ( popd & exit /b )

  popd
)

exit /b

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:IF_
if %* exit /b 0
exit /b 1

:CMD
echo.^>%*
(%*)
echo.
