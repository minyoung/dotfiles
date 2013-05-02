#!/usr/bin/env python

import collections
import os
import sqlite3
import sys
from time import time
from texttable import Texttable


DB_PATH = os.path.expanduser('~/bin/Data/count-commands/commands.sqlite3')
TIMESTAMP = int(time() - 1000 * 60 * 60 * 24 * 7 * 4 * 6)


def execute_scalar(db, query, *args):
    return db.execute(query, args).fetchone()[0]


def normalize_user_string(command):
    return ' '.join(command.split())


def top(db):
    count_query = '''
    SELECT count(*)
    FROM commands
    WHERE
        timestamp > ?
    '''
    percentage = 100 / float(execute_scalar(db, count_query, TIMESTAMP))

    query = '''
    SELECT count(*) AS counts, command
    FROM commands
    WHERE timestamp > ?
    GROUP BY command
    ORDER BY counts DESC
    LIMIT 20
    '''

    table = Texttable()
    table.set_deco(Texttable.HEADER)
    table.set_cols_align(('r', 'r', 'l'))
    table.header(('count', '%', 'command'))
    for row in db.execute(query, (TIMESTAMP,)):
        table.add_row((row[0], int(row[0]) * percentage, row[1]))
    print table.draw()


def sub(db, command, *filters):
    counts = collections.defaultdict(int)
    user_filter = '%s %s' % (command, ' '.join(filters))
    total = 0

    query = '''
    SELECT user_string
    FROM commands
    WHERE
        timestamp > ?
        AND command = ?
    '''

    for row in db.execute(query, (TIMESTAMP, command)):
        command = normalize_user_string(row[0])
        if command.startswith(user_filter):
            counts[command] += 1
            total += 1
    percentage = 100 / float(total)

    table = Texttable()
    table.set_deco(Texttable.HEADER)
    table.set_cols_align(('r', 'r', 'l'))
    table.set_cols_width((5, 6, 75))
    table.header(('count', '%', 'command'))
    for key, value in sorted(counts.iteritems(), key=lambda (k, v): (v, k), reverse=True)[:20]:
        table.add_row((value, value * percentage, key))
    print table.draw()


def main(args):
    command = 'sub' if args else 'top'
    if not os.path.exists(DB_PATH):
        print 'Commands database does not exist: %s' % DB_PATH
        sys.exit(1)
    db = sqlite3.connect(DB_PATH)
    globals()[command](db, *args)


if __name__ == '__main__':
    main(sys.argv[1:])
