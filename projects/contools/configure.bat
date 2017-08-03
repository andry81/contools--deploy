@echo off

setlocal

(
  echo.@echo off
  echo.
  echo.set PROJECT_NAME=contools
  echo.set "WCROOT_OFFSET=../../../_%%PROJECT_NAME%%"
  echo.
  echo.rem primary mirror: github.com
  echo set "GIT.REPO_OWNER=andry81"
  echo set "GIT.USER=user"
  echo set "GIT.EMAIL=user@mail.com"
  echo.
  echo.rem secondary mirror: bitbucket.org
  echo set "GIT2.REPO_OWNER=andry81"
  echo set "GIT2.USER=user"
  echo set "GIT2.EMAIL=user@mail.com"
  echo.
  echo set "CONTOOLS_ROOT.SVN.REPOROOT=https://svn.code.sf.net/p/contools/contools"
  echo set "CONTOOLS_TOOLS.SVN.REPOROOT=https://svn.code.sf.net/p/contools/contools/trunk/Scripts/Tools"
  echo set "EXTERNAL_TOOLS.SVN.REPOROOT=https://svn.code.sf.net/p/contools/external_tools"
  echo.
  echo set "CONTOOLS_ROOT.GIT.ORIGIN=https://%%GIT.USER%%@github.com/%%GIT.REPO_OWNER%%/contools.git"
  echo set "CONTOOLS_TOOLS.GIT.ORIGIN=https://%%GIT.USER%%@github.com/%%GIT.REPO_OWNER%%/contools--Tools.git"
  echo set "CONTOOLS_TOOLS_SVN.GIT.ORIGIN=https://%%GIT.USER%%@github.com/%%GIT.REPO_OWNER%%/svncmd--Scripts.git"
  echo set "EXTERNAL_TOOLS.GIT.ORIGIN=https://%%GIT.USER%%@github.com/%%GIT.REPO_OWNER%%/external_tools.git"
  echo.
  echo set "CONTOOLS_ROOT.GIT2.ORIGIN=https://%%GIT2.USER%%@bitbucket.org/%%GIT2.REPO_OWNER%%/contools.git"
  echo set "CONTOOLS_TOOLS.GIT2.ORIGIN=https://%%GIT2.USER%%@bitbucket.org/%%GIT2.REPO_OWNER%%/contools-tools.git"
  echo set "CONTOOLS_TOOLS_SVN.GIT2.ORIGIN=https://%%GIT2.USER%%@bitbucket.org/%%GIT2.REPO_OWNER%%/svncmd-scripts.git"
  echo set "EXTERNAL_TOOLS.GIT2.ORIGIN=https://%%GIT2.USER%%@bitbucket.org/%%GIT2.REPO_OWNER%%/external_tools.git"
  echo.
) > "%~dp0configure.user.bat"
