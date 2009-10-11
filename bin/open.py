#!/usr/bin/env python

# Basic script to open a file depending on its mime type. Uses xdg-mime to
# determine the mimetype and desktop entry file. The idea is to provide
# functionality like: kfmclient, gnome-open or exo-open.
#
# Basic usage: open.py FILE
#
# This script will determine the mime type, then use that info to determine
# what to use to open the file.
#
#
# How this works:
# 1. Get the file type:
# xdg-mime query filetype FILE
#
# 2. Get the desktop entry filename handling the mime type:
# xdg-mime query default FILETYPE
#
# 3. Use the desktop entry file to determine how to open the file:
# grep DESKTOP_FILE '^Exec='
#
# 4. Open the file using what was specified
#
#
# TODO:
# - interpret Exec key properly in the desktop entry file (field codes)
#   (http://standards.freedesktop.org/desktop-entry-spec/latest/ar01s06.html)
# - handle quoted/escaped args in the Exec line


import os
import re
import subprocess
import sys

def open_file(filename):
    # get the mime type of the file
    p1 = subprocess.Popen(['xdg-mime', 'query', 'filetype', filename], stdout=subprocess.PIPE)
    mimetype = p1.communicate()[0].split(';')[0]
    if not mimetype:
        sys.stderr.write("cannot determine mimetype for '%s'\n" %filename)
        return 1

    # get the .desktop file to use for opening the file
    p2 = subprocess.Popen(['xdg-mime', 'query', 'default', mimetype], stdout=subprocess.PIPE)
    desktopentries = p2.communicate()[0].strip().split(';')
    if not desktopentries:
        sys.stderr.write("unknown handler for mimetype '%s'\n" %mimetype)
        return 2

    # get the data directories (is this correct?)
    entrypaths = [os.environ.get('XDG_DATA_HOME')]
    if entrypaths[0] is None: # default data home correct?
        entrypaths = [os.path.join(os.path.expanduser('~'), '.local/share')]
    entrypaths.extend(os.environ.get('XDG_DATA_DIRS').split(':'))

    arg_regex = re.compile('^%[fFuUdDnNickvm]$')
    for entry in desktopentries:
        for path in entrypaths:
            # find the .desktop file
            desktopfile = os.path.join(path, 'applications', entry)
            if os.path.isfile(desktopfile):
                # grep the file for the Exec line (all that we're interested in)
                g = subprocess.Popen(['grep', '^Exec=', desktopfile], stdout=subprocess.PIPE)
                # should only return one line, but just in case, use the first line
                execline = g.communicate()[0].split('\n')[0]
                # no Exec? Probably an error, but just skip it
                if not execline:
                    continue
                # get rid of the 'Exec=' part of the line
                execline = execline[execline.find('=')+1:]
                # and get the args
                args = []
                # TODO: handle quoted/escaped args
                for a in execline.split():
                    # TODO: properly handle the arguments
                    if arg_regex.match(a):
                        pass
                    else:
                        args.append(a)
                # append the filename as an argument regardless?
                args.append(filename)
                print args
                return subprocess.call(args)
    sys.stderr.write("no method available for opening '%s' (%s)\n" %(filename, mimetype))
    return 3


if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.stderr.write('open.py {file URL}\n')
        sys.exit(1)
    retcode = 0
    for f in sys.argv[1:]:
        ret = open_file(f)
        if ret:
            retcode = ret
    sys.exit(retcode)

