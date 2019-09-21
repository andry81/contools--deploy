* README_EN.known_issuestxt
* 2019.09.09
* python/xonsh

1. KNOWN ISSUES
1.1. issues with the `source` operator
1.2. issues with the pipe `|` operator
1.3. isseus with the `@(...)` operator
1.4. issues with another modules
2. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. KNOWN ISSUES
-------------------------------------------------------------------------------
There is issues with the xonsh module which might be important to known before
change the .xsh script code.

-------------------------------------------------------------------------------
1.1. issues with the `source` operator
-------------------------------------------------------------------------------
* https://github.com/xonsh/xonsh/issues/3302 : "hangs around `source` operator"
* https://github.com/xonsh/xonsh/issues/3301 : "`source` xsh file with try/except does hang"
* https://github.com/xonsh/xonsh/issues/3299 : "hangs after `source` of a script which has been already sourced"

-------------------------------------------------------------------------------
1.2. issues with the pipe `|` operator
-------------------------------------------------------------------------------
* https://github.com/xonsh/xonsh/issues/3187 : "pipe from a function to the `more` command does hang (Windows)"
* https://github.com/xonsh/xonsh/issues/3202 : "`print` order broken while piping"
* https://github.com/xonsh/xonsh/issues/3198 : "can not use log from xonsh on any arbitrary xonsh code"

CAUTION:
  Because the inner xonsh piping is broken, there is no other option except to
  log the output through the external to python piping through the Window batch
  script and external utility.

-------------------------------------------------------------------------------
1.3. isseus with the `@(...)` operator
-------------------------------------------------------------------------------
* https://github.com/xonsh/xonsh/issues/3189 : "module `cmdix`/`yes` can not be interrupted (ctrl+c) from the python evaluation command `@(...)`"
* https://github.com/xonsh/xonsh/issues/3191 : "multiline python evaluation `@(...)` under try block fails with IndexError"
* https://github.com/xonsh/xonsh/issues/3192 : "multiline python evaluation `@(...)` breaks the parser"

NOTE:
  This is reason to always write the inner python evaluation blocks `@(..)`
  on a single line.

-------------------------------------------------------------------------------
1.4. issues with another modules
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3190 : "module `cmdix` executables is not visible from the python `Scripts` directory"
https://github.com/xonsh/xonsh/issues/3189 : "module `cmdix`/`yes` can not be interrupted (ctrl+c) from the python evaluation command `@(...)`"

-------------------------------------------------------------------------------
2. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
