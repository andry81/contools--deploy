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

set HAS_AT_LEAST_ONE_REMOTE=0
set FIRST_TIME_SYNC=0

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  rem # <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<git_path_prefix>|<svn_path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2,3,4,5,6 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    set "CONFIG_REMOTE_URL_NAME=%%k"
    set "CONFIG_REMOTE_URL=%%l"
    set "CONFIG_LOCAL_BRANCH=%%m"
    set "CONFIG_REMOTE_BRANCH=%%n"
    if /i "%SCM_TOKEN%" == "%%i" if /i "root" == "%%j" ( call :GIT_PULL || ( popd & exit /b ) )
  )

  call :IF_ %%HAS_AT_LEAST_ONE_REMOTE%% EQU 0 && ( popd & exit /b -128 )

  call :CMD git svn fetch || ( popd & exit /b )
  call :CMD git svn rebase || ( popd & exit /b )

  call :FIRST_TIME_CLEANUP

  rem # <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<git_path_prefix>|<svn_path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2,3,4,5,6,7,10 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    set "CONFIG_REMOTE_URL_NAME=%%k"
    set "CONFIG_REMOTE_URL=%%l"
    set "CONFIG_LOCAL_BRANCH=%%m"
    set "CONFIG_REMOTE_BRANCH=%%n"
    set "CONFIG_PATH_PREFIX=%%o"
    set "CONFIG_SUBTREE_CMDLINE=%%p"
    if /i "%SCM_TOKEN%" == "%%i" if /i "subtree" == "%%j" ( call :GIT_SUBTREE_PULL || ( popd & exit /b ) )
  )

  popd
)

exit /b

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:GIT_SUBTREE_PULL
set "PULL_BRANCH_TOKEN=%CONFIG_LOCAL_BRANCH%"
if "%PULL_BRANCH_TOKEN%" == "." set "PULL_BRANCH_TOKEN="
if not defined PULL_BRANCH_TOKEN (
  set "PULL_BRANCH_TOKEN=%CONFIG_REMOTE_BRANCH%"
) else (
  if defined CONFIG_REMOTE_BRANCH if not "%CONFIG_REMOTE_BRANCH%" == "." ^
if not "%CONFIG_REMOTE_BRANCH%" == "%CONFIG_LOCAL_BRANCH%" set "PULL_BRANCH_TOKEN=%CONFIG_REMOTE_BRANCH%:%PULL_BRANCH_TOKEN%"
)

if defined CONFIG_SUBTREE_CMDLINE if "%CONFIG_SUBTREE_CMDLINE%" == "." set "CONFIG_SUBTREE_CMDLINE="

call :CMD git subtree add --prefix="%%CONFIG_PATH_PREFIX%%" %CONFIG_SUBTREE_CMDLINE% "%%CONFIG_REMOTE_URL_NAME%%" "%%PULL_BRANCH_TOKEN%%" || (
  call :CMD git subtree pull --prefix="%%CONFIG_PATH_PREFIX%%" %CONFIG_SUBTREE_CMDLINE% "%%CONFIG_REMOTE_URL_NAME%%" "%%PULL_BRANCH_TOKEN%%" || exit /b
)

exit /b 0

:GIT_PULL
set HAS_AT_LEAST_ONE_REMOTE=1

set "PULL_BRANCH_TOKEN=%CONFIG_LOCAL_BRANCH%"
if "%PULL_BRANCH_TOKEN%" == "." set "PULL_BRANCH_TOKEN="
if not defined PULL_BRANCH_TOKEN (
  set "PULL_BRANCH_TOKEN=%CONFIG_REMOTE_BRANCH%"
) else (
  if defined CONFIG_REMOTE_BRANCH if not "%CONFIG_REMOTE_BRANCH%" == "." ^
if not "%CONFIG_REMOTE_BRANCH%" == "%CONFIG_LOCAL_BRANCH%" set "PULL_BRANCH_TOKEN=%CONFIG_REMOTE_BRANCH%:%PULL_BRANCH_TOKEN%"
)

(
  rem check ref on existance
  call git ls-remote -h --exit-code "%CONFIG_REMOTE_URL%" "%%PULL_BRANCH_TOKEN%%" > nul && (
    call :CMD git pull "%%CONFIG_REMOTE_URL_NAME%%" "%%PULL_BRANCH_TOKEN%%" || exit /b
  )
) || set FIRST_TIME_SYNC=1

exit /b 0

:IF_
if %* exit /b 0
exit /b 1

:CMD
echo.^>%*
(%*)
echo.

:FIRST_TIME_CLEANUP
if %FIRST_TIME_SYNC% EQU 0 exit /b 0
rem cleanup empty directories after rebase
rem call :CMD git clean -fd
