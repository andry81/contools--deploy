* README_EN.txt
* 2019.10.29
* deploy/projects/_root

1. DESCRIPTION
2. DIRECTORY DEPLOY STRUCTURE
3. PREREQUISITES
4. INSTALLATION
5. USAGE
5.1. Mirroring (merging) from SVN to GIT
6. KNOWN ISSUES
7. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
From SVN into GIT mirroring scripts for respective project repositories.

-------------------------------------------------------------------------------
2. DIRECTORY DEPLOY STRUCTURE
-------------------------------------------------------------------------------
The default directory structure is this:

/<root>
  |
  +-/__scm_solutions  - the deploy scripts checkout directory
  |  |
  |  +-/all-in-one    - all-in-one solution configuration deploy scripts
  |     |
  |     +-/<project_deploy_scripts> - a project deploy scripts represented a
  |     |                             repository as a subdirectory
  |     |
  |     ...
  |
  +-/_<project_WC_roots> - the root of a project with source working copies
  |
  ...

-------------------------------------------------------------------------------
3. PREREQUISITES
-------------------------------------------------------------------------------

Currently tested these set of OS platforms, interpreters and modules to run
from:

1. OS platforms.

* Windows 7 (`.bat` only)

2. Interpreters:

* python 3.7.4 (3.4+)

3. Modules

* Python site modules:

**  plumbum 1.6.7
    https://plumbum.readthedocs.io/en/latest/
    - to run python scripts in a shell like environment (.xsh)
**  win_unicode_console
    - to enable unicode symbols support in the Windows console
**  pyyaml 5.1.1
    - to read yaml format files (.yaml, .yml)
**  conditional 1.3
    - to support conditional `with` statements

Temporary dropped usage:

**  xonsh/0.9.11
    https://github.com/xonsh/xonsh
    - to run python scripts in a shell like environment (.xsh)
**  prompt-toolkit 2.0.9
    - optional dependency to the Xonsh on the Windows
**  cmdix 0.2.0
    https://github.com/jaraco/cmdix
    - extension to use Unix core utils within Python environment as plain
      executable or python function

-------------------------------------------------------------------------------
4. INSTALLATION
-------------------------------------------------------------------------------
1. run the solution root `configure.bat`
2. run the `configure_private.bat` in all subdirectories if not done yet
3. edit the `WCROOT_OFFSET` variable in the `configure.user.bat` to
   change the default directory structure
4. edit the `GIT.USER`/`GIT.EMAIL`/`GIT2.USER`/`GIT2.EMAIL` in projects's
   `configure_private.user.bat` to mirror from svn to git under unique account
   (will be showed in a merge info after a merge).

-------------------------------------------------------------------------------
5. USAGE
-------------------------------------------------------------------------------
Any deploy script format:
  `<HubAbbrivatedName>~<ScmName>~<CommandOperation>.bat`, where:

  `HubAbbrivatedName` - Hub abbrivated name to run a command for.
  `ScmName`           - Version Source Control service name in a hub.
  `CommandOperation`  - Command operation name to request.

  `HubAbbrivatedName` can be:
    `sf` - SourceForge
    `gl` - GitLab
    `gh` - GitHub
    `bb` - BitBucket

  `ScmName` can be:
    `git` - git source control
    `svn` - svn source control

  `CommandOperation` can be:

  [ScmName=git]
    `init`      - create and initialize local git working copy directory
    `fetch`     - fetch remote git repositories and optionally does
                  (by default is) the pull of all subtrees
    `pull`      - pull remote git repositories and optionally does
                  (by default is) the fetch of all subtrees
    `reset`     - reset local working copy and optionally does
                  (by default is) the reset of all subtree working copies
    `push_svn_to_git` - same as `pull` plus pushes local git working copy
                  to the remote <ScmName> repository
  [ScmName=svn]
    `checkout`  - checks out an svn repository into new svn working copy
                  directory
    `update`    - updates svn working copy directory from the remote svn
                  repository
    `relocate`  - updates svn working copy repository url to the remote svn
                  repository (for example, to change url scheme from
                  `https://` to `svn+ssh://`)

-------------------------------------------------------------------------------
5.1. Mirroring (merging) from SVN to GIT
-------------------------------------------------------------------------------

To take changes from the git REMOTE repository, then these scripts must be
issued:

1. `<HubAbbrivatedName>~git~init` (required only if not inited yet)
2. `<HubAbbrivatedName>~git~pull`

To do a merge from svn REMOTE repository to git REMOTE repository (through
a LOCAL repository), then these scripts must be issued:

1. `<HubAbbrivatedName>~git~init` (required only if not inited yet)
2. `<HubAbbrivatedName>~git~push_svn_to_git`

-------------------------------------------------------------------------------
6. KNOWN ISSUES
-------------------------------------------------------------------------------
For the issues around python xonsh module see details in the
`README_EN.python_xonsh.known_issues.txt` file.

-------------------------------------------------------------------------------
7. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
