# python module for commands with extension modules usage: tacklelib, plumbum

import os, sys, io, csv, shlex, copy
from plumbum import local

tkl_source_module(SOURCE_DIR, 'cmdoplib.std.xsh')
tkl_source_module(SOURCE_DIR, 'cmdoplib.yaml.xsh')
tkl_source_module(SOURCE_DIR, 'cmdoplib.csvgit.xsh')
tkl_source_module(SOURCE_DIR, 'cmdoplib.url.xsh')
tkl_source_module(SOURCE_DIR, 'cmdoplib.svn.xsh')

tkl_import_module(TACKLELIB_ROOT, 'tacklelib.utils.py', 'tkl')

def get_git_svn_path_prefix_regex(path):
  # convert all back slashes at first
  git_svn_path_prefix_regex = path.replace('\\', '/')

  # escape all regex characters
  for c in '^$.+[](){}':
    git_svn_path_prefix_regex = git_svn_path_prefix_regex.replace(c, '\\' + c)

  return '^' + git_svn_path_prefix_regex + '(?:/|$)'

def validate_git_refspec(git_local_branch, git_remote_branch):
  if git_local_branch == '.': git_local_branch = ''
  if git_remote_branch == '.': git_remote_branch = ''

  if git_local_branch != '' and git_remote_branch == '':
    git_remote_branch = git_local_branch
  elif git_local_branch == '' and git_remote_branch != '':
    git_local_branch = git_remote_branch
  elif git_local_branch == '' and git_remote_branch == '':
    raise Exception("at least one of git_local_branch and git_remote_branch parameters must be a valid branch name")

  return (git_local_branch, git_remote_branch)

def get_git_pull_refspec_token(git_local_branch, git_remote_branch):
  git_local_branch, git_remote_branch == validate_git_refspec(git_local_branch, git_remote_branch)

  if git_local_branch == git_remote_branch:
    refspec_token = git_local_branch
  else:
    refspec_token = git_remote_branch + ':' + git_local_branch

  return refspec_token

def get_git_local_ref_token(git_local_branch, git_remote_branch):
  return 'refs/heads/' + validate_git_refspec(git_local_branch, git_remote_branch)[0]

def get_git_remote_ref_token(remote_name, git_local_branch, git_remote_branch):
  git_remote_branch = validate_git_refspec(git_local_branch, git_remote_branch)[1]
  return ('refs/remotes/' + remote_name + '/' + git_remote_branch, 'refs/heads/' + git_remote_branch)

def get_git_refspec_token(git_local_branch, git_remote_branch):
  git_local_branch, git_remote_branch = validate_git_refspec(git_local_branch, git_remote_branch)

  if git_local_branch == git_remote_branch:
    refspec_token = git_local_branch
  else:
    refspec_token = git_remote_branch + ':refs/heads/' + git_local_branch

  return refspec_token

def register_git_remotes(git_repos_reader, scm_name, remote_name, with_root):
  git_repos_reader.reset()

  if with_root:
    for root_row in git_repos_reader:
      if root_row['scm_token'] == scm_name and root_row['remote_name'] == remote_name:
        root_remote_name = root_row['remote_name']
        root_git_reporoot = yaml_expand_value(root_row['git_reporoot'])

        ret = call_no_except('git', ['remote', 'get-url', root_remote_name], stdout = tkl.devnull(), stderr = tkl.devnull())
        if not ret[0]:
          call('git', ['remote', 'set-url', root_remote_name, root_git_reporoot])
        else:
          git_remote_add_cmdline = root_row['git_remote_add_cmdline']
          if git_remote_add_cmdline == '.':
            git_remote_add_cmdline = ''
          call('git', ['remote', 'add', root_remote_name, root_git_reporoot] + shlex.split(yaml_expand_value(git_remote_add_cmdline)))
        break

    git_repos_reader.reset()

  for subtree_row in git_repos_reader:
    if subtree_row['scm_token'] == scm_name and subtree_row['parent_remote_name'] == remote_name:
      subtree_remote_name = subtree_row['remote_name']
      subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])

      ret = call_no_except('git', ['remote', 'get-url', subtree_remote_name], stdout = tkl.devnull(), stderr = tkl.devnull())
      if not ret[0]:
        call('git', ['remote', 'set-url', subtree_remote_name, subtree_git_reporoot])
      else:
        git_remote_add_cmdline = subtree_row['git_remote_add_cmdline']
        if git_remote_add_cmdline == '.':
          git_remote_add_cmdline = ''
        call('git', ['remote', 'add', subtree_remote_name, subtree_git_reporoot] + shlex.split(yaml_expand_value(git_remote_add_cmdline)))

# ex: `git checkout -b <git_local_branch> refs/remotes/origin/<git_remote_branch>`
#
def get_git_checkout_branch_args_list(remote_name, git_local_branch, git_remote_branch):
  git_local_branch, git_remote_branch == validate_git_refspec(git_local_branch, git_remote_branch)

  return ['-b', git_local_branch, get_git_remote_ref_token(remote_name, git_local_branch, git_remote_branch)[0]]

"""
def get_git_fetch_first_commit_hash(remote_name, git_local_branch, git_remote_branch):
  first_commit_hash = None

  ret = call_no_except('git', ['rev-list', '--reverse', '--max-parents=0', 'FETCH_HEAD', get_git_remote_ref_token(remote_name, git_local_branch, git_remote_branch)[0]], stdout = None, stderr = None)
  for row in io.StringIO(ret[1]):
    first_commit_hash = row
    break

  if not first_commit_hash is None:
    print(first_commit_hash)
  if len(ret[2]) > 0:
    print(ret[2].rstrip())

  return first_commit_hash.strip()
"""

# Returns only the first git commit parameters or nothing.
#
def get_git_first_commit_from_git_log(str):
  svn_rev = None
  commit_hash = None
  commit_timestamp = None

  lines = io.StringIO(str)
  for line in lines:
    value_list = [value.strip() for value in line.split(":", 1)]
    key = value_list[0]
    if key == 'commit':
      if not commit_hash is None:
        # return the previous one
        return (svn_rev, commit_hash, commit_timestamp)
      commit_hash = value_list[1]
    elif key == 'timestamp':
      commit_timestamp = value_list[1]
    elif key == 'git-svn-id':
      git_svn_url = value_list[1].split(' ', 1)[0]
      svn_rev_index = git_svn_url.rfind('@')
      if svn_rev_index > 0:
        svn_path = git_svn_url[:svn_rev_index]
        svn_rev = git_svn_url[svn_rev_index + 1:]

  return (svn_rev, commit_hash, commit_timestamp)

# Returns the git commit parameters where was found the svn revision under the requested remote svn url, otherwise would return the last commit parameters.
#
def get_git_commit_from_git_log(str, svn_reporoot, svn_path_prefix):
  if svn_path_prefix == '.': svn_path_prefix = ''

  svn_remote_path = svn_reporoot + ('/' + svn_path_prefix if svn_path_prefix != '' else '')

  num_commits = 0

  lines = io.StringIO(str)
  for line in lines:
    print(line.strip())
    value_list = [value.strip() for value in line.split(":", 1)]
    key = value_list[0]
    if key == 'commit':
      commit_hash = value_list[1]
      num_commits += 1
    elif key == 'timestamp':
      commit_timestamp = value_list[1]
    elif key == 'git-svn-id':
      git_svn_url = value_list[1].split(' ', 1)[0]
      svn_rev_index = git_svn_url.rfind('@')
      if svn_rev_index > 0:
        svn_path = git_svn_url[:svn_rev_index]
        svn_rev = git_svn_url[svn_rev_index + 1:]
        if svn_path == svn_remote_path:
          return (svn_rev, commit_hash, commit_timestamp, num_commits)

  return (None, commit_hash, commit_timestamp, num_commits)

def get_last_git_pushed_commit_hash(git_reporoot, git_remote_local_ref_token):
  git_last_pushed_commit_hash = None

  ret = call_no_except('git', ['ls-remote', git_reporoot], stdout = None, stderr = None)
  if len(ret[1]) > 0:
    print(ret[1].rstrip())
  if len(ret[2]) > 0:
    print(ret[2].rstrip())

  with GitLsRemoteListReader(ret[1]) as git_ls_remote_reader:
    for row in git_ls_remote_reader:
      if row['ref'] == git_remote_local_ref_token:
        git_last_pushed_commit_hash = row['hash']
        break

  return git_last_pushed_commit_hash

def get_last_git_fetched_commit_hash(git_remote_ref_token, verify_ref = True):
  git_last_fetched_commit_hash = None

  ret = call('git', ['show-ref'] + (['--verify'] if verify_ref else []) + [git_remote_ref_token], stdout = None, stderr = None)

  with GitShowRefListReader(ret[1]) as git_show_ref_reader:
    for row in git_show_ref_reader:
      if row['ref'] == git_remote_ref_token:
        git_last_fetched_commit_hash = row['hash'].rstrip()
        break

  if not git_last_fetched_commit_hash is None:
    print(git_last_fetched_commit_hash)
  if len(ret[2]):
    print(ret[2].rstrip())

  return git_last_fetched_commit_hash

def get_git_head_commit_hash(git_local_ref_token, verify_ref = True):
  git_head_commit_hash = None

  ret = call_no_except('git', ['show-ref'] + (['--verify'] if verify_ref else []) + [git_local_ref_token], stdout = None, stderr = None)

  with GitShowRefListReader(ret[1]) as git_show_ref_reader:
    for row in git_show_ref_reader:
      if row['ref'] == git_local_ref_token:
        git_head_commit_hash = row['hash'].rstrip()
        break

  if not git_head_commit_hash is None:
    print(git_head_commit_hash)
  if len(ret[2]):
    print(ret[2].rstrip())

  return git_head_commit_hash

def revert_if_git_head_refs_is_not_last_pushed(git_reporoot, git_local_ref_token, git_remote_ref_token, git_remote_local_ref_token,
  verify_head_ref = True, reset_hard = False, revert_after_fetch = False):
  # get last pushed commit hash

  git_last_pushed_commit_hash = get_last_git_pushed_commit_hash(git_reporoot, git_remote_local_ref_token)

  # compare the last pushed commit hash with the last fetched commit hash and if different, then revert local changes

  # get last fetched commit hash

  if not git_last_pushed_commit_hash is None: # optimization
    git_last_fetched_commit_hash = get_last_git_fetched_commit_hash(git_remote_ref_token)

  if (not git_last_pushed_commit_hash is None and not git_last_fetched_commit_hash is None and git_last_pushed_commit_hash != git_last_fetched_commit_hash) or \
     (git_last_pushed_commit_hash is None and not git_last_fetched_commit_hash is None) or \
     (not git_last_pushed_commit_hash is None and git_last_fetched_commit_hash is None):
     call('git', ['reset'] + (['--hard'] if reset_hard else []) + [git_remote_ref_token])

  # additionally, compare the last pushed commit hash with the head commit hash and if different then revert changes

  # get head commit hash

  git_head_commit_hash = get_git_head_commit_hash(git_local_ref_token, verify_ref = verify_head_ref)

  if not git_last_pushed_commit_hash is None and not git_head_commit_hash is None:
    is_head_commit_not_last_pushed = True if git_last_pushed_commit_hash != git_head_commit_hash else False
    is_head_commit_last_pushed = not is_head_commit_not_last_pushed
  else:
    is_head_commit_not_last_pushed = False
    is_head_commit_last_pushed = False

  if is_head_commit_not_last_pushed or (git_last_pushed_commit_hash is None and not git_head_commit_hash is None):
    # clean the stage using `git reset ...`  from the not yet updated HEAD reference
    call('git', ['reset'] + (['--hard'] if reset_hard else []) + [git_local_ref_token])

    if is_head_commit_not_last_pushed:
      # force reassign the HEAD to the FETCH_HEAD
      call('git', ['update-ref', git_local_ref_token, git_last_pushed_commit_hash])

  if (is_head_commit_last_pushed or git_head_commit_hash is None) and revert_after_fetch:
    # don't execute the whole revert if a last fetch didn't change the head or head does not exist
    return

  # Drop all other references which might be created by a previous bad `git svn fetch ...` call except of the main local and the main remote references.
  # Description:
  #   The `git svn fetch ...` have has an ability to create a dangled HEAD reference which is assited with one more remote reference additionally
  #   to the already existed, so we must not just reassign the HEAD reference back to the FETCH_HEAD, but remove an added remote reference too.
  #   To do so we remove all the references returned by the `git show-ref` command except the main local and the main remote reference.
  #
  ret = call('git', ['show-ref'], stdout = None, stderr = None)
  if len(ret[1]) > 0:
    print(ret[1].rstrip())
  if len(ret[2]) > 0:
    print(ret[2].rstrip())

  is_ref_list_updated = False

  with GitShowRefListReader(ret[1]) as git_show_ref_reader:
    for row in git_show_ref_reader:
      ref = row['ref']
      if ref != git_local_ref_token and ref != git_remote_ref_token:
        # delete the reference
        call('git', ['update-ref', '-d', ref])
        is_ref_list_updated = True

  # call to the `git reset ...` if not done yet and HEAD exists, otherwise call again after the HEAD reference update
  if not git_head_commit_hash is None:
    call('git', ['reset'] + (['--hard'] if reset_hard else []) + [git_local_ref_token] )

def get_git_svn_subtree_ignore_paths_regex(git_repos_reader, scm_name, remote_name, svn_reporoot):
  parent_svn_reporoot_urlpath = tkl.ParseResult('', *tkl.urlparse(svn_reporoot)[1:]).geturl()

  subtree_git_svn_init_ignore_paths_regex = ''

  git_repos_reader.reset()

  for subtree_row in git_repos_reader:
    if subtree_row['scm_token'] == scm_name and subtree_row['parent_remote_name'] == remote_name:
      svn_reporoot_urlpath = tkl.ParseResult('', *tkl.urlparse(subtree_row['svn_reporoot'])[1:]).geturl()

      if svn_reporoot_urlpath == parent_svn_reporoot_urlpath:
        subtree_svn_path_prefix = subtree_row['svn_path_prefix']

        if subtree_svn_path_prefix == '.':
          raise Exception('not root branch type must have not empty svn path prefix')

        subtree_svn_path_prefix = yaml_expand_value(subtree_svn_path_prefix)

        subtree_git_svn_path_prefix_regex = get_git_svn_path_prefix_regex(subtree_svn_path_prefix)

        subtree_git_svn_init_ignore_paths_regex += ('|' if len(subtree_git_svn_init_ignore_paths_regex) > 0 else '') + subtree_git_svn_path_prefix_regex

  return subtree_git_svn_init_ignore_paths_regex

def git_svn_fetch_to_last_git_pushed_svn_rev(remote_name, git_local_branch, git_remote_branch, svn_reporoot, svn_path_prefix, git_svn_fetch_cmdline_list = []):
  # search for the last pushed svn revision

  git_last_svn_rev, git_commit_hash, git_commit_timestamp, git_from_commit_timestamp, num_git_commits = \
    get_last_git_svn_rev_by_git_log(remote_name, git_local_branch, git_remote_branch, svn_reporoot, svn_path_prefix)

  # special `git svn fetch` call to build initial git-svn revisions map from the svn repository

  try:
    if not git_last_svn_rev is None:
      ret = call('git', ['svn', 'fetch', '-r' + str(git_last_svn_rev)] + git_svn_fetch_cmdline_list, stdout = None, stderr = None)
    else:
      ret = call('git', ['svn', 'fetch', '-r0'] + git_svn_fetch_cmdline_list, stdout = None, stderr = None)

  except ProcessExecutionError as proc_err:
    if len(proc_err.stdout) > 0:
      print(proc_err.stdout)
    if len(proc_err.stderr) > 0:
      print(proc_err.stderr)
    raise

  else:
    # cut out the middle of the stdout
    stdout_lines = ret[1]
    stderr_lines = ret[2]
    num_new_lines = stdout_lines.count('\n')
    if num_new_lines > 7:
      line_index = 0
      for line in io.StringIO(stdout_lines):
        if line_index < 3 or line_index >= num_new_lines - 3: # excluding the last line return
          print(line, end='')
        elif line_index == 3:
          print('...')
        line_index += 1
    elif len(stdout_lines) > 0:
      print(stdout_lines)
    if len(stderr_lines) > 0:
      print(stderr_lines)

  return git_last_svn_rev

# returns as tuple:
#   git_last_svn_rev          - last pushed svn revision if has any
#   git_commit_hash           - git commit associated with the last pushed svn revision if has any, otherwise the last git commit
#   git_commit_timestamp      - git commit timestamp of the `git_commit_hash` commit
#   git_from_commit_timestamp - from there the last search is occured, if None - from FETCH_HEAD, if not None, then has used as: `git log ... FETCH_HEAD ... --until <git_from_commit_timestamp>`
#   num_git_commits           - number of looked up commits from the either FETCH_HEAD or from the `git_from_commit_timestamp` argument in the last `git log` command
#
def get_last_git_svn_rev_by_git_log(remote_name, git_local_branch, git_remote_branch, svn_reporoot, svn_path_prefix, git_log_start_depth = 16):
  # get last pushed svn revision from the `git log` using last commit hash from the git remote repo
  git_last_svn_rev = None
  git_commit_hash = None
  git_commit_timestamp = None
  num_git_commits = None

  git_log_prev_depth = -1
  git_log_next_depth = git_log_start_depth  # initial `git log` commits depth
  git_log_prev_num_commits = -1
  git_log_next_num_commits = 0

  # use `--until` argument to shift commits window
  git_from_commit_timestamp = None

  # 1. iterate to increase the `git log` depth (`--max-count`) in case of equal the first and the last commit timestamps
  # 2. iterate to shift the `git log` window using `--until` parameter
  while True:
    ret = call('git', ['log', '--max-count=' + str(git_log_next_depth), '--format=commit: %H%ntimestamp: %ct%n%b', 'FETCH_HEAD',
      get_git_remote_ref_token(remote_name, git_local_branch, git_remote_branch)[0]] +
      (['--until', str(git_from_commit_timestamp)] if not git_from_commit_timestamp is None else []),
      stdout = None, stderr = None)

    git_last_svn_rev, git_commit_hash, git_commit_timestamp, num_git_commits = get_git_commit_from_git_log(ret[1], svn_reporoot, svn_path_prefix)

    # quit if the svn revision is found
    if not git_last_svn_rev is None:
      break

    git_log_prev_num_commits = git_log_next_num_commits
    git_log_next_num_commits = num_git_commits

    # the `git log` depth can not be any longer increased (the `git log` list end)
    if git_log_next_depth > git_log_prev_depth and git_log_prev_num_commits >= git_log_next_num_commits:
      break

    git_log_prev_depth = git_log_next_depth

    git_first_commit_svn_rev, git_first_commit_hash, git_first_commit_timestamp = get_git_first_commit_from_git_log(ret[1])

    # increase the depth of the `git log` if the last commit timestamp is not less than the first commit timestamp
    if git_commit_timestamp >= git_first_commit_timestamp:
      git_log_next_depth *= 2
      if git_from_commit_timestamp is None:
        git_from_commit_timestamp = git_first_commit_timestamp
    else:
      # update conditions
      git_log_prev_num_commits = -1
      git_from_commit_timestamp = git_commit_timestamp

  return (git_last_svn_rev, git_commit_hash, git_commit_timestamp, git_from_commit_timestamp, num_git_commits)


# CAUTION:
#   * By default the function processes the root repository together with the subtree repositories.
#     If you want to skip the subtree repositories, then do use the `root_only` argument.
#     If you want to process subtree repositories by a custom (not builtin) path,
#     then do use the `init_subtrees_root` argument as a root path to the subtree directories.
#
def git_init(configure_dir, scm_name, init_subtrees_root = None, root_only = False):
  print(">git_init: {0}".format(configure_dir))

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 32

  if not init_subtrees_root is None and not os.path.isdir(init_subtrees_root):
    print_err("{0}: error: init_subtrees_root directory does not exist: `{1}`.".format(sys.argv[0], init_subtrees_root))
    return 33

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  git_user = getvar(scm_name + '.USER')
  git_email = getvar(scm_name + '.EMAIL')

  print(' -> pushd: {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  with local.cwd(wcroot_path):
    if not os.path.exists(wcroot_path + '/.git'):
      call('git', ['init', wcroot_path])

    with GitReposListReader(configure_dir + '/git_repos.lst') as git_repos_reader:
      # generate `--ignore_paths` for subtrees

      root_remote_name = None
      remote_name_list = []

      for row in git_repos_reader:
        if row['scm_token'] == scm_name and row['branch_type'] == 'root':
          root_remote_name = row['remote_name']
          remote_name_list.append(root_remote_name)

          root_svn_reporoot = yaml_expand_value(row['svn_reporoot'])
          root_svn_path_prefix = yaml_expand_value(row['svn_path_prefix'])
          root_git_svn_init_cmdline = row['git_svn_init_cmdline']
          if root_git_svn_init_cmdline == '.':
            root_git_svn_init_cmdline = ''
          else:
            root_git_svn_init_cmdline = yaml_expand_value(root_git_svn_init_cmdline)
          break

      if root_remote_name is None:
        raise Exception('the root record is not found in the git repositories list')

      if len(root_git_svn_init_cmdline) > 0:
        root_git_svn_init_cmdline_list = shlex.split(root_git_svn_init_cmdline)
      else:
        root_git_svn_init_cmdline_list = []

      # Always use the trunk, even if it is in a subdirectory, to later be able to use the SVN url always as a root url without relative suffix and
      # let the git to generate a commit hash based on a complete path from the SVN root.
      if '--stdlayout' not in root_git_svn_init_cmdline_list and '--trunk' not in root_git_svn_init_cmdline_list:
        root_git_svn_init_cmdline_list.append('--trunk=' + root_svn_path_prefix)
      root_svn_url = root_svn_reporoot

      git_svn_init_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(git_repos_reader, scm_name, root_remote_name, root_svn_reporoot)
      if len(git_svn_init_ignore_paths_regex) > 0:
        root_git_svn_init_cmdline_list.append('--ignore-paths=' + git_svn_init_ignore_paths_regex)

      # (re)init root git svn
      is_git_root_wcroot_exists = os.path.exists(wcroot_path + '/.git/svn')
      if is_git_root_wcroot_exists:
        ret = call_no_except('git', ['config', 'svn-remote.svn.url'], stdout = None, stderr = None)

        if len(ret[1]) > 0:
          print(ret[1].rstrip())
        if len(ret[2]) > 0:
          print(ret[2].rstrip())

      # Reinit if:
      #   1. git/svn wcroot is not found or
      #   2. svn remote url is not registered or
      #   3. svn remote url is different
      #
      if is_git_root_wcroot_exists and not ret[0]:
        root_svn_url_reg = ret[1].rstrip()
      if not is_git_root_wcroot_exists or ret[0] or root_svn_url_reg != root_svn_url:
        # removing the git svn config section to avoid it's records duplication on reinit
        call_no_except('git', ['config', '--remove-section', 'svn-remote.svn'])
        call('git', ['svn', 'init', root_svn_url] + root_git_svn_init_cmdline_list)

      call('git', ['config', 'user.name', git_user])
      call('git', ['config', 'user.email', git_email])

      # register git remotes

      register_git_remotes(git_repos_reader, scm_name, root_remote_name, True)

      print('---')

      if root_only:
        return

      is_builtin_subtrees_root = False
      if init_subtrees_root is None:
        init_subtrees_root = wcroot_path + '/.git/svn2git/gitwc'
        is_builtin_subtrees_root = True

      # Initialize non root git repositories as stanalone working copies inside the `init_subtrees_root` directory,
      # use the combination of the `remote_name` and the `parent_git_path_prefix` as a prefix to a working copy directory.

      git_repos_reader.reset()

      for subtree_row in git_repos_reader:
        if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
          subtree_parent_git_path_prefix = subtree_row['parent_git_path_prefix']

          if subtree_parent_git_path_prefix == '.':
            raise Exception('not root branch type must have not empty git parent path prefix')

          subtree_remote_name = subtree_row['remote_name']
          if subtree_remote_name in remote_name_list:
            raise Exception('remote_name must be unique in the repositories list for the same scm_token')

          remote_name_list.append(subtree_remote_name)

          subtree_svn_reporoot = yaml_expand_value(subtree_row['svn_reporoot'])
          # expand if contains a variable substitution
          subtree_parent_git_path_prefix = yaml_expand_value(subtree_parent_git_path_prefix)
          subtree_svn_path_prefix = yaml_expand_value(subtree_row['svn_path_prefix'])

          subtree_git_svn_init_cmdline = subtree_row['git_svn_init_cmdline']
          if subtree_git_svn_init_cmdline == '.':
            subtree_git_svn_init_cmdline = ''
          else:
            subtree_git_svn_init_cmdline = yaml_expand_value(subtree_git_svn_init_cmdline)

          subtree_git_wcroot = os.path.abspath(os.path.join(init_subtrees_root, subtree_remote_name + "'" + subtree_parent_git_path_prefix.replace('/', '--'))).replace('\\', '/')

          if is_builtin_subtrees_root:
            if not os.path.exists(init_subtrees_root):
              print('>mkdir: -p ' + init_subtrees_root)
              try:
                os.makedirs(init_subtrees_root)
              except FileExistsError:
                pass

          if not os.path.exists(subtree_git_wcroot):
            print('>mkdir: ' + subtree_git_wcroot)
            try:
              os.mkdir(subtree_git_wcroot)
            except FileExistsError:
              pass

          print(' ->> pushd: {0}...'.format(subtree_git_wcroot))

          with local.cwd(subtree_git_wcroot):
            if not os.path.exists(subtree_git_wcroot + '/.git'):
              call('git', ['init', subtree_git_wcroot])

            if len(subtree_git_svn_init_cmdline) > 0:
              subtree_git_svn_init_cmdline_list = shlex.split(subtree_git_svn_init_cmdline)
            else:
              subtree_git_svn_init_cmdline_list = []

            # Always use the trunk, even if it is in a subdirectory, to later be able to use the SVN url always as a root url without relative suffix and
            # let the git to generate a commit hash based on a complete path from the SVN root.
            if '--stdlayout' not in subtree_git_svn_init_cmdline_list and '--trunk' not in subtree_git_svn_init_cmdline_list:
              subtree_git_svn_init_cmdline_list.append('--trunk=' + subtree_svn_path_prefix)
            subtree_svn_url = subtree_svn_reporoot

            with GitReposListReader(configure_dir + '/git_repos.lst') as subtree_git_repos_reader:
              # generate `--ignore_paths` for subtrees

              subtree_git_svn_init_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(subtree_git_repos_reader, scm_name, subtree_remote_name, subtree_svn_reporoot)
              if len(subtree_git_svn_init_ignore_paths_regex) > 0:
                subtree_git_svn_init_cmdline_list.append('--ignore-paths=' + subtree_git_svn_init_ignore_paths_regex)

              # (re)init subtree git svn
              is_git_subtree_wcroot_exists = os.path.exists(subtree_git_wcroot + '/.git/svn')
              if is_git_subtree_wcroot_exists:
                ret = call_no_except('git', ['config', 'svn-remote.svn.url'], stdout = None, stderr = None)

                if len(ret[1]) > 0:
                  print(ret[1].rstrip())
                if len(ret[2]) > 0:
                  print(ret[2].rstrip())

              # Reinit if:
              #   1. git/svn wcroot is not found or
              #   2. svn remote url is not registered or
              #   3. svn remote url is different
              #
              if is_git_subtree_wcroot_exists and not ret[0]:
                subtree_svn_url_reg = ret[1].rstrip()
              if not is_git_subtree_wcroot_exists or ret[0] or subtree_svn_url_reg != subtree_svn_url:
                # removing the git svn config section to avoid it's records duplication on reinit
                call_no_except('git', ['config', '--remove-section', 'svn-remote.svn'])
                call('git', ['svn', 'init', subtree_svn_url] + subtree_git_svn_init_cmdline_list)

              call('git', ['config', 'user.name', git_user])
              call('git', ['config', 'user.email', git_email])

              # register git remotes

              register_git_remotes(subtree_git_repos_reader, scm_name, subtree_remote_name, True)

          print('---')

# CAUTION:
#   * By default the function processes the root repository together with the subtree repositories.
#     If you want to skip the subtree repositories, then do use the `root_only` argument.
#     If you want to process subtree repositories by a custom (not builtin) path,
#     then do use the `fetch_subtrees_root` argument as a root path to the subtree directories.
#
def git_fetch(configure_dir, scm_name, fetch_subtrees_root = None, root_only = False, reset_hard = False):
  print(">git_fetch: {0}".format(configure_dir))

  if not fetch_subtrees_root is None:
    print(' * fetch_subtrees_root: `' + fetch_subtrees_root + '`')

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 32

  if not fetch_subtrees_root is None and not os.path.isdir(fetch_subtrees_root):
    print_err("{0}: error: fetch_subtrees_root directory does not exist: `{1}`.".format(sys.argv[0], fetch_subtrees_root))
    return 33

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  git_user = getvar(scm_name + '.USER')
  git_email = getvar(scm_name + '.EMAIL')

  print(' -> pushd: {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  with local.cwd(wcroot_path), GitReposListReader(configure_dir + '/git_repos.lst') as git_repos_reader:
    has_root = False

    remote_name_list = []

    for row in git_repos_reader:
      if row['scm_token'] == scm_name and row['branch_type'] == 'root':
        has_root = True

        root_remote_name = row['remote_name']
        remote_name_list.append(root_remote_name)

        root_git_reporoot = yaml_expand_value(row['git_reporoot'])
        root_svn_reporoot = yaml_expand_value(row['svn_reporoot'])

        root_git_local_branch = yaml_expand_value(row['git_local_branch'])
        root_git_remote_branch = yaml_expand_value(row['git_remote_branch'])

        root_svn_path_prefix = yaml_expand_value(row['svn_path_prefix'])

        git_refspec_token = get_git_refspec_token(root_git_local_branch, root_git_remote_branch)

        call('git', ['fetch', root_remote_name, git_refspec_token])

        git_local_ref_token = get_git_local_ref_token(root_git_local_branch, root_git_remote_branch)

        break

    if not has_root:
      raise Exception('Have has no root branch in the git_repos.lst')

    git_remote_ref_token, git_remote_local_ref_token = \
      get_git_remote_ref_token(root_remote_name, root_git_local_branch, root_git_remote_branch)

    # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
    # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

    revert_if_git_head_refs_is_not_last_pushed(root_git_reporoot, git_local_ref_token, git_remote_ref_token,
      git_remote_local_ref_token, reset_hard = reset_hard)

    # provoke git svn revisions rebuild

    git_svn_fetch_cmdline_list = []

    # generate `--ignore_paths` for subtrees

    git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(git_repos_reader, scm_name, root_remote_name, root_svn_reporoot)
    if len(git_svn_fetch_ignore_paths_regex) > 0:
      git_svn_fetch_cmdline_list.append('--ignore-paths=' + git_svn_fetch_ignore_paths_regex)

    # git-svn (re)fetch last svn revision (faster than (re)fetch all revisions)

    git_last_svn_rev = git_svn_fetch_to_last_git_pushed_svn_rev(root_remote_name, root_git_local_branch, root_git_remote_branch, root_svn_reporoot, root_svn_path_prefix, git_svn_fetch_cmdline_list)

    # revert again if last fetch has broke the HEAD
    revert_if_git_head_refs_is_not_last_pushed(root_git_reporoot, git_local_ref_token, git_remote_ref_token,
      git_remote_local_ref_token, reset_hard = reset_hard, revert_after_fetch = True)

    print('---')

    if root_only:
      return

    if fetch_subtrees_root is None:
      fetch_subtrees_root = wcroot_path + '/.git/svn2git/gitwc'

    # Fetch content of non root git repositories into stanalone working copies inside the `fetch_subtrees_root` directory,
    # use the combination of the `remote_name` and the `parent_git_path_prefix` as a prefix to a working copy directory.

    git_repos_reader.reset()

    for subtree_row in git_repos_reader:
      if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
        subtree_parent_git_path_prefix = subtree_row['parent_git_path_prefix']

        if subtree_parent_git_path_prefix == '.':
          raise Exception('not root branch type must have not empty git subtree path prefix')

        # expand if contains a variable substitution
        subtree_parent_git_path_prefix = yaml_expand_value(subtree_parent_git_path_prefix)
        subtree_remote_name = subtree_row['remote_name']

        if subtree_remote_name in remote_name_list:
          raise Exception('remote_name must be unique in the repositories list for the same scm_token')

        remote_name_list.append(subtree_remote_name)

        subtree_git_wcroot = os.path.abspath(os.path.join(fetch_subtrees_root, subtree_remote_name + "'" + subtree_parent_git_path_prefix.replace('/', '--'))).replace('\\', '/')

        print(' ->> pushd: {0}...'.format(subtree_git_wcroot))

        with local.cwd(subtree_git_wcroot):
          subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])
          subtree_svn_reporoot = yaml_expand_value(subtree_row['svn_reporoot'])

          subtree_git_local_branch = yaml_expand_value(subtree_row['git_local_branch'])
          subtree_git_remote_branch = yaml_expand_value(subtree_row['git_remote_branch'])

          subtree_svn_path_prefix = yaml_expand_value(subtree_row['svn_path_prefix'])

          subtree_git_refspec_token = get_git_refspec_token(subtree_git_local_branch, subtree_git_remote_branch)

          call('git', ['fetch', subtree_remote_name, subtree_git_refspec_token])

          subtree_git_local_ref_token = get_git_local_ref_token(subtree_git_local_branch, subtree_git_remote_branch)

          """
          with open('.git/HEAD', 'wt') as subtree_head_file:
            subtree_head_file.write('ref: ' + subtree_git_local_ref_token)
            subtree_head_file.close()
          """

          subtree_git_remote_ref_token, subtree_git_remote_local_ref_token = \
            get_git_remote_ref_token(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch)

          # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
          # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

          revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard)

          # provoke git svn revisions rebuild

          subtree_git_svn_fetch_cmdline_list = []

          with GitReposListReader(configure_dir + '/git_repos.lst') as subtree_git_repos_reader:
            # generate `--ignore_paths` for subtrees

            subtree_git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(subtree_git_repos_reader, scm_name, subtree_remote_name, subtree_svn_reporoot)
            if len(subtree_git_svn_fetch_ignore_paths_regex) > 0:
              subtree_git_svn_fetch_cmdline_list.append('--ignore-paths=' + subtree_git_svn_fetch_ignore_paths_regex)

            # git-svn (re)fetch last svn revision (faster than (re)fetch all revisions)

            subtree_git_last_svn_rev = \
              git_svn_fetch_to_last_git_pushed_svn_rev(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch, subtree_svn_reporoot, subtree_svn_path_prefix, subtree_git_svn_fetch_cmdline_list)

            # revert again if last fetch has broke the HEAD
            revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard, revert_after_fetch = True)

        print('---')

# CAUTION:
#   * By default the function processes the root repository together with the subtree repositories.
#     If you want to skip the subtree repositories, then do use the `root_only` argument.
#     If you want to process subtree repositories by a custom (not builtin) path,
#     then do use the `reset_subtrees_root` argument as a root path to the subtree directories.
#
def git_reset(configure_dir, scm_name, reset_subtrees_root = None, root_only = False, reset_hard = False):
  print(">git_reset: {0}".format(configure_dir))

  if not reset_subtrees_root is None:
    print(' * reset_subtrees_root: `' + reset_subtrees_root + '`')

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 32

  if not reset_subtrees_root is None and not os.path.isdir(reset_subtrees_root):
    print_err("{0}: error: reset_subtrees_root directory does not exist: `{1}`.".format(sys.argv[0], reset_subtrees_root))
    return 33

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  git_user = getvar(scm_name + '.USER')
  git_email = getvar(scm_name + '.EMAIL')

  print(' -> pushd: {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  with local.cwd(wcroot_path), GitReposListReader(configure_dir + '/git_repos.lst') as git_repos_reader:
    has_root = False

    remote_name_list = []

    for row in git_repos_reader:
      if row['scm_token'] == scm_name and row['branch_type'] == 'root':
        has_root = True

        root_remote_name = row['remote_name']
        remote_name_list.append(root_remote_name)

        root_git_reporoot = yaml_expand_value(row['git_reporoot'])

        root_git_local_branch = yaml_expand_value(row['git_local_branch'])
        root_git_remote_branch = yaml_expand_value(row['git_remote_branch'])

        git_local_ref_token = get_git_local_ref_token(root_git_local_branch, root_git_remote_branch)

        break

    if not has_root:
      raise Exception('Have has no root branch in the git_repos.lst')

    git_remote_ref_token, git_remote_local_ref_token = \
      get_git_remote_ref_token(root_remote_name, root_git_local_branch, root_git_remote_branch)

    # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
    # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

    revert_if_git_head_refs_is_not_last_pushed(root_git_reporoot, git_local_ref_token, git_remote_ref_token,
      git_remote_local_ref_token, reset_hard = reset_hard)

    print('---')

    if root_only:
      return

    if reset_subtrees_root is None:
      reset_subtrees_root = wcroot_path + '/.git/svn2git/gitwc'

    # Reset content of non root git repositories in the stanalone working copies inside the `reset_subtrees_root` directory,
    # use the combination of the `remote_name` and the `parent_git_path_prefix` as a prefix to a working copy directory.

    git_repos_reader.reset()

    for subtree_row in git_repos_reader:
      if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
        subtree_parent_git_path_prefix = subtree_row['parent_git_path_prefix']

        if subtree_parent_git_path_prefix == '.':
          raise Exception('not root branch type must have not empty git subtree path prefix')

        # expand if contains a variable substitution
        subtree_parent_git_path_prefix = yaml_expand_value(subtree_parent_git_path_prefix)
        subtree_remote_name = subtree_row['remote_name']

        if subtree_remote_name in remote_name_list:
          raise Exception('remote_name must be unique in the repositories list for the same scm_token')

        remote_name_list.append(subtree_remote_name)

        subtree_git_wcroot = os.path.abspath(os.path.join(reset_subtrees_root, subtree_remote_name + "'" + subtree_parent_git_path_prefix.replace('/', '--'))).replace('\\', '/')

        print(' ->> pushd: {0}...'.format(subtree_git_wcroot))

        with local.cwd(subtree_git_wcroot):
          subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])

          subtree_git_local_branch = yaml_expand_value(subtree_row['git_local_branch'])
          subtree_git_remote_branch = yaml_expand_value(subtree_row['git_remote_branch'])

          subtree_git_local_ref_token = get_git_local_ref_token(subtree_git_local_branch, subtree_git_remote_branch)

          subtree_git_remote_ref_token, subtree_git_remote_local_ref_token = \
            get_git_remote_ref_token(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch)

          # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
          # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

          revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard)

          print('---')

# CAUTION:
#   * By default the function processes the root repository together with the subtree repositories.
#     If you want to skip the subtree repositories, then do use the `root_only` argument.
#     If you want to process subtree repositories by a custom (not builtin) path,
#     then do use the `pull_subtrees_root` argument as a root path to the subtree directories.
#
def git_pull(configure_dir, scm_name, pull_subtrees_root = None, root_only = False, reset_hard = False):
  print(">git_pull: {0}".format(configure_dir))

  if not pull_subtrees_root is None:
    print(' * pull_subtrees_root: `' + pull_subtrees_root + '`')

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 32

  if not pull_subtrees_root is None and not os.path.isdir(pull_subtrees_root):
    print_err("{0}: error: pull_subtrees_root directory does not exist: `{1}`.".format(sys.argv[0], pull_subtrees_root))
    return 33

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  git_user = getvar(scm_name + '.USER')
  git_email = getvar(scm_name + '.EMAIL')

  print(' -> pushd: {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  with local.cwd(wcroot_path), GitReposListReader(configure_dir + '/git_repos.lst') as git_repos_reader:
    has_root = False

    remote_name_list = []

    for row in git_repos_reader:
      if row['scm_token'] == scm_name and row['branch_type'] == 'root':
        has_root = True

        root_remote_name = row['remote_name']
        remote_name_list.append(root_remote_name)

        root_git_reporoot = yaml_expand_value(row['git_reporoot'])
        root_svn_reporoot = yaml_expand_value(row['svn_reporoot'])

        root_git_local_branch = yaml_expand_value(row['git_local_branch'])
        root_git_remote_branch = yaml_expand_value(row['git_remote_branch'])

        root_svn_path_prefix = yaml_expand_value(row['svn_path_prefix'])

        git_refspec_token = get_git_refspec_token(root_git_local_branch, root_git_remote_branch)

        call('git', ['fetch', root_remote_name, git_refspec_token])

        git_local_ref_token = get_git_local_ref_token(root_git_local_branch, root_git_remote_branch)

        break

    if not has_root:
      raise Exception('Have has no root branch in the git_repos.lst')

    git_remote_ref_token, git_remote_local_ref_token = \
      get_git_remote_ref_token(root_remote_name, root_git_local_branch, root_git_remote_branch)

    # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
    # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

    revert_if_git_head_refs_is_not_last_pushed(root_git_reporoot, git_local_ref_token, git_remote_ref_token,
      git_remote_local_ref_token, reset_hard = reset_hard)

    # provoke git svn revisions rebuild

    git_svn_fetch_cmdline_list = []

    # generate `--ignore_paths` for subtrees

    git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(git_repos_reader, scm_name, root_remote_name, root_svn_reporoot)
    if len(git_svn_fetch_ignore_paths_regex) > 0:
      git_svn_fetch_cmdline_list.append('--ignore-paths=' + git_svn_fetch_ignore_paths_regex)

    # git-svn (re)fetch last svn revision (faster than (re)fetch all revisions)

    git_last_svn_rev = git_svn_fetch_to_last_git_pushed_svn_rev(root_remote_name, root_git_local_branch, root_git_remote_branch, root_svn_reporoot, root_svn_path_prefix, git_svn_fetch_cmdline_list)

    # revert again if last fetch has broke the HEAD
    revert_if_git_head_refs_is_not_last_pushed(root_git_reporoot, git_local_ref_token, git_remote_ref_token,
      git_remote_local_ref_token, reset_hard = reset_hard, revert_after_fetch = True)

    """
    with open('.git/HEAD', 'wt') as head_file:
      head_file.write('ref: ' + git_local_ref_token)
      head_file.close()
    """

    call('git', ['switch', root_git_local_branch])

    print('---')

    if root_only:
      return

    if pull_subtrees_root is None:
      pull_subtrees_root = wcroot_path + '/.git/svn2git/gitwc'

    # Fetch content of non root git repositories into stanalone working copies inside the `pull_subtrees_root` directory,
    # use the combination of the `remote_name` and the `parent_git_path_prefix` as a prefix to a working copy directory.

    git_repos_reader.reset()

    for subtree_row in git_repos_reader:
      if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
        subtree_parent_git_path_prefix = subtree_row['parent_git_path_prefix']

        if subtree_parent_git_path_prefix == '.':
          raise Exception('not root branch type must have not empty git subtree path prefix')

        # expand if contains a variable substitution
        subtree_parent_git_path_prefix = yaml_expand_value(subtree_parent_git_path_prefix)
        subtree_remote_name = subtree_row['remote_name']

        if subtree_remote_name in remote_name_list:
          raise Exception('remote_name must be unique in the repositories list for the same scm_token')

        remote_name_list.append(subtree_remote_name)

        subtree_git_wcroot = os.path.abspath(os.path.join(pull_subtrees_root, subtree_remote_name + "'" + subtree_parent_git_path_prefix.replace('/', '--'))).replace('\\', '/')

        print(' ->> pushd: {0}...'.format(subtree_git_wcroot))

        with local.cwd(subtree_git_wcroot):
          subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])
          subtree_svn_reporoot = yaml_expand_value(subtree_row['svn_reporoot'])

          subtree_git_local_branch = yaml_expand_value(subtree_row['git_local_branch'])
          subtree_git_remote_branch = yaml_expand_value(subtree_row['git_remote_branch'])

          subtree_svn_path_prefix = yaml_expand_value(subtree_row['svn_path_prefix'])

          subtree_git_refspec_token = get_git_refspec_token(subtree_git_local_branch, subtree_git_remote_branch)

          call('git', ['fetch', subtree_remote_name, subtree_git_refspec_token])

          subtree_git_local_ref_token = get_git_local_ref_token(subtree_git_local_branch, subtree_git_remote_branch)

          subtree_git_remote_ref_token, subtree_git_remote_local_ref_token = \
            get_git_remote_ref_token(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch)

          # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
          # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

          revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard)

          # provoke git svn revisions rebuild

          subtree_git_svn_fetch_cmdline_list = []

          with GitReposListReader(configure_dir + '/git_repos.lst') as subtree_git_repos_reader:
            # generate `--ignore_paths` for subtrees

            subtree_git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(subtree_git_repos_reader, scm_name, subtree_remote_name, subtree_svn_reporoot)
            if len(subtree_git_svn_fetch_ignore_paths_regex) > 0:
              subtree_git_svn_fetch_cmdline_list.append('--ignore-paths=' + subtree_git_svn_fetch_ignore_paths_regex)

            # git-svn (re)fetch last svn revision (faster than (re)fetch all revisions)

            subtree_git_last_svn_rev = \
              git_svn_fetch_to_last_git_pushed_svn_rev(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch, subtree_svn_reporoot, subtree_svn_path_prefix, subtree_git_svn_fetch_cmdline_list)

            # revert again if last fetch has broke the HEAD
            revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard, revert_after_fetch = True)

            """
            with open('.git/HEAD', 'wt') as subtree_head_file:
              subtree_head_file.write('ref: ' + subtree_git_local_ref_token)
              subtree_head_file.close()
            """

            call('git', ['switch', subtree_git_local_branch])

        print('---')

# CAUTION:
#   * The function always does process the root repository together along with the subtree repositories, because
#     it is a part of a whole 1-way synchronization process between the SVN and the GIT.
#     If you want to reduce the depth or change the configuration of subtrees, you have to edit the respective
#     `git_repos.lst` file.
#     If you want to process subtree repositories by a custom (not builtin) path,
#     then do use the `push_subtrees_root` argument as a root path to the subtree directories.
#
def git_push_from_svn(configure_dir, scm_name, push_subtrees_root = None, reset_hard = False):
  print(">git_push_from_svn: {0}".format(configure_dir))

  if not push_subtrees_root is None:
    print(' * push_subtrees_root: `' + push_subtrees_root + '`')

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 32

  if not push_subtrees_root is None and not os.path.isdir(push_subtrees_root):
    print_err("{0}: error: push_subtrees_root directory does not exist: `{1}`.".format(sys.argv[0], push_subtrees_root))
    return 33

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  git_user = getvar(scm_name + '.USER')
  git_email = getvar(scm_name + '.EMAIL')

  print(' -> pushd: {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  with local.cwd(wcroot_path), GitReposListReader(configure_dir + '/git_repos.lst') as git_repos_reader:
    has_root = False

    for row in git_repos_reader:
      if row['scm_token'] == scm_name and row['branch_type'] == 'root':
        has_root = True

        root_remote_name = row['remote_name']

        root_git_reporoot = yaml_expand_value(row['git_reporoot'])
        root_svn_reporoot = yaml_expand_value(row['svn_reporoot'])

        root_git_local_branch = yaml_expand_value(row['git_local_branch'])
        root_git_remote_branch = yaml_expand_value(row['git_remote_branch'])

        root_parent_git_path_prefix = yaml_expand_value(row['parent_git_path_prefix'])
        root_svn_path_prefix = yaml_expand_value(row['svn_path_prefix'])

        git_refspec_token = get_git_refspec_token(root_git_local_branch, root_git_remote_branch)

        #call('git', ['fetch', root_remote_name, git_refspec_token])

        git_local_ref_token = get_git_local_ref_token(root_git_local_branch, root_git_remote_branch)

        break

    if not has_root:
      raise Exception('Have has no root branch in the git_repos.lst')

    # Algorithm:
    #
    # 1. Iterate over all subtree repositories to request:
    # 1.1. The last has been pushed svn commit with the revision from the git local repository, including the git commit hash and timestamp.
    # 1.2. The first not yet pushed svn commit with the revision from the svn remote repository, including the svn commit timestamp.
    #
    # 2. Compare parent-child repositories on timestamps between the last has been pushed svn commit and the first not yet pushed svn commit:
    # 2.1. If the first not yet pushed svn commit which has an association with the parent/child git repository is not after a timestamp of
    #      the last has been pushed svn commit in the child/parent git repository, then the pushed one commit is ahead to the not pushed one
    #      and must be reverted or resetted back to the not pushed state (exceptional case, can happen, for example, if svn-to-git commit
    #      timestamps is not in sync and must be explicitly offsetted).
    # 2.2. Otherwise the not pushed one svn commit can be pushed into the git repository in an ordered push, where all git pushes must happen
    #      beginning from the most child git repository to the most parent git repository.
    #
    # 3. Fetch the first not yet pushed to the git the svn commit, rebase and push it into the git repository one-by-one beginning from the
    #    most child git repository to the most parent git repository. If a parent repository does not have has svn commit to push with the
    #    same revision from a child repository, then anyway do merge and push changes into the parent git repository. This will introduce
    #    changes from children repositories into parent repositories even if a parent repository does not have has changes with the same svn
    #    revision from a child svn repository.
    #

    if push_subtrees_root is None:
      push_subtrees_root = wcroot_path + '/.git/svn2git/gitwc'

    # 1.
    #

    print('- Reading GIT-SVN repositories list:')

    column_names = ['<remote_name>', '<git_reporoot>', '<parent_git_prefix>', '<svn_repopath>', '<git_local_branch>', '<git_remote_branch>']
    column_widths = [15, 64, 20, 64, 20, 20]

    root_svn_repopath = root_svn_reporoot + ('/' + root_svn_path_prefix if root_svn_path_prefix != '' else '')

    svn_reporoot_list = [root_svn_reporoot]

    print('  {:<{}} {:<{}} {:<{}} {:<{}} {:<{}} {:<{}}'.format(
      *(i for j in [(column_name, column_width) for column_name, column_width in zip(column_names, column_widths)] for i in j)
    ))

    print('  ' + (column_widths[0] * '='),
      (column_widths[1] * '='),
      (column_widths[2] * '='),
      (column_widths[3] * '='),
      (column_widths[4] * '='),
      (column_widths[5] * '=')
    )

    row_values = [root_remote_name, root_git_reporoot, root_parent_git_path_prefix, root_svn_repopath, root_git_local_branch, root_git_remote_branch]
    print('  {:<{}} {:<{}} {:<{}} {:<{}} {:<{}} {:<{}}'.format(
      *(i for j in [(row_value, column_width) for row_value, column_width in zip(row_values, column_widths)] for i in j)
    ))

    # Recursive format:
    #   { <root_repo_remote_name> : ( <root_repo_params>, <root_fetch_state>, { <child_remote_name> : ( <child_repo_params>, <child_fetch_state>, ... ), ... } ) }
    #   <*_repo_params>:  {
    #     'nest_index'                    : <integer>,
    #     'remote_name'                   : <string>,
    #     'parent_remote_name'            : <string>,
    #     'git_reporoot'                  : <string>,
    #     'parent_git_path_prefix'        : <string>,
    #     'svn_reporoot'                  : <string>,
    #     'svn_path_prefix'               : <string>,
    #     'svn_repo_uuid'                 : <string>,
    #     'git_local_branch'              : <string>,
    #     'git_remote_branch'             : <string>
    #   }
    #   <*_fetch_state>:  {
    #     # all `last_pushed_*` either None or required at a time
    #     'last_pushed_svn_rev'           : <integer>,
    #     'last_pushed_git_hash'          : <string>,
    #     'last_pushed_git_timestamp'     : <integer>,
    #     # all `first_unpushed_*` either None or required at a time
    #     'first_unpushed_svn_rev'        : <integer>,
    #     'first_unpushed_svn_timestamp'  : <integer>
    #   }
    #
    git_svn_repo_tree = {
      root_remote_name : (
        {
          'nest_index'                    : 0,                  # the root
          'remote_name'                   : root_remote_name,
          'parent_remote_name'            : '.',                # special case: if parent remote name is the '.', then it is the root
          'git_reporoot'                  : root_git_reporoot,
          'parent_git_path_prefix'        : root_parent_git_path_prefix,
          'svn_reporoot'                  : root_svn_reporoot,
          #'svn_repo_uuid'                : '',
          'svn_path_prefix'               : root_svn_path_prefix,
          'git_local_branch'              : root_git_local_branch,
          'git_remote_branch'             : root_git_remote_branch
        },
        # must be assigned at once, otherwise: `TypeError: 'tuple' object does not support item assignment`
        {},
        {}
      )
    }

    git_svn_repo_tree_tuple_ref_preorder_list = [ git_svn_repo_tree[root_remote_name] ]

    # Format: [ <ref_to_repo_tree_tuple>, ... ]
    #
    parent_child_remote_names_to_parse = [ git_svn_repo_tree[root_remote_name] ]

    # repository tree pre-order traversal 
    while True: # read `parent_child_remote_names_to_parse` until empty
      remote_name_list = []

      parent_repo_tree_tuple = parent_child_remote_names_to_parse.pop(0)
      parent_repo_params = parent_repo_tree_tuple[0]
      parent_nest_index = parent_repo_params['nest_index']
      parent_remote_name = parent_repo_params['remote_name']
      parent_parent_remote_name = parent_repo_params['parent_remote_name']

      remote_name_list = [parent_remote_name]

      insert_to_front_index = 0

      git_repos_reader.reset()

      for subtree_row in git_repos_reader:
        if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
          subtree_parent_remote_name = subtree_row['parent_remote_name']

          if subtree_parent_remote_name == parent_remote_name:
            subtree_remote_name = subtree_row['remote_name']
            subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])
            subtree_svn_reporoot = yaml_expand_value(subtree_row['svn_reporoot'])
            subtree_git_local_branch = yaml_expand_value(subtree_row['git_local_branch'])
            subtree_git_remote_branch = yaml_expand_value(subtree_row['git_remote_branch'])
            subtree_parent_git_path_prefix = yaml_expand_value(subtree_row['parent_git_path_prefix'])
            subtree_svn_path_prefix = yaml_expand_value(subtree_row['svn_path_prefix'])

            if subtree_svn_reporoot not in svn_reporoot_list:
              svn_reporoot_list.append(subtree_svn_reporoot)

            subtree_svn_repopath = subtree_svn_reporoot + ('/' + subtree_svn_path_prefix if subtree_svn_path_prefix != '' else '')

            subtree_remote_name_prefix_str = '| ' * (parent_nest_index + 1)

            row_values = [subtree_remote_name, subtree_git_reporoot, subtree_parent_git_path_prefix, subtree_svn_repopath, subtree_git_local_branch, subtree_git_remote_branch]
            print('  {:<{}} {:<{}} {:<{}} {:<{}} {:<{}} {:<{}}'.format(
              *(i for j in [(row_value, column_width) for row_value, column_width in zip(row_values, column_widths)] for i in j)
            ))

            if subtree_remote_name in remote_name_list:
              raise Exception('remote_name must be unique in the repositories list for the same scm_token')

            remote_name_list.append(subtree_remote_name)

            ref_child_repo_params = parent_repo_tree_tuple[2]

            if subtree_remote_name in ref_child_repo_params:
              raise Exception('subtree_remote_name must be unique in the ref_child_repo_params')

            ref_child_repo_tree_tuple = ref_child_repo_params[subtree_remote_name] = (
              {
                'nest_index'                    : parent_nest_index + 1,
                'remote_name'                   : subtree_remote_name,
                'parent_remote_name'            : parent_remote_name,
                'git_reporoot'                  : subtree_git_reporoot,
                'parent_git_path_prefix'        : subtree_parent_git_path_prefix,
                'svn_reporoot'                  : subtree_svn_reporoot,
                #'svn_repo_uuid'                : '',
                'svn_path_prefix'               : subtree_svn_path_prefix,
                'git_local_branch'              : subtree_git_local_branch,
                'git_remote_branch'             : subtree_git_remote_branch,
              },
              # must be assigned at once, otherwise: `TypeError: 'tuple' object does not support item assignment`
              {},
              {}
            )

            git_svn_repo_tree_tuple_ref_preorder_list.append(ref_child_repo_tree_tuple)

            # push to front instead of popped
            parent_child_remote_names_to_parse.insert(insert_to_front_index, ref_child_repo_tree_tuple)
            insert_to_front_index += 1

      if len(parent_child_remote_names_to_parse) == 0:
        break

    print('  ' + (column_widths[0] * '-'),
      (column_widths[1] * '-'),
      (column_widths[2] * '-'),
      (column_widths[3] * '-'),
      (column_widths[4] * '-'),
      (column_widths[5] * '-')
    )

    print('- Updating SVN repositories info:')

    svn_repo_root_to_uuid_dict = {}

    for git_svn_repo_tree_tuple_ref in git_svn_repo_tree_tuple_ref_preorder_list:
      ref_repo_params = git_svn_repo_tree_tuple_ref[0]
      svn_reporoot = ref_repo_params['svn_reporoot']

      if svn_reporoot not in svn_repo_root_to_uuid_dict.keys():
        ret = call('svn', ['info', '--show-item', 'repos-uuid', svn_reporoot], stdout = None, stderr = None)

        svn_repo_uuid = ret[1]
        if not svn_repo_uuid is None:
          svn_repo_uuid = svn_repo_uuid.rstrip()

        if svn_repo_uuid != '':
          svn_repo_root_to_uuid_dict[svn_reporoot] = svn_repo_uuid

        if len(svn_repo_uuid) > 0:
          print(svn_repo_uuid)
        if len(ret[2]) > 0:
          print(ret[2].rstrip())
      else:
        ref_repo_params['svn_repo_uuid'] = svn_repo_root_to_uuid_dict[svn_reporoot]

    # 2.
    #

    print('- Checking parent-child GIT/SVN repositories for the last fetch state...')

    #parent_svn_reporoot_urlpath = tkl.ParseResult('', *tkl.urlparse(svn_reporoot)[1:]).geturl()

    git_remote_ref_token, git_remote_local_ref_token = \
      get_git_remote_ref_token(root_remote_name, root_git_local_branch, root_git_remote_branch)

    # provoke git svn revisions rebuild

    git_svn_fetch_cmdline_list = []

    # generate `--ignore_paths` for subtrees

    git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(git_repos_reader, scm_name, root_remote_name, root_svn_reporoot)
    if len(git_svn_fetch_ignore_paths_regex) > 0:
      git_svn_fetch_cmdline_list.append('--ignore-paths=' + git_svn_fetch_ignore_paths_regex)

    # git-svn get last svn revision w/o fetch because it must be already fetched

    root_git_last_svn_rev, root_git_commit_hash, root_git_commit_timestamp, root_git_from_commit_timestamp, root_num_git_commits = \
      get_last_git_svn_rev_by_git_log(root_remote_name, root_git_local_branch, root_git_remote_branch, root_svn_reporoot, root_svn_path_prefix)

    """
    git_repos_reader.reset()

    for subtree_row in git_repos_reader:
      if subtree_row['scm_token'] == scm_name and subtree_row['branch_type'] != 'root':
        subtree_parent_git_path_prefix = subtree_row['parent_git_path_prefix']

        if subtree_parent_git_path_prefix == '.':
          raise Exception('not root branch type must have not empty git subtree path prefix')

        # expand if contains a variable substitution
        subtree_parent_git_path_prefix = yaml_expand_value(subtree_parent_git_path_prefix)
        subtree_remote_name = yaml_expand_value(subtree_row['remote_name'])

        subtree_git_wcroot = os.path.abspath(os.path.join(push_subtrees_root, subtree_remote_name + "'" + subtree_parent_git_path_prefix.replace('/', '--'))).replace('\\', '/')

        print(' ->> pushd: {0}...'.format(subtree_git_wcroot))

        with local.cwd(subtree_git_wcroot):
          subtree_git_reporoot = yaml_expand_value(subtree_row['git_reporoot'])
          subtree_svn_reporoot = yaml_expand_value(subtree_row['svn_reporoot'])

          subtree_git_local_branch = yaml_expand_value(subtree_row['git_local_branch'])
          subtree_git_remote_branch = yaml_expand_value(subtree_row['git_remote_branch'])

          subtree_svn_path_prefix = yaml_expand_value(subtree_row['svn_path_prefix'])

          subtree_git_refspec_token = get_git_refspec_token(subtree_git_local_branch, subtree_git_remote_branch)

          call('git', ['fetch', subtree_remote_name, subtree_git_refspec_token])

          subtree_git_local_ref_token = get_git_local_ref_token(subtree_git_local_branch, subtree_git_remote_branch)

          subtree_git_remote_ref_token, subtree_git_remote_local_ref_token = \
            get_git_remote_ref_token(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch)

          # 1. compare the last pushed commit hash with the last fetched commit hash and if different, then revert FETCH_HEAD
          # 2. additionally, compare the last pushed commit hash with the head commit hash and if different then revert HEAD

          revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard)

          # provoke git svn revisions rebuild

          subtree_git_svn_fetch_cmdline_list = []

          with GitReposListReader(configure_dir + '/git_repos.lst') as subtree_git_repos_reader:
            # generate `--ignore_paths` for subtrees

            subtree_git_svn_fetch_ignore_paths_regex = get_git_svn_subtree_ignore_paths_regex(subtree_git_repos_reader, scm_name, subtree_remote_name, subtree_svn_reporoot)
            if len(subtree_git_svn_fetch_ignore_paths_regex) > 0:
              subtree_git_svn_fetch_cmdline_list.append('--ignore-paths=' + subtree_git_svn_fetch_ignore_paths_regex)

            # git-svn (re)fetch last svn revision (faster than (re)fetch all revisions)

            subtree_git_last_svn_rev = \
              git_svn_fetch_to_last_git_pushed_svn_rev(subtree_remote_name, subtree_git_local_branch, subtree_git_remote_branch, subtree_svn_reporoot, subtree_svn_path_prefix, subtree_git_svn_fetch_cmdline_list)

            # revert again if last fetch has broke the HEAD
            revert_if_git_head_refs_is_not_last_pushed(subtree_git_reporoot, subtree_git_local_ref_token, subtree_git_remote_ref_token,
            subtree_git_remote_local_ref_token, reset_hard = reset_hard, revert_after_fetch = True)

            "#""
            with open('.git/HEAD', 'wt') as subtree_head_file:
              subtree_head_file.write('ref: ' + subtree_git_local_ref_token)
              subtree_head_file.close()
            "#""

            call('git', ['switch', subtree_git_local_branch])

    """
