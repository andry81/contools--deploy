import os, sys, inspect
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

# basic initialization, loads `config.private.yaml`
tkl_source_module(SOURCE_DIR, '__init__.xsh')

tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.svn.xsh', 'cmdoplib')
tkl_import_module(CMDOPLIB_ROOT, 'cmdoplib.git.xsh', 'cmdoplib')

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

def cmdop(configure_dir, scm_name, cmd_name):
  print(">cmdop: {0}, {1}".format(scm_name, cmd_name))

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    exit(1)

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    exit(2)

  # loads `config.yaml` from `configure_dir`
  yaml_global_vars_pushed = False
  if os.path.isfile(os.path.join(configure_dir, 'config.yaml')):
    # save all old variable values and remember all newly added variables as a new stack record
    yaml_push_global_vars()
    yaml_global_vars_pushed = True
    yaml_load_config(configure_dir, 'config.yaml')

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
        ret = cmdop(os.path.join(dirpath, dir), scm_name, cmd_name)
      is_leaf_configure_dir = False
    dirs.clear() # not recursively

  # do action only in a leaf configure_dir
  if is_leaf_configure_dir:
    if scm_name[:3] == 'SVN':
      if cmd_name == 'update':
        ret = cmdoplib.svn_update(configure_dir, scm_name)
      elif cmd_name == 'checkout':
        ret = cmdoplib.svn_checkout(configure_dir, scm_name)
      else:
        raise Exception('unknown command name: ' + str(cmd_name))
    elif scm_name[:3] == 'GIT':
      if cmd_name == 'init':
        ret = cmdoplib.git_init(configure_dir, scm_name)
      elif cmd_name == 'pull':
        ret = cmdoplib.git_pull(configure_dir, scm_name)
      #elif cmd_name == 'reset':
      #  ret = cmdoplib.git_reset(configure_dir, scm_name)
      #elif cmd_name == 'sync_svn_to_git':
      #  ret = cmdoplib.git_sync_from_svn(configure_dir, scm_name)
      else:
        raise Exception('unknown command name: ' + str(cmd_name))
    else:
      raise Exception('unsupported scm name: ' + str(scm_name))

  if yaml_global_vars_pushed:
    # remove previously added variables and restore previously changed variable values
    yaml_pop_global_vars(True)

  return ret

def main(configure_root, configure_dir, scm_name, cmd_name):
  # load `config.yaml` from `configure_root` up to `configure_dir` (excluded) directory
  configure_relpath = os.path.relpath(configure_dir, configure_root).replace('\\', '/')
  configure_relpath_comps = configure_relpath.split('/')
  num_comps = len(configure_relpath_comps)
  if num_comps > 0:
    yaml_load_config(configure_root, 'config.yaml')
  if num_comps > 1:
    for i in range(num_comps-1):
      configure_parent_dir = os.path.join(configure_root, *configure_relpath_comps[:i+1]).replace('\\', '/')
      yaml_load_config(configure_parent_dir, 'config.yaml')

  cmdop(configure_dir, scm_name, cmd_name)

# CAUTION:
#   Temporary disabled because of issues in the python xonsh module.
#   See details in the `README_EN.known_issues.txt` file.
#
#@(pcall, main, CONFIGURE_ROOT, CONFIGURE_DIR, SCM_NAME, CMD_NAME) | @(CONTOOLS_ROOT + '/wtee.exe', CONFIGURE_DIR + '/.log/' + os.path.splitext(os.path.split(__file__)[1])[0] + '.' + datetime.now().strftime("%Y'%m'%d_%H'%M'%S''%f")[:-3])

# NOTE:
#   Logging is implemented externally to the python.
#
if __name__ == '__main__':
  main(CONFIGURE_ROOT, CONFIGURE_DIR, SCM_NAME, CMD_NAME)