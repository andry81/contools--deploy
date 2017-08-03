@echo off

setlocal

(
  echo.@echo off
  echo.
  echo.set SVN.PROJECT_PATH_LIST=contools\{{HUB_ABBR}}~deploy nsisplus\{{HUB_ABBR}}~deploy svncmd\{{HUB_ABBR}}~deploy ^^
  echo.  contools\{{HUB_ABBR}}~external_tools contools\{{HUB_ABBR}}~contools svncmd\{{HUB_ABBR}}~svncmd ^^
  echo.  nsisplus\{{HUB_ABBR}}~NsisSetupLib nsisplus\{{HUB_ABBR}}~NsisSetupDev nsisplus\{{HUB_ABBR}}~NsisSetupSamples
  echo.
  echo.rem from leaf repositories to a root repository
  echo.set GIT.PROJECT_PATH_LIST= contools\{{HUB_ABBR}}~contools--deploy nsisplus\{{HUB_ABBR}}~nsisplus--deploy svncmd\{{HUB_ABBR}}~svncmd--deploy ^^
  echo.  contools\{{HUB_ABBR}}~contools--Tools svncmd\{{HUB_ABBR}}~svncmd--Scripts ^^
  echo.  contools\{{HUB_ABBR}}~external_tools contools\{{HUB_ABBR}}~contools svncmd\{{HUB_ABBR}}~svncmd ^^
  echo.  nsisplus\{{HUB_ABBR}}~nsisplus--NsisSetupLib nsisplus\{{HUB_ABBR}}~nsisplus--NsisSetupDev nsisplus\{{HUB_ABBR}}~nsisplus--NsisSetupSamples
  echo.
) > "%~dp0configure.user.bat"
