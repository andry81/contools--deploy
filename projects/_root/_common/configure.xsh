import sys, os, shutil, inspect
#from datetime import datetime

SOURCE_FILE = os.path.abspath(inspect.getsourcefile(lambda:0)).replace('\\','/')
SOURCE_DIR = os.path.dirname(SOURCE_FILE)

CONFIGURE_DIR = sys.argv[1].replace('\\', '/') if len(sys.argv) >= 2 else ''

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

if not os.path.isdir(CONFIGURE_ROOT):
  raise Exception('CONFIGURE_ROOT directory does not exist: `{0}`'.format(CONFIGURE_ROOT))

if not os.path.isdir(CONFIGURE_DIR):
  raise Exception('CONFIGURE_DIR directory does not exist: `{0}`'.format(CONFIGURE_DIR))

#try:
#  os.mkdir(os.path.join(CONFIGURE_DIR, '.log'))
#except:
#  pass

def configure(configure_dir):
  print(">configure: {0}".format(configure_dir))

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    exit(1)

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    exit(2)

  try:
    if os.path.isfile(os.path.join(configure_dir, 'git_repos.lst.in')):
      shutil.copyfile(os.path.join(configure_dir, 'git_repos.lst.in'), os.path.join(configure_dir, 'git_repos.lst')),
  except:
    # `exit` with the parentheses to workaround the issue:
    # `source` xsh file with try/except does hang`:
    # https://github.com/xonsh/xonsh/issues/3301
    exit(255)

  try:
    if os.path.isfile(os.path.join(configure_dir, 'config.yaml.in')):
      shutil.copyfile(os.path.join(configure_dir, 'config.yaml.in'), os.path.join(configure_dir, 'config.yaml')),
  except:
    # `exit` with the parentheses to workaround the issue:
    # `source` xsh file with try/except does hang`:
    # https://github.com/xonsh/xonsh/issues/3301
    exit(255)

  # loads `config.yaml` from `configure_dir`
  if os.path.isfile(os.path.join(configure_dir, 'config.yaml')):
    yaml_load_config(configure_dir, 'config.yaml')

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
        configure(os.path.join(dirpath, dir).replace('\\', '/'))
    dirs.clear() # not recursively

def main(configure_root, configure_dir):
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

  configure(configure_dir)

# CAUTION:
#   Temporary disabled because of issues in the python xonsh module.
#   See details in the `README_EN.known_issues.txt` file.
#
#@(pcall, main, CONFIGURE_ROOT, CONFIGURE_DIR) | @(CONTOOLS_ROOT + '/wtee.exe', CONFIGURE_DIR + '/.log/' + os.path.splitext(os.path.split(__file__)[1])[0] + '.' + datetime.now().strftime("%Y'%m'%d_%H'%M'%S''%f")[:-3])

# NOTE:
#   Logging is implemented externally to the python.
#
if __name__ == '__main__':
  main(CONFIGURE_ROOT, CONFIGURE_DIR)
