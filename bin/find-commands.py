#!/usr/bin/env python

import os
import re
import sqlite3
import sys
import time
from texttable import Texttable


DB_PATH = os.path.expanduser('~/bin/Data/count-commands/commands.sqlite3')
TIMESTAMP = int(time.time() - 60 * 60 * 24 * 7 * 4 * 6)

RE_CACHE = {}

def regexp(expr, item):
    if expr not in RE_CACHE:
        RE_CACHE[expr] = re.compile(expr, re.IGNORECASE)
    return RE_CACHE[expr].search(item) is not None


def highlight(text, regex):
    matches = regex.findall(text)
    betweens = regex.split(text)
    output = []
    output.append(betweens.pop(0))
    while betweens:
        output.append('\033[91m')
        output.append(matches.pop(0))
        output.append('\033[0m')
        output.append(betweens.pop(0))
    return ''.join(output)


def format_duration(duration):
    hours = ''
    if duration > 3600:
        hours = '{0}h '.format(int(duration / 3600))
        duration = duration % 3600

    minutes = ''
    if duration > 60:
        minutes = '{0}m '.format(int(duration / 60))
        duration = duration % 60

    seconds = '{0:.2f}s'.format(duration)

    return hours + minutes + seconds


def format_time(timestamp, now=0):
    if not now:
        now = time.time()
    diff = now - timestamp
    if diff > 7 * 24 * 60 * 60:
        return time.strftime('%c', time.localtime(timestamp))
    if diff > 24 * 60 * 60:
        return '{:.0f} days ago'.format(diff / (24 * 60 * 60))
    if diff > 60 * 60:
        return '{:.0f} hours ago'.format(diff / (60 * 60))
    if diff > 60:
        return '{:.0f} minutes ago'.format(diff / 60)
    return 'just now'


def find_commands(db, *filters):
    user_filter = '\s+'.join(filters)
    user_re = re.compile(user_filter)
    RE_CACHE[user_filter] = user_re

    query = '''
    SELECT timestamp, duration, user_string
    FROM commands
    WHERE
        timestamp > ?
        AND user_string REGEXP ?
    '''

    table = Texttable()
    table.set_deco(Texttable.HEADER)
    table.set_cols_align(('r', 'r', 'l'))
    table.header(('date', 'duration', 'command'))

    max_command_width = 0
    now = time.time()
    for row in db.execute(query, (TIMESTAMP, user_filter)):
        max_command_width = max(max_command_width, len(row[2]))
        table.add_row((
            format_time(row[0], now),
            format_duration(row[1]) if row[1] > 0 else '',
            highlight(row[2], user_re)))

    table.set_cols_width((30, 10, max_command_width + 2))

    print table.draw()


def main(args):
    if not os.path.exists(DB_PATH):
        print 'Commands database does not exist: %s' % DB_PATH
        sys.exit(1)
    db = sqlite3.connect(DB_PATH)
    db.create_function('REGEXP', 2, regexp)
    find_commands(db, *args)


if __name__ == '__main__':
    main(sys.argv[1:])
