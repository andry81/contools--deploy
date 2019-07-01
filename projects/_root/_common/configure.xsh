import sys, os, shutil, time
from datetime import datetime

CONFIGURE_DIR = sys.argv[1].replace('\\', '/')

CONTOOLS_ROOT = os.environ['CONTOOLS_ROOT'].replace('\\', '/')
BASE_SCRIPTS_ROOT = os.environ['BASE_SCRIPTS_ROOT'].replace('\\', '/')

evalx('source ' + BASE_SCRIPTS_ROOT + '/cmdoplib.xsh')

def configure(configure_dir):
  print(">configure:", configure_dir)
  if configure_dir == "":
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    exit 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    exit 2

  try:
    if os.path.isfile(configure_dir + '/config.yaml.in'):
      shutil.copyfile(configure_dir + '/config.yaml.in', configure_dir + '/config.yaml')
  except:
    exit 255

  try:
    if os.path.isfile(configure_dir + '/repos.lst.in'):
      shutil.copyfile(configure_dir + '/repos.lst.in', configure_dir + '/repos.lst')
  except:
    exit 255

  for dirpath, dirs, files in os.walk(configure_dir):
    for dir in dirs:
      # ignore directories beginning by '.'
      if str(dir)[0:1] == '.':
        pass
      # ignore directories w/o config.vars.in and config.yaml.in files
      if not (os.path.isfile(os.path.join(dirpath, dir, 'config.vars.in')) and
         os.path.isfile(os.path.join(dirpath, dir, 'config.yaml.in'))):
        pass
      if os.path.isfile(os.path.join(dirpath, dir, 'configure.bat')):
        configure(os.path.join(dirpath, dir))
    dirs.clear() # not recursively

if not os.path.isdir(CONFIGURE_DIR + '/.log'):
  os.mkdir(CONFIGURE_DIR + '/.log')

# CAUTION:
#   Temporary disabled because of issues in the python xonsh module.
#   See details in the `README_EN.known_issues.txt` file.
#
#@(pcall, configure, CONFIGURE_DIR) | @(CONTOOLS_ROOT + '/wtee.exe', CONFIGURE_DIR + '/.log/' + os.path.splitext(os.path.split(__file__)[1])[0] + '.' + datetime.now().strftime("%Y'%m'%d_%H'%M'%S''%f")[:-3])

# NOTE:
#   Logging is implemented exter nally to the python.
#
configure(CONFIGURE_DIR)
