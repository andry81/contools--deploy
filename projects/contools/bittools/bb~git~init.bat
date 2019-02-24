@echo off

setlocal

if not defined NEST_LVL set NEST_LVL=0

set /A NEST_LVL+=1

call "%%~dp0__init__.bat" || exit /b

set "DATETIME_VALUE="
for /F "usebackq eol=	 tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if "%%i" == "LocalDateTime" set "DATETIME_VALUE=%%j"

if not "%DATETIME_VALUE%" == "" set "DATETIME_VALUE=%DATETIME_VALUE:~0,18%"

set "TEMP_DATE=%DATETIME_VALUE:~0,4%_%DATETIME_VALUE:~4,2%_%DATETIME_VALUE:~6,2%"
set "TEMP_TIME=%DATETIME_VALUE:~8,2%_%DATETIME_VALUE:~10,2%_%DATETIME_VALUE:~12,2%_%DATETIME_VALUE:~15,3%"

set "TEMP_FILE_OUTTER_DIR=%TEMP%\%~n0.%TEMP_DATE%.%TEMP_TIME%"

set "STDOUT_FILE_TMP=%TEMP_FILE_OUTTER_DIR%\stdout.txt"
set "STDERR_FILE_TMP=%TEMP_FILE_OUTTER_DIR%\stderr.txt"

rem create temporary files to store local context output
if exist "%TEMP_FILE_OUTTER_DIR%\" (
  echo.%~nx0: error: temporary generated directory TEMP_FILE_OUTTER_DIR is already exist: "%TEMP_FILE_OUTTER_DIR%"
  exit /b -255
) >&2

mkdir "%TEMP_FILE_OUTTER_DIR%"

call :MAIN %%*
set LASTERROR=%ERRORLEVEL%

rem cleanup temporary files
rmdir /S /Q "%TEMP_FILE_OUTTER_DIR%"

exit /b %LASTERROR%

:MAIN
set "WCROOT=%GIT2.WCROOT_DIR%"
if not defined WCROOT ( call :EXIT_B -254 & goto EXIT )

if not "%WCROOT_OFFSET%" == "" set "WCROOT=%WCROOT_OFFSET%/%WCROOT%"

if not exist "%~dp0%WCROOT%" mkdir "%~dp0%WCROOT%"
if not exist "%~dp0%WCROOT%\.git" ( call :CMD git init "%%~dp0%%WCROOT%%" %%* || goto EXIT )

pushd "%~dp0%WCROOT%" && (
  rem reinit git svn
  call :GIT_SVN_INIT "%%CONTOOLS_BITTOOLS.SVN.REPOROOT%%" --stdlayout || ( popd & goto EXIT )

  call :CMD git config user.name "%%GIT2.USER%%" || ( popd & goto EXIT )
  call :CMD git config user.email "%%GIT2.EMAIL%%" || ( popd & goto EXIT )

  (
    git remote get-url origin > nul 2> nul && call :CMD git remote set-url origin "%%CONTOOLS_BITTOOLS.GIT2.ORIGIN%%"
  ) || call :CMD git remote add origin "%%CONTOOLS_BITTOOLS.GIT2.ORIGIN%%" || ( popd & goto EXIT )

  popd
)

goto EXIT

:CMD
echo.^>%*
(%*)
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
