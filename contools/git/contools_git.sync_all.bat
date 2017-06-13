@echo off

pushd "%~dp0contools_git" && (
  call :CMD git pull origin master || ( popd & goto EXIT )
  call :CMD git subtree pull --prefix=Scripts/Tools tools master || ( popd & goto EXIT )
  call :CMD git subtree pull --prefix=Scripts/Tools/scm/svn --squash tools-svn master || ( popd & goto EXIT )
  call :CMD git push origin master || ( popd & goto EXIT )
)

:EXIT
pause
exit /b

:CMD
echo.^>%*
(%*)
echo.
