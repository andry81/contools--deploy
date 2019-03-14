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

set "DATETIME_VALUE="
for /F "usebackq eol=	 tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if "%%i" == "LocalDateTime" set "DATETIME_VALUE=%%j"

if not defined DATETIME_VALUE (
  echo.%~nx0: error: could not retrieve a date time value to create unique temporary directory.
  exit /b -128
) >&2

set "DATETIME_VALUE=%DATETIME_VALUE:~0,18%"

set "TEMP_DATE=%DATETIME_VALUE:~0,4%_%DATETIME_VALUE:~4,2%_%DATETIME_VALUE:~6,2%"
set "TEMP_TIME=%DATETIME_VALUE:~8,2%_%DATETIME_VALUE:~10,2%_%DATETIME_VALUE:~12,2%_%DATETIME_VALUE:~15,3%"

set "TEMP_OUTPUT_DIR=%TEMP%\%~n0.%TEMP_DATE%.%TEMP_TIME%"

set "STDOUT_FILE_TMP=%TEMP_OUTPUT_DIR%\stdout.txt"
set "STDERR_FILE_TMP=%TEMP_OUTPUT_DIR%\stderr.txt"

rem create temporary files to store local context output
if exist "%TEMP_OUTPUT_DIR%\" (
  echo.%~nx0: error: temporary generated directory TEMP_OUTPUT_DIR is already exist: "%TEMP_OUTPUT_DIR%"
  exit /b -255
) >&2

mkdir "%TEMP_OUTPUT_DIR%"

call :MAIN
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%TEMP_OUTPUT_DIR%"

call :EXIT_B %%LASTERROR%%

goto EXIT

:MAIN
call set "WCROOT_DIR=%%%SCM_TOKEN%.WCROOT_DIR%%"
if not defined WCROOT_DIR exit /b -254
if not defined WCROOT_OFFSET exit /b -253

set HAS_AT_LEAST_ONE_REMOTE=0
for /F "usebackq eol=# tokens=1,* delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
  if /i "%SCM_TOKEN%" == "%%i" ( set "HAS_AT_LEAST_ONE_REMOTE=1" & goto WCROOT )
)

if %HAS_AT_LEAST_ONE_REMOTE% EQU 0 exit /b -250

:WCROOT
call :GETWCROOT "%WCROOT_OFFSET%/%WCROOT_DIR%"

if not exist "%WCROOT%" mkdir "%WCROOT%"
if not exist "%WCROOT%\.git" ( call :CMD git init "%%WCROOT%%" || exit /b )

call set GIT_SVN_INIT_CMDLINE=%%%SCM_TOKEN%.GIT_SVN_INIT_CMDLINE%%
call set "GIT_USER=%%%SCM_TOKEN%.USER%%"
call set "GIT_EMAIL=%%%SCM_TOKEN%.USER%%"

echo."%WCROOT%"...

pushd "%WCROOT%" && (
  rem reinit git svn
  call :GIT_SVN_INIT %GIT_SVN_INIT_CMDLINE% || ( popd & exit /b )

  call :CMD git config user.name "%%GIT_USER%%" || ( popd & exit /b )
  call :CMD git config user.email "%%GIT_EMAIL%%" || ( popd & exit /b )

  rem <scm_token>|<branch_type>|<remote_name>|<remote_url>|<local_branch>|<remote_branch>|<path_prefix>|<git_remote_add_cmdline>|<git_subtree_cmdline>
  for /F "usebackq eol=# tokens=1,3,4,8 delims=|" %%i in ("%REPOS_LIST_FILE_PATH%") do (
    set "CONFIG_REMOTE_URL_NAME=%%j"
    set "CONFIG_REMOTE_URL=%%k"
    set "CONFIG_REMOTE_URL_ADD_CMDLINE=%%l"
    if /i "%SCM_TOKEN%" == "%%i" call :GIT_REGISTER_REMOTE_URL
  )

  popd
)

exit /b

:GETWCROOT
set "WCROOT=%~dpf1"
exit /b

:GIT_REGISTER_REMOTE_URL
if "%CONFIG_REMOTE_URL_ADD_CMDLINE%" == "." set "CONFIG_REMOTE_URL_ADD_CMDLINE="

(
  git remote get-url "%CONFIG_REMOTE_URL_NAME%" > nul 2> nul && call :CMD git remote set-url "%%CONFIG_REMOTE_URL_NAME%%" "%CONFIG_REMOTE_URL%"
) || call :CMD git remote add "%%CONFIG_REMOTE_URL_NAME%%" "%CONFIG_REMOTE_URL%" %CONFIG_REMOTE_URL_ADD_CMDLINE% || ( popd & goto EXIT )
exit /b

:CMD
echo.^>%*
(
  %*
)
echo.
exit /b

:GIT_SVN_INIT
setlocal ENABLEDELAYEDEXPANSION

rem workarounds for `git init`
call :CMD_W_STDIO git svn init %%* || goto GIT_SVN_RESET_CONFIG_URL

rem test on assertion (where empty url: [svn-remote "svn"]	url = )
rem `assertion "type != type_uri" failed: file "subversion/libsvn_subr/dirent_uri.c", line 312, function: canonicalize`
rem `      0 [main] perl 15212 cygwin_exception::open_stackdumpfile: Dumping stack trace to perl.exe.stackdump`
if "!STDERR_VALUE!" == "" exit /b
if not "!STDERR_VALUE:~0,10!" == "assertion " exit /b

:GIT_SVN_RESET_CONFIG_URL
rem reset svn-remote.svn.url
call :CMD git config --local --replace-all svn-remote.svn.url %%* || exit /b

rem create git-svn reference
if not exist ".git\refs\remotes\git-svn" if exist ".git\refs\remotes\" (
  if exist ".git\refs\heads\master" (
    call :CMD git update-ref refs/remotes/git-svn master || exit /b
  )
)

exit /b

:CMD_W_STDIO
echo.^>%*
set "STDOUT_VALUE="
set "STDERR_VALUE="
(
  %*
) > "%STDOUT_FILE_TMP%" 2> "%STDERR_FILE_TMP%"
rem print back to stdout/stderr immediately
rem type "%STDERR_FILE_TMP%" >&2
rem type "%STDOUT_FILE_TMP%"
set /P STDERR_VALUE=< "%STDERR_FILE_TMP%"
set /P STDOUT_VALUE=< "%STDOUT_FILE_TMP%"
echo.
exit /b

goto EXIT

:EXIT_B
exit /b %*

:EXIT
set /A NEST_LVL-=1

if %NEST_LVL% LEQ 0 pause

exit /b
