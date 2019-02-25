@echo off

setlocal

set "SCM_TOKEN=%~1"
set "CONFIG_VARS_FILE_PATH=%~2"
set "REPOS_LIST_FILE_PATH=%~3"

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 1
) >&2

if not exist "%CONFIG_VARS_FILE_PATH%" (
  echo.%~nx0: error: CONFIG_VARS_FILE_PATH is not exist: "%CONFIG_VARS_FILE_PATH%"
  exit /b 2
) >&2

if not exist "%REPOS_LIST_FILE_PATH%" (
  echo.%~nx0: error: REPOS_LIST_FILE_PATH is not exist: "%REPOS_LIST_FILE_PATH%"
  exit /b 3
) >&2

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || goto EXIT

rem load configuration file
for /F "usebackq eol=# tokens=* delims=" %%i in ("%CONFIG_VARS_FILE_PATH%") do (
  set %%i
)

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR ( call :EXIT_B -254 & goto EXIT )
if not defined WCROOT_OFFSET ( call :EXIT_B -253 & goto EXIT )

call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

set HAS_AT_LEAST_ONE_REMOTE=0
set FIRST_TIME_SYNC=0

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  rem <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    if /i "%SCM_TOKEN%" == "%%i" if /i "root" == "%%j" set HAS_AT_LEAST_ONE_REMOTE=1
  )

  call :IF_ %%HAS_AT_LEAST_ONE_REMOTE%% EQU 0 && ( popd & call :EXIT_B -128 & goto EXIT )

  call :CMD git svn fetch || ( popd & goto EXIT )

  popd
)

goto EXIT

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:IF_
if %* exit /b 0
exit /b 1

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
