* README_EN.txt
* 2019.11.22
* deploy/projects/_root

1. DESCRIPTION
2. DIRECTORY DEPLOY STRUCTURE
3. PREREQUISITES
4. INSTALLATION
5. USAGE
5.1. Mirroring (merging) from SVN to GIT
6. SSH+SVN/PLINK SETUP
7. KNOWN ISSUES
7.1. svn+ssh issues
7.1.1. Message `svn: E170013: Unable to connect to a repository at URL 'svn+ssh://...'`
       `svn: E170012: Can't create tunnel`
7.1.2. Message `Can't create session: Unable to connect to a repository at URL 'svn+ssh://...': `
       `To better debug SSH connection problems, remove the -q option from ssh' in the [tunnels] section of your Subversion configuration file. `
       `at .../Git/mingw64/share/perl5/Git/SVN.pm line 310.'`
7.1.3. Message `Keyboard-interactive authentication prompts from server:`
       `svn: E170013: Unable to connect to a repository at URL 'svn+ssh://...'`
       `svn: E210002: To better debug SSH connection problems, remove the -q option from 'ssh' in the [tunnels] section of your Subversion configuration file.`
       `svn: E210002: Network connection closed unexpectedly`
7.2. Python execution issues
7.2.1. `OSError: [WinError 87] The parameter is incorrect` while try to run
       `python_tests`
7.2.2. `OSError: [WinError 6] The handle is invalid`
7.3. pytest execution issues
7.4. fcache execution issues
8. AUTHOR EMAIL

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

* python 3.7.3 or 3.7.5 (3.4+ or 3.5+)
  https://python.org
  - standard implementation to run python scripts
  - 3.7.4 has a bug in the `pytest` module execution, see `KNOWN ISSUES`
    section
  - 3.5+ is required for the direct import by a file path (with any extension)
    as noted in the documentation:
    https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly

3. Modules

* Python site modules:

**  xonsh/0.9.12
    https://github.com/xonsh/xonsh
    - to run python scripts and import python modules with `.xsh` file
      extension
**  plumbum 1.6.7
    https://plumbum.readthedocs.io/en/latest/
    - to run python scripts in a shell like environment
**  win_unicode_console
    - to enable unicode symbols support in the Windows console
**  pyyaml 5.1.1
    - to read yaml format files (.yaml, .yml)
**  conditional 1.3
    - to support conditional `with` statements
**  fcache 0.4.7
    - for local cache storage for python scripts
**  psutil 5.6.7
    - for processes list request
**  tzlocal 2.0.0
    - for local timezone request

Temporary dropped usage:

**  prompt-toolkit 2.0.9
    - optional dependency to the Xonsh on the Windows
**  cmdix 0.2.0
    https://github.com/jaraco/cmdix
    - extension to use Unix core utils within Python environment as plain
      executable or python function

4. Patches:

* Python site modules contains patches in the `python_patches` directory:

** fcache
   - to fix issues from the `fcache execution issues` section.

-------------------------------------------------------------------------------
4. INSTALLATION
-------------------------------------------------------------------------------
1. run the `configure.bat` script from the root directory or from a
   subdirectory you going to use.
2. run the `configure_private.bat` script from the root directory or from a
   subdirectory you going to use.
3. edit the `WCROOT_OFFSET` variable in the respective `config.yaml` file
   and change the default directory structure if is required to.
4. edit the `GIT.USER`/`GIT.EMAIL`/`GIT2.USER`/`GIT2.EMAIL` in respective
   `config.private.yaml` file to mirror from svn to git under unique account
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
6. SSH+SVN/PLINK SETUP
-------------------------------------------------------------------------------
Based on: https://stackoverflow.com/questions/11345868/how-to-use-git-svn-with-svnssh-url/58641860#58641860

The svn+ssh protocol must be setuped using both the private and the public ssh
key.

In case of in the Windows usage you have to setup the ssh key before run the
svn client using these general steps related to the native Windows `svn.exe`
(should not be a ported one, for example, like the `msys` or `cygwin` tools
which is not fully native):

1. Install the `putty` client.
2. Generate the key using the `puttygen.exe` utility and the correct type of
   the key dependent on the svn hub server (Ed25519, RSA, DSA, etc).
3. Install the been generated public variant of the key into the svn hub server
   by reading the steps from the docs to the server.
4. Ensure that the `SVN_SSH` environment variable in the generated
   `config.env.yaml` file is pointing a correct path to the `plink.exe` and
   uses valid arguments. This would avoid hangs in scripts because of
   interactive login/password request and would avoid usage svn repository
   urls with the user name inside.
5. Ensure that all svn working copies and the `externals` properties in them
   contains valid svn repository urls with the `svn+ssh://` prefix. If not then
   use the `*~svn~relocate` scrtip(s) to switch onto it. Then fix all the rest
   urls in the `externals` properties, for example, just by remove the url
   scheme prefix and leave the `//` prefix instead.
6. Run the `pageant.exe` in the background with the previously generated
   private key (add it).
7. Test the connection to the svn hub server through the `putty.exe` client.
   The client should not ask for the password if the `pageant.exe` is up and
   running with has been correctly setuped private key. The client should not
   ask for the user name either if the `SVN_SSH` environment variable is
   declared with the user name.

The `git` client basically is a part of ported `msys` or `cygwin` tools, which
means they behaves a kind of differently.

The one of the issues with the message `Can't create session: Unable to connect
to a repository at URL 'svn+ssh://...': Error in child process: exec of ''
failed: No such file or directory at .../Git/mingw64/share/perl5/Git/SVN.pm
line 310.` is the issue with the `SVN_SSH` environment variable. The variable
should be defined with an utility from the same tools just like the `git`
itself. The attempt to use it with the standalone `plink.exe` from the `putty`
application would end with that message.

So, additionally to the steps for the `svn.exe` application you should apply,
for example, these steps:

1. Drop the usage of the `SVN_SSH` environment variable and remove it.
2. Run the `ssh-pageant` from the `msys` or `cygwin` tools (the `putty`'s
   `pageant` must be already run with the valid private key). You can read
   about it, for example, from here: https://github.com/cuviper/ssh-pageant
   ("ssh-pageant is a tiny tool for Windows that allows you to use SSH keys
   from PuTTY's Pageant in Cygwin and MSYS shell environments.")
3. Create the environment variable returned by the `ssh-pageant` from the
   stdout, for example: `SSH_AUTH_SOCK=/tmp/ssh-hNnaPz/agent.2024`.
4. Use urls in the `git svn ...` commands together with the user name as stated
   in the documentation
   (https://git-scm.com/docs/git-svn#Documentation/git-svn.txt---usernameltusergt ):
   `svn+ssh://<USERNAME>@svn.<url>.com/repo`
   ("For transports that SVN handles authentication for (http, https, and plain
   svn), specify the username. For other transports (e.g. svn+ssh://), you
   **must include the username in the URL**,
   e.g. svn+ssh://foo@svn.bar.com/project")

These instructions should help to use `git svn` commands together with the
`svn` commands.

NOTE:
  The scripts does all above automatically. All you have to do is to ensure
  that you are using valid paths and keys in the respective configuration
  files.

-------------------------------------------------------------------------------
7. KNOWN ISSUES
-------------------------------------------------------------------------------
For the issues around python xonsh module see details in the
`README_EN.python_xonsh.known_issues.txt` file.

-------------------------------------------------------------------------------
7.1. svn+ssh issues
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
7.1.1. Message `svn: E170013: Unable to connect to a repository at URL 'svn+ssh://...'`
       `svn: E170012: Can't create tunnel`
-------------------------------------------------------------------------------

Issue #1:

The `svn ...` command was run w/o properly configured putty plink utility or
w/o the `SVN_SSH` environment variable with the user name parameter.

Solution:

Carefully read the `SSH+SVN/PLINK SETUP` section to fix most of the cases.

Issue #2

The `SVN_SSH` environment variable have has the backslash characters - `\`.

Solution:

Replace all the backslash characters by forward slash character - `/` or by
double baskslash character - `\\`.

-------------------------------------------------------------------------------
7.1.2. Message `Can't create session: Unable to connect to a repository at URL 'svn+ssh://...': `
       `To better debug SSH connection problems, remove the -q option from ssh' in the [tunnels] section of your Subversion configuration file. `
       `at .../Git/mingw64/share/perl5/Git/SVN.pm line 310.'`
-------------------------------------------------------------------------------

Issue:

The `git svn ...` command should not be called with the `SVN_SSH` variable
declared for the `svn ...` command.

Solution:

Read docs about the `ssh-pageant` usage from the msys tools to fix that.

See details: https://stackoverflow.com/questions/31443842/svn-hangs-on-checkout-in-windows/58613014#58613014

NOTE:
  The scripts does automatic maintain of the `ssh-pageant` utility startup.
  All you have to do is to ensure that you are using valid paths and keys in
  the respective configuration files.

-------------------------------------------------------------------------------
7.2. Python execution issues
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
7.2.1. `OSError: [WinError 87] The parameter is incorrect` while try to run
       `python_tests`
-------------------------------------------------------------------------------

Issue:

The `python_tests` scripts fails with the titled message.

Reason:

Python version 3.7.4 is broken on Windows 7:
https://bugs.python.org/issue37549 :
`os.dup() fails for standard streams on Windows 7`

Solution:

Reinstall a different python version.

-------------------------------------------------------------------------------
7.2.2. `OSError: [WinError 6] The handle is invalid`
-------------------------------------------------------------------------------

Issue:

The python interpreter (3.7, 3.8, 3.9) sometimes throws this message at exit,
see details here: https://bugs.python.org/issue37380

Solution:

Reinstall a different python version.

-------------------------------------------------------------------------------
7.1.3. Message `Keyboard-interactive authentication prompts from server:`
       `svn: E170013: Unable to connect to a repository at URL 'svn+ssh://...'`
       `svn: E210002: To better debug SSH connection problems, remove the -q option from 'ssh' in the [tunnels] section of your Subversion configuration file.`
       `svn: E210002: Network connection closed unexpectedly`
-------------------------------------------------------------------------------

Related command: `git svn ...`

Issue #1:

Network is disabled:

Issue #2:

The `pageant` application is not running or the provate SSH key is not added.

Issue #3:

The `ssh-pageant` utility is not running or the `git svn ...` command does run
without the `SSH_AUTH_SOCK` environment variable properly registered.

Solution:

Read the deatils in the `SSH+SVN/PLINK SETUP` section.

-------------------------------------------------------------------------------
7.3. pytest execution issues
-------------------------------------------------------------------------------
* `xonsh incorrectly reorders the test for the pytest` :
  https://github.com/xonsh/xonsh/issues/3380
* `a test silent ignore` :
  https://github.com/pytest-dev/pytest/issues/6113
* `can not order tests by a test directory path` :
  https://github.com/pytest-dev/pytest/issues/6114


-------------------------------------------------------------------------------
7.4. fcache execution issues
-------------------------------------------------------------------------------
* `fcache is not multiprocess aware on Windows` :
  https://github.com/tsroten/fcache/issues/26
* ``_read_from_file` returns `None` instead of (re)raise an exception` :
  https://github.com/tsroten/fcache/issues/27
* `OSError: [WinError 17] The system cannot move the file to a different disk drive.` :
  https://github.com/tsroten/fcache/issues/28

-------------------------------------------------------------------------------
8. AUTHOR EMAIL
-------------------------------------------------------------------------------
Andrey Dibrov (andry at inbox dot ru)
