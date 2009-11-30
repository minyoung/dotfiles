#!/usr/bin/env python

import sys
import os
arglen = len(sys.argv)
if arglen < 2:
    print "list the contents of ARCHIVE"
    print "usage: %s ARCHIVE" %(os.path.basename(sys.argv[0]))
    sys.exit(0)

if not os.path.isfile(sys.argv[1]):
    print "%s is not a file" %sys.argv[1]
    sys.exit(1)


import subprocess
def pipe_tar(args):
    process = subprocess.Popen(args, stdout=subprocess.PIPE)
    tar = subprocess.Popen(['tar', 'tvf', '-'], stdin=process.stdout)
    tar.communicate()


ARCHIVE = sys.argv[1]
if ARCHIVE.endswith('.tar.gz') or ARCHIVE.endswith('.tgz'):
    subprocess.call(['tar', 'tvzf', ARCHIVE])
elif ARCHIVE.endswith('.gz'):
    subprocess.call(['gzip', 'l', ARCHIVE])

elif ARCHIVE.endswith('.tar.bz2') or ARCHIVE.endswith('.tbz2'):
    subprocess.call(['tar', 'tvjf', ARCHIVE])

elif ARCHIVE.endswith('.tar.lzma') or ARCHIVE.endswith('.tlz'):
    #subprocess.call(['tar', 'taf', ARCHIVE, '-C', DESTDIR])
    pipe_tar(['lzma', '-cd', ARCHIVE])

elif ARCHIVE.endswith('.tar.7z'):
    pipe_tar(['7za', 'x', '-so', ARCHIVE])
elif ARCHIVE.endswith('.7z'):
    subprocess.call(['7za', 'l', ARCHIVE])

elif ARCHIVE.endswith('.tar.zip'):
    pipe_tar(['unzip', '-p', ARCHIVE])
elif ARCHIVE.endswith('.zip'):
    subprocess.call(['unzip', '-l', ARCHIVE])

elif ARCHIVE.endswith('.rar'):
    subprocess.call(['unrar', 'l', ARCHIVE])

