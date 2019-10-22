# python module for commands with extension modules usage: tacklelib, plumbum

import os, sys, time, datetime
from plumbum import local

tkl_source_module(SOURCE_DIR, 'cmdoplib.std.xsh')
tkl_source_module(SOURCE_DIR, 'cmdoplib.csvsvn.xsh')

def get_svn_log_list(wcpath, depth = 1, from_rev = None, to_rev = None):
  rev_list = []

  if from_rev is None:
    if str(to_rev) == '0':
      from_rev = 'HEAD'
    else:
      from_rev = 0
  if to_rev is None:
    if str(from_rev) == 'HEAD':
      to_rev = 0
    else:
      to_rev = 'HEAD'

  ret = call_no_except('svn', ['log', '-q', '-l', str(depth), '-r', str(from_rev) + ':' + str(to_rev), wcpath], stdout = None, stderr = None)

  stdout_lines = ret[1]
  stderr_lines = ret[2]

  with SvnLogListReader(stdout_lines) as svn_log_reader:
    for row in svn_log_reader:
      svn_rev = row['rev']
      if svn_rev[:1] == 'r':
        svn_rev = svn_rev[1:].rstrip()
        svn_user_name = row['user_name'].rstrip()
        svn_time_date = row['time_date']
        found_index = svn_time_date.find('(')
        if found_index >= 0:
          svn_time_date = svn_time_date[:found_index]
        svn_time_date = svn_time_date.rstrip()

        svn_timestamp = int(time.mktime(datetime.datetime.strptime(svn_time_date, '%Y-%m-%d %H:%M:%S %z').timetuple()))
        rev_list.append((svn_rev, svn_user_name, svn_timestamp, svn_time_date))

  # cut out the middle of the stdout
  num_revs = len(rev_list)
  if num_revs > 7:
    row_index = 0
    for row in rev_list:
      if row_index < 3 or row_index >= num_revs - 3: # excluding the last line return
        print('r{} | {} | {} [{}]'.format(*row))
      elif row_index == 3:
        print('...')
      row_index += 1
  elif num_revs > 0:
    for row in rev_list:
      print('r{} | {} | {} [{}]'.format(*row))
  if len(stderr_lines) > 0:
    print(stderr_lines)

  """
  # To iterate over lines instead chars.
  # (see details: https://stackoverflow.com/questions/3054604/iterate-over-the-lines-of-a-string/3054898#3054898 )
  stdout_lines = io.StringIO(ret[1])
  print(stdout_lines)
  for line in stdout_lines:
    if line[0] == 'r':
      rev_str_end = line.find(' ')
      if rev_str_end >= 0:
        rev_list.append(line[1:rev_str_end])
  """

  return rev_list

def svn_update(configure_dir, scm_name):
  print(">svn update: {0}".format(configure_dir))

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 2

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  print(' -> {0}...'.format(wcroot_path))

  with local.cwd(wcroot_path):
    call('svn', ['up'])

def svn_checkout(configure_dir, scm_name):
  print(">svn checkout: {0}".format(configure_dir))

  if configure_dir == '':
    print_err("{0}: error: configure directory is not defined.".format(sys.argv[0]))
    return 1

  if configure_dir[-1:] in ['\\', '/']:
    configure_dir = configure_dir[:-1]

  if not os.path.isdir(configure_dir):
    print_err("{0}: error: configure directory does not exist: `{1}`.".format(sys.argv[0], configure_dir))
    return 2

  wcroot_dir = getvar(scm_name + '.WCROOT_DIR')
  if wcroot_dir == '': return -254
  if WCROOT_OFFSET == '': return -253

  wcroot_path = os.path.abspath(os.path.join(WCROOT_OFFSET, wcroot_dir)).replace('\\', '/')

  svn_checkout_url = getvar(scm_name + '.CHECKOUT_URL')

  print(' -> {0}...'.format(wcroot_path))

  if not os.path.exists(wcroot_path):
    os.mkdir(wcroot_path)

  if os.path.isdir(wcroot_path + '/.svn'):
    return 0

  call('svn', ['co', svn_checkout_url, wcroot_path])
