import os, sys, inspect, argparse
#from datetime import datetime

SOURCE_FILE = os.path.abspath(inspect.getsourcefile(lambda:0)).replace('\\','/')
SOURCE_DIR = os.path.dirname(SOURCE_FILE)

CONFIGURE_DIR = sys.argv[1].replace('\\', '/') if len(sys.argv) >= 2 else ''
SCM_NAME = sys.argv[2] if len(sys.argv) >= 3 else ''
CMD_NAME = sys.argv[3] if len(sys.argv) >= 4 else ''

# portable import to the global space
sys.path.append(SOURCE_DIR + '/tools/tacklelib')
import tacklelib as tkl
# all functions in the module have has a 'tkl_' prefix, all classes begins by `Tackle`, so we don't need a scope here
tkl.tkl_merge_module(tkl, globals())
# cleanup
tkl = None
sys.path.pop()

### globals ###

# format: [(<header_str>, <stderr_str>), ...]
tkl_declare_global('g_registered_ignored_errors', [], copy_as_reference_in_parent = True) # must be empty list to save the reference

### imports ###

# basic initialization, loads `config.private.yaml`
tkl_source_module(SOURCE_DIR, '__init__.xsh')

tkl_import_module(TACKLELIB_ROOT, 'tacklelib.utils.py', 'tkl')

tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.svn.xsh', 'cmdoplib')
tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.gitsvn.xsh', 'cmdoplib')

if not os.path.isdir(CONFIGURE_ROOT):
  raise Exception('CONFIGURE_ROOT directory does not exist: `{0}`'.format(CONFIGURE_ROOT))

if not os.path.isdir(CONFIGURE_DIR):
  raise Exception('CONFIGURE_DIR directory does not exist: `{0}`'.format(CONFIGURE_DIR))

if not SCM_NAME:
  raise Exception('SCM_NAME name is not defined: `{0}`'.format(SCM_NAME))
if not CMD_NAME:
  raise Exception('CMD_NAME name is not defined: `{0}`'.format(CMD_NAME))

#try:
#  os.mkdir(os.path.join(CONFIGURE_DIR, '.log'))
#except:
#  pass

def cmdop(configure_dir, scm_name, cmd_name, bare_args, subtrees_root = None, root_only = False, reset_hard = False):
  print(">cmdop: {0} {1}: entering `{2}`".format(scm_name, cmd_name, configure_dir))

  with tkl.OnExit(lambda: print(">cmdop: {0} {1}: leaving `{2}`\n---".format(scm_name, cmd_name, configure_dir))):
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

    hab_root_var = scm_name + '.HUB_ROOT'
    if not hasglobalvar(hab_root_var):
      print_err("{0}: error: hub root variable is not declared for the scm_name as prefix: `{1}`.".format(sys.argv[0], hab_root_var))
      exit(3)

    # loads `config.yaml` from `configure_dir`
    yaml_global_vars_pushed = False
    if os.path.isfile(configure_dir + '/config.yaml.in'):
      # save all old variable values and remember all newly added variables as a new stack record
      yaml_push_global_vars()
      yaml_global_vars_pushed = True
      yaml_load_config(configure_dir, 'config.yaml', to_globals = True, to_environ = False)

    # loads `config.env.yaml` from `configure_dir`
    yaml_environ_vars_pushed = False
    if os.path.isfile(configure_dir + '/config.env.yaml.in'):
      # save all old variable values and remember all newly added variables as a new stack record
      yaml_push_environ_vars()
      yaml_environ_vars_pushed = True
      yaml_load_config(configure_dir, 'config.env.yaml', to_globals = False, to_environ = True)

    is_leaf_configure_dir = True
    ret = 0

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
        if os.path.isfile(os.path.join(dirpath, dir, 'config.yaml')):
          ret = cmdop(os.path.join(dirpath, dir).replace('\\', '/'), scm_name, cmd_name, bare_args)
        is_leaf_configure_dir = False
      dirs.clear() # not recursively

    # do action only in a leaf configure_dir
    if is_leaf_configure_dir:
      if scm_name[:3] == 'SVN':
        if hasglobalvar(scm_name + '.WCROOT_DIR'):
          if cmd_name == 'update':
            ret = cmdoplib.svn_update(configure_dir, scm_name, bare_args)
          elif cmd_name == 'checkout':
            ret = cmdoplib.svn_checkout(configure_dir, scm_name, bare_args)
          elif cmd_name == 'relocate':
            ret = cmdoplib.svn_relocate(configure_dir, scm_name, bare_args)
          else:
            raise Exception('unknown command name: ' + str(cmd_name))
      elif scm_name[:3] == 'GIT':
        if hasglobalvar(scm_name + '.WCROOT_DIR'):
          if cmd_name == 'init':
            ret = cmdoplib.git_init(configure_dir, scm_name,
              subtrees_root = subtrees_root, root_only = root_only)
          elif cmd_name == 'fetch':
            ret = cmdoplib.git_fetch(configure_dir, scm_name,
              subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
          elif cmd_name == 'reset':
            ret = cmdoplib.git_reset(configure_dir, scm_name,
              subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
          elif cmd_name == 'pull':
            ret = cmdoplib.git_pull(configure_dir, scm_name,
              subtrees_root = subtrees_root, root_only = root_only, reset_hard = reset_hard)
          elif cmd_name == 'push_svn_to_git':
            ret = cmdoplib.git_push_from_svn(configure_dir, scm_name,
              subtrees_root = subtrees_root, reset_hard = reset_hard)
          else:
            raise Exception('unknown command name: ' + str(cmd_name))
      else:
        raise Exception('unsupported scm name: ' + str(scm_name))

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

def main(configure_root, configure_dir, scm_name, cmd_name, bare_args, subtrees_root = None, root_only = False, reset_hard = False):
  with tkl.OnExit(on_main_exit):
    configure_relpath = os.path.relpath(configure_dir, configure_root).replace('\\', '/')
    configure_relpath_comps = configure_relpath.split('/')
    num_comps = len(configure_relpath_comps)

    # load `config.yaml` from `configure_root` up to `configure_dir` (excluded) directory
    if num_comps > 1:
      for i in range(num_comps-1):
        configure_parent_dir = os.path.join(configure_root, *configure_relpath_comps[:i+1]).replace('\\', '/')
        if os.path.exists(configure_parent_dir + '/config.yaml.in'):
          yaml_load_config(configure_parent_dir, 'config.yaml', to_globals = True, to_environ = False)

    # load `config.env.yaml` from `configure_root` up to `configure_dir` (excluded) directory
    if num_comps > 1:
      for i in range(num_comps-1):
        configure_parent_dir = os.path.join(configure_root, *configure_relpath_comps[:i+1]).replace('\\', '/')
        if os.path.exists(configure_parent_dir + '/config.env.yaml.in'):
          yaml_load_config(configure_parent_dir, 'config.env.yaml', to_globals = False, to_environ = True)

    cmdop(configure_dir, scm_name, cmd_name, bare_args,
      subtrees_root = subtrees_root,
      root_only = root_only,
      reset_hard = reset_hard)

# CAUTION:
#   Temporary disabled because of issues in the python xonsh module.
#   See details in the `README_EN.known_issues.txt` file.
#
#@(pcall, main, CONFIGURE_ROOT, CONFIGURE_DIR, SCM_NAME, CMD_NAME) | @(CONTOOLS_ROOT + '/wtee.exe', CONFIGURE_DIR + '/.log/' + os.path.splitext(os.path.split(__file__)[1])[0] + '.' + datetime.now().strftime("%Y'%m'%d_%H'%M'%S''%f")[:-3])

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

  main(CONFIGURE_ROOT, CONFIGURE_DIR, SCM_NAME, CMD_NAME, unknown_args,
    subtrees_root = known_args.R,
    root_only = (True if known_args.ro else False),
    reset_hard = (True if known_args.reset_hard else False))
