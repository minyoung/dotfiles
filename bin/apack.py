#!/usr/bin/env python

import sys
import os
arglen = len(sys.argv)
if arglen < 2:
    print "archive FILES into ARCHIVE"
    print "usage: %s ARCHIVE [FILES...]" %(os.path.basename(sys.argv[0]))
    sys.exit(0)

if os.path.exists(sys.argv[1]):
    print "%s already exists!" %sys.argv[1]
    print "doing nothing"
    sys.exit(1)

if arglen < 3:
    print "no files to process"
    print "doing nothing"
    sys.exit(1)


import subprocess
def pipe_tar(args, files):
    tar = subprocess.Popen(['tar', 'cf', '-'] + files, stdout=subprocess.PIPE)
    process = subprocess.Popen(args, stdin=tar.stdout)
    process.communicate()

ARCHIVE = sys.argv[1]
if ARCHIVE.endswith('.tar.gz') or ARCHIVE.endswith('.tgz'):
    subprocess.call(['tar', 'czf', ARCHIVE] + sys.argv[2:])
elif ARCHIVE.endswith('.gz'):
    subprocess.call(['gzip', sys.argv[2]])

elif ARCHIVE.endswith('.tar.bz2') or ARCHIVE.endswith('.tbz2'):
    subprocess.call(['tar', 'cjf', ARCHIVE] + sys.argv[2:])
elif ARCHIVE.endswith('.bz2'):
    subprocess.call(['bzip2', sys.argv[2]])

elif ARCHIVE.endswith('.tar.lzma') or ARCHIVE.endswith('.tlz'):
    subprocess.call(['tar', 'caf', ARCHIVE] + sys.argv[2:])
elif ARCHIVE.endswith('.lzma'):
    subprocess.call(['lzma', '-z', ARCHIVE, sys.arg[2]])

elif ARCHIVE.endswith('.tar.7z'):
    pipe_tar(['7za', 'a', '-si', ARCHIVE], sys.argv[2:])
elif ARCHIVE.endswith('.7z'):
    subprocess.call(['7za', 'a', ARCHIVE] + sys.argv[2:])

elif ARCHIVE.endswith('.tar.zip'):
    pipe_tar(['zip', ARCHIVE, '-'], sys.argv[2:])
elif ARCHIVE.endswith('.zip'):
    subprocess.call(['zip', '-r', ARCHIVE] + sys.argv[2:])

elif ARCHIVE.endswith('.rar'):
    subprocess.call(['rar', 'a', '-r', ARCHIVE] + sys.argv[2:])

