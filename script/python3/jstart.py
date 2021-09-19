#!/usr/bin/env python
#
# Using:
# - https://stackoverflow.com/questions/26338688/start-ipython-notebook-with-python-file
# - https://stackoverflow.com/questions/35229604/how-to-change-the-default-browser-used-by-the-ipython-jupyter-notebook-in-linux
import sys
from IPython.terminal.ipapp import launch_new_instance
from IPython.lib import passwd
from socket import gethostname
import warnings
import os
warnings.filterwarnings("ignore", module = "zmq.*")
os.chdir(os.environ['HOME'] + os.sep + 'notebook')
sys.argv.append("notebook")
sys.argv.append("--IPKernelApp.pylab='inline'")
#sys.argv.append("--NotebookApp.ip=" + gethostname())
sys.argv.append("--NotebookApp.open_browser=True")
#osys.argv.append("--NotebookApp.password=" + passwd())
#sys.argv.append("--NotebookApp.browser='/usr/bin/firefox -private -P private -no-remote %s'")
sys.argv.append("--NotebookApp.browser='/usr/bin/firefox -private -P private -no-remote %s'")
launch_new_instance()
