#!/usr/bin/env python

import os
import re
import sys

PRETEND = False
OVERWRITE_INPUT_FILE = False
USE_BACKUP_FILE = False


BADD_REGEX = re.compile(r'^badd \+\d+ (.+)$')

class NullObject(object):
    '''This will swallow *everything*'''
    def __call__(self, *args, **kwargs):
        return self

    def __getattr__(self, name):
        return self


def cleanup_file(filename):
    print '= Cleaning up: %s =' % filename
    removed_count = 0
    if PRETEND:
        output_file = NullObject()
    else:
        output_file = open(filename + '.out', 'w')

    for line in open(filename, 'r'):
        matches = BADD_REGEX.match(line)
        buffer_name = matches and matches.groups()[0]
        if buffer_name:
            if not os.path.exists(os.path.expanduser(buffer_name)):
                print 'Removing %s' % buffer_name
                removed_count += 1
                continue
        output_file.write(line)
    output_file.close()

    if not PRETEND and OVERWRITE_INPUT_FILE:
        if USE_BACKUP_FILE:
            backup_filename = '%s/.%s.backup' % os.path.split(filename)
            print 'Saving old file to: %s' % backup_filename
            backup_filename = os.path.expanduser(backup_filename)
            if os.path.exists(backup_filename):
                os.remove(backup_filename)
            os.rename(filename, backup_filename)
        else:
            os.remove(filename)
        os.rename(filename + '.out', filename)
    print 'Removed %d lines\n' % removed_count


def main(args):
    if not args:
        print 'Give me some files to work with!'
        sys.exit(0)
    for filename in args:
        cleanup_file(filename)

if __name__ == '__main__':
    main(sys.argv[1:])
