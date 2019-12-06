import os, sys, inspect, argparse
#from datetime import datetime

SOURCE_FILE = os.path.abspath(inspect.getsourcefile(lambda:0)).replace('\\','/')
SOURCE_DIR = os.path.dirname(SOURCE_FILE)

# portable import to the global space
sys.path.append(SOURCE_DIR + '/tools/tacklelib')
import tacklelib as tkl

tkl.tkl_init(tkl)

# cleanup
del tkl # must be instead of `tkl = None`, otherwise the variable would be still persist
sys.path.pop()


tkl_declare_global('CONFIGURE_DIR', sys.argv[1].replace('\\', '/') if len(sys.argv) >= 2 else '')
tkl_declare_global('SCM_TOKEN', sys.argv[2] if len(sys.argv) >= 3 else '')
tkl_declare_global('CMD_TOKEN', sys.argv[3] if len(sys.argv) >= 4 else '')

# format: [(<header_str>, <stderr_str>), ...]
tkl_declare_global('g_registered_ignored_errors', []) # must be not empty value to save the reference

# basic initialization, loads `config.private.yaml`
tkl_source_module(SOURCE_DIR, '__init__.xsh')

tkl_import_module(TACKLELIB_ROOT, 'tacklelib.utils.py', 'tkl')
tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.svn.xsh', 'cmdoplib_svn')
tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.gitsvn.xsh', 'cmdoplib_gitsvn')

if not os.path.isdir(CONFIGURE_ROOT):
  raise Exception('CONFIGURE_ROOT directory does not exist: `{0}`'.format(CONFIGURE_ROOT))

if not os.path.isdir(CONFIGURE_DIR):
  raise Exception('CONFIGURE_DIR directory does not exist: `{0}`'.format(CONFIGURE_DIR))

if not SCM_TOKEN:
  raise Exception('SCM_TOKEN name is not defined: `{0}`'.format(SCM_TOKEN))
if not CMD_TOKEN:
  raise Exception('CMD_TOKEN name is not defined: `{0}`'.format(CMD_TOKEN))

#try:
#  os.mkdir(os.path.join(CONFIGURE_DIR, '.log'))
#except:
#  pass

def cmdop(configure_dir, scm_token, cmd_token, bare_args, subtrees_root = None, root_only = False, reset_hard = False):
  print("cmdop: {0} {1}: entering `{2}`".format(scm_token, cmd_token, configure_dir))

  with tkl.OnExit(lambda: print("cmdop: {0} {1}: leaving `{2}`\n---".format(scm_token, cmd_token, configure_dir))):
    if not subtrees_root is None:
      print(' subtrees_root: ' + subtrees_root)
    if root_only:
      print(' root_only: ' + str(root_only))
    if reset_hard:
      print(' reset_hard: ' + str(reset_hard))

    if configure_dir == '':
      print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
      exit(1)

    if configure_dir[-1:] in ['\\', '/']:
      configure_dir = configure_dir[:-1]

    if not os.path.isdir(configure_dir):
      print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
      exit(2)

    hub_root_var = scm_token + '.HUB_ROOT'
    if not hasglobalvar(hub_root_var):
      print_err("{0}: error: hub root variable is not declared for the scm_token as prefix: `{1}`.".format(sys.argv[0], hub_root_var))
      exit(3)

    hub_abbr_var = scm_token + '.HUB_ABBR'
    if not hasglobalvar(hub_abbr_var):
      print_err("{0}: error: hub abbrivation variable is not declared for the scm_token as prefix: `{1}`.".format(sys.argv[0], hub_abbr_var))
      exit(4)

    hub_abbr = getglobalvar(hub_abbr_var)
    scm_type = scm_token[:3].lower()

    # loads `config.yaml` from `configure_dir`
    yaml_global_vars_pushed = False
    if os.path.isfile(configure_dir + '/config.yaml.in'):
      # save all old variable values and remember all newly added variables as a new stack record
      yaml_push_global_vars()
      yaml_global_vars_pushed = True
      yaml_load_config(configure_dir, 'config.yaml', to_globals = True, to_environ = False,
        search_by_global_pred_at_third = lambda var_name: getglobalvar(var_name))

    # loads `config.env.yaml` from `configure_dir`
    yaml_environ_vars_pushed = False
    if os.path.isfile(configure_dir + '/config.env.yaml.in'):
      # save all old variable values and remember all newly added variables as a new stack record
      yaml_push_environ_vars()
      yaml_environ_vars_pushed = True
      yaml_load_config(configure_dir, 'config.env.yaml', to_globals = False, to_environ = True,
        search_by_environ_pred_at_third = lambda var_name: getglobalvar(var_name))

    ret = 0

    # do action only if not in the root and a command file is present
    if not tkl.compare_file_paths(configure_dir, CONFIGURE_ROOT):
      dir_files_wo_ext = [os.path.splitext(f)[0] for f in os.listdir(configure_dir) if os.path.isfile(f)]
      cmd_file = hub_abbr + '~' + scm_type + '~' + cmd_token

      is_cmd_file_found = False
      for dir_file_wo_ext in dir_files_wo_ext:
        if tkl.compare_file_paths(dir_file_wo_ext, cmd_file):
          is_cmd_file_found = True
          break

      if is_cmd_file_found:
        if scm_type == 'svn':
          if hasglobalvar(scm_token + '.WCROOT_DIR'):
            if cmd_token == 'update':
              ret = cmdoplib_svn.svn_update(configure_dir, scm_token, bare_args)
            elif cmd_token == 'checkout':
              ret = cmdoplib_svn.svn_checkout(configure_dir, scm_token, bare_args)
            elif cmd_token == 'relocate':
              ret = cmdoplib_svn.svn_relocate(configure_dir, scm_token, bare_args)
            else:
              raise Exception('unknown command name: ' + str(cmd_token))
        elif scm_type == 'git':
          if hasglobalvar(scm_token + '.WCROOT_DIR'):
            if cmd_token == 'init':
              ret = cmdoplib_gitsvn.git_init(configure_dir, scm_token,
                subtrees_root = subtrees_root, root_only = root_only)
            elif cmd_token == 'fetch':
              ret = cmdoplib_gitsvn.git_fetch(configure_dir, scm_token,
                subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
            elif cmd_token == 'reset':
              ret = cmdoplib_gitsvn.git_reset(configure_dir, scm_token,
                subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
            elif cmd_token == 'pull':
              ret = cmdoplib_gitsvn.git_pull(configure_dir, scm_token,
                subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
            elif cmd_token == 'push_svn_to_git':
              ret = cmdoplib_gitsvn.git_push_from_svn(configure_dir, scm_token,
                subtrees_root = subtrees_root, reset_hard = reset_hard)
            else:
              raise Exception('unknown command name: ' + str(cmd_token))
        else:
          raise Exception('unsupported scm name: ' + str(scm_token))

    for dirpath, dirs, files in os.walk(configure_dir):
      for dir in dirs:
        # ignore directories beginning by '.'
        if str(dir)[0:1] == '.':
          continue
        # ignore common directories
        if str(dir) in ['_common']:
          continue
        ## ignore directories w/o config.vars.in and config.yaml.in files
        #if not (os.path.isfile(os.path.join(dirpath, dir, 'config.vars.in')) and
        #   os.path.isfile(os.path.join(dirpath, dir, 'config.yaml.in'))):
        #  continue
        if os.path.isfile(os.path.join(dirpath, dir, 'config.yaml.in')):
          cmdop(os.path.join(dirpath, dir).replace('\\', '/'), scm_token, cmd_token, bare_args)
      dirs.clear() # not recursively

    if yaml_environ_vars_pushed:
      # remove previously added variables and restore previously changed variable values
      yaml_pop_environ_vars(True)

    if yaml_global_vars_pushed:
      # remove previously added variables and restore previously changed variable values
      yaml_pop_global_vars(True)

  return ret

def on_main_exit():
  if len(g_registered_ignored_errors) > 0:
    print('- Registered ignored errors:')
    for registered_ignored_error in g_registered_ignored_errors:
      print(registered_ignored_error[0])
      print(registered_ignored_error[1])
      print('---')

def main(configure_root, configure_dir, scm_token, cmd_token, bare_args, subtrees_root = None, root_only = False, reset_hard = False):
  with tkl.OnExit(on_main_exit):
    configure_relpath = os.path.relpath(configure_dir, configure_root).replace('\\', '/')
    configure_relpath_comps = configure_relpath.split('/')
    num_comps = len(configure_relpath_comps)

    # load `config.yaml` from `configure_root` up to `configure_dir` (excluded) directory
    if num_comps > 1:
      if os.path.exists(configure_root + '/config.yaml.in'):
        yaml_load_config(configure_root, 'config.yaml', to_globals = True, to_environ = False,
          search_by_global_pred_at_third = lambda var_name: getglobalvar(var_name))
      for i in range(num_comps-1):
        configure_parent_dir = os.path.join(configure_root, *configure_relpath_comps[:i+1]).replace('\\', '/')
        if os.path.exists(configure_parent_dir + '/config.yaml.in'):
          yaml_load_config(configure_parent_dir, 'config.yaml', to_globals = True, to_environ = False,
            search_by_global_pred_at_third = lambda var_name: getglobalvar(var_name))

    # load `config.env.yaml` from `configure_root` up to `configure_dir` (excluded) directory
    if num_comps > 1:
      if os.path.exists(configure_root + '/config.env.yaml.in'):
        yaml_load_config(configure_root, 'config.env.yaml', to_globals = False, to_environ = True,
          search_by_environ_pred_at_third = lambda var_name: getglobalvar(var_name))
      for i in range(num_comps-1):
        configure_parent_dir = os.path.join(configure_root, *configure_relpath_comps[:i+1]).replace('\\', '/')
        if os.path.exists(configure_parent_dir + '/config.env.yaml.in'):
          yaml_load_config(configure_parent_dir, 'config.env.yaml', to_globals = False, to_environ = True,
            search_by_environ_pred_at_third = lambda var_name: getglobalvar(var_name))

    cmdop(configure_dir, scm_token, cmd_token, bare_args,
      subtrees_root = subtrees_root,
      root_only = root_only,
      reset_hard = reset_hard)

# CAUTION:
#   Temporary disabled because of issues in the python xonsh module.
#   See details in the `README_EN.known_issues.txt` file.
#
#@(pcall, main, CONFIGURE_ROOT, CONFIGURE_DIR, SCM_TOKEN, CMD_TOKEN) | @(CONTOOLS_ROOT + '/wtee.exe', CONFIGURE_DIR + '/.log/' + os.path.splitext(os.path.split(__file__)[1])[0] + '.' + datetime.now().strftime("%Y'%m'%d_%H'%M'%S''%f")[:-3])

# NOTE:
#   Logging is implemented externally to the python.
#
if __name__ == '__main__':
  # parse arguments
  arg_parser = argparse.ArgumentParser()
  arg_parser.add_argument('-R', type = str)                       # custom subtree root directory (path)
  arg_parser.add_argument('-ro', action = 'store_true')           # invoke for the root record only (boolean)
  arg_parser.add_argument('--reset_hard', action = 'store_true')  # use `git reset ...` call with the `--hard` parameter (boolean)
  known_args, unknown_args = arg_parser.parse_known_args(sys.argv[4:])

  main(CONFIGURE_ROOT, CONFIGURE_DIR, SCM_TOKEN, CMD_TOKEN, unknown_args,
    subtrees_root = known_args.R,
    root_only = (True if known_args.ro else False),
    reset_hard = (True if known_args.reset_hard else False))
