* README_EN.known_issuestxt
* 2019.07.01
* deploy/projects/_root

1. KNOWN ISSUES
1.1. pipe from a function to the `more` command does hang (Windows)
1.2. different output in python evaluation command `@(...)` and python w/o evaluation
1.3. module `cmdix`/`yes` can not be interrupted (ctrl+c) from the python evaluation command `@(...)`
1.4. module `cmdix` executables is not visible from the python `Scripts` directory
1.5. multiline python evaluation `@(...)` under try block fails with IndexError
1.6. multiline python evaluation `@(...)` breaks the parser
2. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. KNOWN ISSUES
-------------------------------------------------------------------------------
There is issues with the xonsh module which might be important to known before
change the .xsh script code.

-------------------------------------------------------------------------------
1.1. pipe from a function to the `more` command does hang (Windows)
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3187

CAUTION:
  Because the inner xonsh piping is broken, there is no other option except to
  log the output through the external to python piping through the Window batch
  script and external utility.

-------------------------------------------------------------------------------
1.2. different output in python evaluation command `@(...)` and python w/o evaluation
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3188

NOTE:
  This is may be another reason to not use the inner xonsh piping as long as
  the inner python evaluation logic can silently make the output silent or
  suppress it at random places.

-------------------------------------------------------------------------------
1.3. module `cmdix`/`yes` can not be interrupted (ctrl+c) from the python evaluation command `@(...)`
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3189

-------------------------------------------------------------------------------
1.4. module `cmdix` executables is not visible from the python `Scripts` directory
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3190

-------------------------------------------------------------------------------
1.5. multiline python evaluation `@(...)` under try block fails with IndexError
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3191

NOTE:
  This is reason to always write the inner python evaluation blocks `@(..)`
  on a single line.

-------------------------------------------------------------------------------
1.6. multiline python evaluation `@(...)` breaks the parser
-------------------------------------------------------------------------------
https://github.com/xonsh/xonsh/issues/3192

NOTE:
  This is another reason to always write the inner python evaluation blocks
  `@(..)` on a single line.

-------------------------------------------------------------------------------
2. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
