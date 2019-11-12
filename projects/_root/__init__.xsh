import os

# auto export these globals to all child modules
tkl_declare_global('CONFIGURE_ROOT', SOURCE_DIR)
tkl_declare_global('CONTOOLS_ROOT', os.environ['CONTOOLS_ROOT'])
tkl_declare_global('TACKLELIB_ROOT', os.environ['TACKLELIB_ROOT'])
tkl_declare_global('CMDOPLIB_ROOT', os.environ['CMDOPLIB_ROOT'])

tkl_declare_global('LOCAL_CACHE_ROOT', CONFIGURE_ROOT + '/_cache')

tkl_declare_global('PYTHON_EXE_PATH', os.environ['PYTHON_EXE_PATH'])
tkl_declare_global('PYTHON_EXE_FILE_NAME', os.path.basename(PYTHON_EXE_PATH))

tkl_source_module(CMDOPLIB_ROOT, 'cmdoplib.xsh')

yaml_load_config(CONFIGURE_ROOT, 'config.private.yaml')
