#!/usr/bin/python
import os
import sys

os.system("chkconfig --list")
os.system("grep error /var/log/boot.log")