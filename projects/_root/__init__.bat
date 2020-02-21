@echo off

if %__BASE_INIT__%0 NEQ 0 exit /b

if not defined NEST_LVL set NEST_LVL=0

set "CONFIGURE_ROOT=%~dp0"
set "CONFIGURE_ROOT=%CONFIGURE_ROOT:~0,-1%"

set "LOCAL_CONFIG_DIR_NAME=_config"

set "PYXVCS_SCRIPTS_ROOT=%CONFIGURE_ROOT%\_pyxvcs"
set "CONTOOLS_ROOT=%PYXVCS_SCRIPTS_ROOT%\tools"
set "TACKLELIB_ROOT=%PYXVCS_SCRIPTS_ROOT%\tools\tacklelib"
set "CMDOPLIB_ROOT=%PYXVCS_SCRIPTS_ROOT%\tools\cmdoplib"
set "TMPL_CMDOP_FILES_DIR=%CONFIGURE_ROOT%\%LOCAL_CONFIG_DIR_NAME%\tmpl"

call "%%CONTOOLS_ROOT%%\load_config.bat" "%%CONFIGURE_ROOT%%\%%LOCAL_CONFIG_DIR_NAME%%" "config.vars" || exit /b

if defined CHCP chcp %CHCP%

set __BASE_INIT__=1

exit /b
