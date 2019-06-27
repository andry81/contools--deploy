@echo off

setlocal

set "SCM_TOKEN=%~1"
set "REPOS_LIST_FILE_PATH=%~2"

if not defined SCM_TOKEN (
  echo.%~nx0: error: SCM_TOKEN is not defined.
  exit /b 1
) >&2

if not exist "%REPOS_LIST_FILE_PATH%" (
  echo.%~nx0: error: REPOS_LIST_FILE_PATH is not exist: "%REPOS_LIST_FILE_PATH%"
  exit /b 2
) >&2

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || goto EXIT

call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR ( call :EXIT_B -254 & goto EXIT )
if not defined WCROOT_OFFSET ( call :EXIT_B -253 & goto EXIT )

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
    if /i "%SCM_TOKEN%" == "%%i" if /i "root" == "%%j" ( call :GIT_PULL || ( popd & goto EXIT ) )
  )

  call :IF_ %%HAS_AT_LEAST_ONE_REMOTE%% EQU 0 && ( popd & call :EXIT_B -128 & goto EXIT )

  call :CMD git svn fetch || ( popd & goto EXIT )
  call :CMD git svn rebase || ( popd & goto EXIT )

  call :FIRST_TIME_CLEANUP

  rem # <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<git_path_prefix>|<svn_path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2,3,4,5,6,7,10 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    set "CONFIG_REMOTE_URL_NAME=%%k"
    set "CONFIG_REMOTE_URL=%%l"
    set "CONFIG_LOCAL_BRANCH=%%m"
    set "CONFIG_REMOTE_BRANCH=%%n"
    set "CONFIG_PATH_PREFIX=%%o"
    set "CONFIG_SUBTREE_CMDLINE=%%p"
    if /i "%SCM_TOKEN%" == "%%i" if /i "subtree" == "%%j" ( call :GIT_SUBTREE_PULL || ( popd & goto EXIT ) )
  )

  rem DO NOT call rebase here!

  rem # <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<git_path_prefix>|<svn_path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,2,3,4,5,6 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    set "CONFIG_REMOTE_URL_NAME=%%k"
    set "CONFIG_REMOTE_URL=%%l"
    set "CONFIG_LOCAL_BRANCH=%%m"
    set "CONFIG_REMOTE_BRANCH=%%n"
    if /i "%SCM_TOKEN%" == "%%i" if /i "root" == "%%j" ( call :GIT_PUSH || ( popd & goto EXIT ) )
  )

  popd
)

goto EXIT

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

:GIT_PUSH
set "PUSH_BRANCH_TOKEN=%CONFIG_LOCAL_BRANCH%"
if "%PUSH_BRANCH_TOKEN%" == "." set "PUSH_BRANCH_TOKEN="
if not defined PUSH_BRANCH_TOKEN (
  set "PUSH_BRANCH_TOKEN=%CONFIG_REMOTE_BRANCH%"
) else (
  if defined CONFIG_REMOTE_BRANCH if not "%CONFIG_REMOTE_BRANCH%" == "." ^
if not "%CONFIG_REMOTE_BRANCH%" == "%CONFIG_LOCAL_BRANCH%" set "PUSH_BRANCH_TOKEN=%PUSH_BRANCH_TOKEN%:%CONFIG_REMOTE_BRANCH%"
)

call :CMD git push "%%CONFIG_REMOTE_URL_NAME%%" "%%PUSH_BRANCH_TOKEN%%" || exit /b

exit /b 0

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

:FIRST_TIME_CLEANUP
if %FIRST_TIME_SYNC% EQU 0 exit /b 0
rem cleanup empty directories after rebase
rem call :CMD git clean -fd
