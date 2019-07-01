import sys
import cmdix

# error print
def print_err(*args, **kwargs):
  print(*args, file=sys.stderr, **kwargs)

# call from pipe
def pcall(args):
  args.pop(0)(*args)

# /dev/null (Linux) or nul (Windows) replacement
def pnull(args, stdin=None):
  for line in stdin:
    pass
