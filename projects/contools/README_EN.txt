* README_EN.txt
* 2019.02.25
* deploy/projects/contools

1. DESCRIPTION
2. DIRECTORY DEPLOY STRUCTURE
3. INSTALLATION
4. USAGE
4.1. Mirroring (merging) from SVN to GIT
5. AUTHOR EMAIL

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
  +-/__scm_solutions - the deploy scripts checkout directory
  |  |
  |  +-/all-in-one  - all-in-one solution configuration deploy scripts
  |     |
  |     +-/contools - the project deploy scripts represented a repository as a
  |                   subdirectory
  |
  +-/_contools      - the root of the project with source working copies

-------------------------------------------------------------------------------
3. INSTALLATION
-------------------------------------------------------------------------------
1. run the solution root `configure.bat`
2. run the `configure_private.bat` in all subdirectories if not done yet
3. edit the `WCROOT_OFFSET` variable in the `configure.user.bat` to
   change the default directory structure
4. edit the `GIT.USER`/`GIT.EMAIL`/`GIT2.USER`/`GIT2.EMAIL` in projects's
   `configure_private.user.bat` to mirror from svn to git under unique account
   (will be showed in a merge info after a merge).

-------------------------------------------------------------------------------
4. USAGE
-------------------------------------------------------------------------------
Any deploy script format:
  `<HubAbbrivatedName>~<ScmName>~<CommandOperation>.bat`, where:

  `HubAbbrivatedName` - abbrivated hub name.
  `ScmName`           - version source control name on a hub.
  `CommandOperation`  - command operation to request from scm.

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
    `svn_fetch` - fetch svn repostory into git working copy
    `pull_all`  - pull remote git repository including `git svn fetch` and
        `git svn rebase` and pull all subtrees
    `reset_all` - reset local working copy
    `svn_sync_all` - same as `pull_all` plus push to remote <ScmName>
        repository
  [ScmName=svn]
    `checkout_all` - checkout svn repository into new svn working copy
        directory
    `update_all` - update svn working copy directory

-------------------------------------------------------------------------------
4.1. Mirroring (merging) from SVN to GIT
-------------------------------------------------------------------------------
To do a fetch from the svn REMOTE repository to the git LOCAL repository, then
these scripts must be issued:

1. `git~init` (required only if not inited yet)
2. `git~svn_fetch`

To do a merge from the svn REMOTE repository to the git LOCAL repository, then
these scripts must be issued:

1. `git~init` (required only if not inited yet)
2. `git~pull_all`

To do a merge from svn REMOTE repository to git REMOTE repository (through
a LOCAL repository), then these scripts must be issued:

1. `git~init` (required only if not inited yet)
2. `git~svn_sync_all`

-------------------------------------------------------------------------------
5. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
