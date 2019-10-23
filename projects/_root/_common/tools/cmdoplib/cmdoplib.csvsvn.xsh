# python module for commands with extension modules usage: tacklelib, csv

import csv

tkl_source_module(SOURCE_DIR, 'cmdoplib.csv.xsh')

class SvnLogListReaderDialect(csv.Dialect):
  delimiter = '|'
  quotechar = '"'
  doublequote = True
  skipinitialspace = True
  lineterminator = '\r\n'
  quoting = csv.QUOTE_MINIMAL

csv.register_dialect('svn_log_q', SvnLogListReaderDialect)

class SvnLogListReader(tkl.CsvListBaseStrReader):
  def __init__(self, str, fieldnames = ['rev', 'user_name', 'date_time'], dialect = 'svn_log_q'):
    tkl.CsvListBaseStrReader.__init__(self, str, fieldnames, dialect)
