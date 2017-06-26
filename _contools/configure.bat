@echo off

setlocal

(
  echo.@echo off
  echo.
  echo set "GIT.REPO_OWNER=andry81"
  echo set "GIT.USER=user"
  echo set "GIT.EMAIL=user@mail.com"
  echo.
  echo set "CONTOOLS_ROOT.SVN.REPOROOT=https://svn.code.sf.net/p/contools/contools/trunk"
  echo set "CONTOOLS_TOOLS.SVN.REPOROOT=https://svn.code.sf.net/p/contools/contools/trunk/Scripts/Tools"
  echo set "EXTERNAL_TOOLS.SVN.REPOROOT=https://svn.code.sf.net/p/contools/external_tools/trunk"
  echo.
  echo set "CONTOOLS_ROOT.GIT.ORIGIN=https://github.com/%%GIT.REPO_OWNER%%/contools.git"
  echo set "CONTOOLS_TOOLS.GIT.ORIGIN=https://github.com/%%GIT.REPO_OWNER%%/contools--Tools.git"
  echo set "CONTOOLS_TOOLS_SVN.GIT.ORIGIN=https://github.com/%%GIT.REPO_OWNER%%/svncmd--Scripts.git"
  echo set "EXTERNAL_TOOLS.GIT.ORIGIN=https://github.com/%%GIT.REPO_OWNER%%/external_tools.git"
) > "%~dp0configure.user.bat"
