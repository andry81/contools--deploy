* README_EN.txt
* 2018.07.28
* deploy/projects/_root

1. DESCRIPTION
2. DIRECTORY DEPLOY STRUCTURE
3. INSTALLATION
4. USAGE
4.1. Mirroring (merging) from SVN to GIT
5. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
The SVN and GIT deploy scripts for respective project repositories.

Currently implemented merging or mirroring ONLY from svn into git.

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
The solution root deploy scripts format:
  `<HubAbbrivatedName>~<RepositoryOperation>.bat`, where:

  `HubAbbrivatedName` can be:
    `sf` - SourceForge
    `gh` - GitHub
    `bb` - BitBucket
    `gl` - GitLab

  `RepositoryOperation` can be:
    `git_init` - create and initialize local git working copy directory
    `svn_to_git_fetch` - fetch svn repostory into git working copy
    `git_pull_all` - pull remote git repository including `git svn fetch` and
        `git svn rebase` and pull all subtrees
    `git_reset_all` - reset local working copy
    `svn_to_git_sync_all` - same as `pull_all` plus push to remote repository
    `svn_checkout_all` - checkout svn repository into new svn working copy
        directory
    `svn_update_all` - update svn working copy directory

Projects deploy scripts format:
  `<HubAbbrivatedName>~<RepositoryName>.<RepositoryOperation>.bat`, where:

  `HubAbbrivatedName` - the same as for the root solution deploy scripts.
  `RepositoryName` - is a local reporesentation of the repository name allocated
      for the particular hub (can be different in each hub).
  `RepositoryOperation` - the same as for the root solution deploy scripts.

-------------------------------------------------------------------------------
4.1. Mirroring (merging) from SVN to GIT
-------------------------------------------------------------------------------
To do a fetch from the svn REMOTE repository to the git LOCAL repository, then
these scripts must be issued:

1. `git_init` (required only if not inited yet)
2. `svn_to_git_fetch`

To do a merge from the svn REMOTE repository to the git LOCAL repository, then
these scripts must be issued:

1. `git_init` (required only if not inited yet)
2. `git_pull_all`

To do a merge from svn REMOTE repository to git REMOTE repository (through
a LOCAL repository), then these scripts must be issued:

1. `git_init` (required only if not inited yet)
2. `svn_to_git_sync_all`

-------------------------------------------------------------------------------
5. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
