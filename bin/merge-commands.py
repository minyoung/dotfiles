#!/usr/bin/env python

from __future__ import print_function

import argparse
import sqlite3
import sys

def merge_commands(args, src):
    dest_db = sqlite3.connect(args.dest, timeout=0.3)
    src_db = sqlite3.connect(src, timeout=0.3)
    src_db.row_factory = sqlite3.Row

    if args.prune_hosts:
        for row in src_db.execute('SELECT DISTINCT hostname FROM commands'):
            print('deleting commands for host: %r' % row['hostname'])
            dest_db.execute('DELETE FROM commands WHERE hostname = ?', [row['hostname']])

    columns = [
        'uuid',
        'hostname',
        'timestamp',
        'duration',
        'command',
        'user_string',
        'expanded_string',
    ]
    insert = '''
        INSERT INTO commands (%s)
        VALUES (%s)
        ON CONFLICT(uuid) DO UPDATE SET %s
    ''' % (
        ','.join(columns),
        ','.join('?' for _ in columns),
        ','.join('%s=excluded.%s' % (c, c) for c in columns[1:]),
    )
    count = 0
    for row in src_db.execute('SELECT * FROM commands'):
        dest_db.execute(insert, [row[c] for c in columns])
        count += 1
        if count % 100 == 0:
            print('.', end='')
            sys.stdout.flush()

    if args.pretend:
        dest_db.rollback()
    else:
        dest_db.commit()
    print('\nimported %d rows' % count)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('dest', help='sqlite3 database to merge into')
    parser.add_argument('srcs', help='sqlite3 databases to merge', nargs='+')
    parser.add_argument(
        '--prune-hosts',
        help='delete all rows with overlapping hostnames',
        action='store_true',
    )
    parser.add_argument('--pretend', help='do not commit changes', action='store_true')
    args = parser.parse_args()
    for src in args.srcs:
        merge_commands(args, src)
