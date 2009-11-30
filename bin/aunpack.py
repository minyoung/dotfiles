#!/usr/bin/env python

import sys
import os
arglen = len(sys.argv)
if arglen < 2:
    print "extract ARCHIVE"
    print "usage: %s ARCHIVE [OPTIONS]" %(os.path.basename(sys.argv[0]))
    print "OPTIONS:"
    print "-d DESTDIR : specify destination directory for contents"
    sys.exit(0)

if not os.path.isfile(sys.argv[1]):
    print "%s is not a file" %sys.argv[1]
    sys.exit(1)


DESTDIR = '.'
#parse options
i = 2
while i < arglen:
    opt = sys.argv[i]
    if opt == '-d':
        if arglen <= i + 1: #+1 for argv[0]
            print "destination directory not specified"
            print "ignoring option"
        else:
            DESTDIR = sys.argv[i+1]
            if not os.path.isdir(DESTDIR):
                if os.path.exists(DESTDIR):
                    print "specified destination directory exists"
                    print "ignoring option"
                    DESTDIR = '.'
                else:
                    try:
                        os.mkdir(DESTDIR, 0755)
                    except OSError:
                        print "cannot create destination directory"
                        print "failing"
                        sys.exit(2)
            #+1 to skip for destination directory
            i += 1
    i += 1


import subprocess
def pipe_tar(args):
    process = subprocess.Popen(args, stdout=subprocess.PIPE)
    tar = subprocess.Popen(['tar', 'xf', '-', '-C', DESTDIR], stdin=process.stdout)
    tar.communicate()

ARCHIVE = sys.argv[1]
if ARCHIVE.endswith('.tar.gz') or ARCHIVE.endswith('.tgz'):
    subprocess.call(['tar', 'xzf', ARCHIVE, '-C', DESTDIR])
elif ARCHIVE.endswith('.gz'):
    subprocess.call(['gunzip', ARCHIVE])

elif ARCHIVE.endswith('.tar.bz2') or ARCHIVE.endswith('.tbz2'):
    subprocess.call(['tar', 'xjf', ARCHIVE, '-C', DESTDIR])
elif ARCHIVE.endswith('.bz2'):
    subprocess.call(['bunzip2', ARCHIVE])

elif ARCHIVE.endswith('.tar.lzma') or ARCHIVE.endswith('.tlz'):
    #subprocess.call(['tar', 'xaf', ARCHIVE, '-C', DESTDIR])
    pipe_tar(['lzma', '-cd', ARCHIVE])
elif ARCHIVE.endswith('.lzma'):
    subprocess.call(['lzma', '-d', ARCHIVE])

elif ARCHIVE.endswith('.tar.7z'):
    pipe_tar(['7za', 'x', '-so', ARCHIVE])
elif ARCHIVE.endswith('.7z'):
    subprocess.call(['7za', 'x', ARCHIVE, '-o%s' %DESTDIR])

elif ARCHIVE.endswith('.tar.zip'):
    pipe_tar(['unzip', '-p', ARCHIVE])
elif ARCHIVE.endswith('.zip'):
    subprocess.call(['unzip', ARCHIVE, '-d', DESTDIR])

elif ARCHIVE.endswith('.rar'):
    subprocess.call(['unrar', 'x', ARCHIVE, DESTDIR])

