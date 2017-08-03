* README_EN.txt
* 2017.08.04
* deploy/projects/contools

1. DESCRIPTION
2. DIRECTORY DEPLOY STRUCTURE
3. INSTALLATION
4. USAGE
5. AUTHOR EMAIL

-------------------------------------------------------------------------------
1. DESCRIPTION
-------------------------------------------------------------------------------
The SVN and GIT deploy scripts for respective project repositories.

-------------------------------------------------------------------------------
2. DIRECTORY DEPLOY STRUCTURE
-------------------------------------------------------------------------------
The default directory structure is this:

<root>
  |
  +-- __scm_solutions   - the deploy scripts checkout directory
  |     |
  |     +-- all-in-one  - the solution root deploy scripts
  |           |
  |           +-- contools - the project deploy scripts
  |           |
  |           +-- nsisplus - the project deploy scripts
  |           |
  |           +-- svncmd   - the project deploy scripts
  |
  +-- _contools         - the root for WCs of the project
  |
  +-- _nsisplus         - the root for WCs of the project
  |
  +-- _svncmd           - the root for WCs of the project

-------------------------------------------------------------------------------
3. INSTALLATION
-------------------------------------------------------------------------------
1. run the solution root `configure.bat`
2. run the `configure.bat` in all project's directories
3. edit the `WCROOT_OFFSET` variable to change the default directory structure

-------------------------------------------------------------------------------
4. USAGE
-------------------------------------------------------------------------------
The solution root deploy scripts format:
  `<HubAbbrivatedName>~<RepositoryOperation>.bat`, where:

  `HubAbbrivatedName` can be:
    `sf` - SourceForge
    `gh` - GitHub
    `bb` - BitBucket

  `RepositoryOperation` can be:
    `git_init` - create and initialize local git working copy directory
    `git_fetch` - fetch svn repostory into working copy
    `git_pull_all` - pull remote repository including `git svn fetch` and
        `git svn rebase` and pull all subtrees
    `git_reset_all` - reset local working copy
    `svn_to_git_sync_all` - same as `pull_all` plus push to remote repository
    `svn_checkout_all` - checkout svn repository into new svn working copy
        directory
    `svn_update_all` - update svn working copy directory

Projects deploy scripts format:
  `<HubAbbrivatedName>~<RepositoryName>.<RepositoryOperation>.bat`, where:

  `HubAbbrivatedName` the same as for the root solution deploy scripts.
  `RepositoryName` is a repository name allocated in the hub.
  `RepositoryOperation` the same as for the root solution deploy scripts:

-------------------------------------------------------------------------------
5. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
