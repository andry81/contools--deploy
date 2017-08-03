@echo off

setlocal

(
  echo.@echo off
  echo.
  echo.set SVN.PROJECT_PATH_LIST=_contools\{{HUB_ABBR}}~external_tools _contools\{{HUB_ABBR}}~contools _svncmd\{{HUB_ABBR}}~svncmd ^^
  echo.  _nsisplus\{{HUB_ABBR}}~NsisSetupLib _nsisplus\{{HUB_ABBR}}~NsisSetupDev _nsisplus\{{HUB_ABBR}}~NsisSetupSamples
  echo.
  echo.rem from leaf repositories to a root repository
  echo.set GIT.PROJECT_PATH_LIST=_contools\{{HUB_ABBR}}~contools--Tools _svncmd\{{HUB_ABBR}}~svncmd--Scripts ^^
  echo.  _contools\{{HUB_ABBR}}~external_tools _contools\{{HUB_ABBR}}~contools _svncmd\{{HUB_ABBR}}~svncmd ^^
  echo.  _nsisplus\{{HUB_ABBR}}~NsisSetupLib _nsisplus\{{HUB_ABBR}}~NsisSetupDev _nsisplus\{{HUB_ABBR}}~NsisSetupSamples
  echo.
) > "%~dp0configure.user.bat"
