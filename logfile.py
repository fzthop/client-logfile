#!/usr/bin/python
import os
import sys

Path = os.path.exists('/root/log')

#print Path

if Path == False:
    #print Path
    os.mkdir("/root/log")
    
Logfile = os.path.isfile('/root/log/logfile.sh')
#print Logfile

if Logfile == False:
    print "The file logfile.sh is not exists!"
    #os.abort()
    sys.exit(1)

#exec script logfile.sh
n = os.system("/root/log/logfile.sh") 
n = n >> 8
if n != 3:
    print "There is something rong to exec the script logfile.sh!"
    sys.exit(2)

#read logfile
if os.getcwd()!='/root/log':
    os.chdir('/root/log')

logfile = os.path.isfile('/root/log/logfile')
if logfile == False:
    print "File logfile is not exists!"
    sys.exit(3)

f = open('logfile', 'r')
try:
    #list_of_line = f.readline()
    for line in f:
        print line
finally:
    f.close()

#print "End!"
