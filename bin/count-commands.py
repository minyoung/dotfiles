#!/usr/bin/env python

import itertools
import os
import re
import sqlite3
import sys
import time


DB_PATH = os.path.expanduser('~/bin/Data/count-commands/commands.sqlite3')
COLORS = {
    'cyan': '\033[96m',
    'reset': '\033[0m',
    'yellow': '\033[93m',
    'red': '\033[31m',
}


def format_str(format_str, *args, **kwargs):
    kwargs.update(COLORS)
    return format_str.format(*args, **kwargs)


def _get_db():
    dirname = os.path.dirname(DB_PATH)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    return sqlite3.connect(DB_PATH, timeout=0.3)


def _create_command_table(db):
    db.execute('''
        CREATE TABLE IF NOT EXISTS commands (
            timestamp INTEGER,
            duration INTEGER DEFAULT -1,
            command TEXT,
            user_string TEXT,
            expanded_string TEXT)''')
    db.execute(
        '''CREATE INDEX IF NOT EXISTS ix_commands_command
            ON commands(command)''')
    db.execute(
        '''CREATE INDEX IF NOT EXISTS ix_commands_timestamp
            ON commands(timestamp)''')


def _insert_command(db, timestamp, user_string, expanded_string):
    command = user_string.split()[0]
    db.execute('''
        INSERT INTO commands (timestamp, command, user_string, expanded_string)
        VALUES (?, ?, ?, ?)''', [
            timestamp,
            command,
            user_string,
            expanded_string])
    db.commit()
    db.close()


def _print_command_info(user_command):
    command_info = format_str(
        "{cyan}{cwd} {reset}@ {yellow}{date}{reset}\n{user_command}",
        cwd=os.getcwd(),
        date=time.strftime('%F %T %Z'),
        user_command=user_command)
    info_lines = command_info.split('\n')

    ansi_color_regex = re.compile('\033\[\d+m')
    clean_info_lines = [ansi_color_regex.sub('', l).replace('\t', ' ' * 6)
                        for l in info_lines]
    line_length = max(map(len, clean_info_lines))

    print format_str("{red}+-{0}-+{reset}", '-' * line_length)
    for line, clean in itertools.izip(info_lines, clean_info_lines):
        print format_str(
            "{red}|{reset} {line}{padding} {red}|",
            line=line,
            padding=' ' * (line_length - len(clean)))
    print format_str("{red}+-{0}-+{reset}", '-' * line_length)


def log_command(args):
    timestamp = int(args[0])
    user_string = args[1]
    expanded_string = args[3]

    try:
        db = _get_db()
        _create_command_table(db)
        _insert_command(db, timestamp, user_string, expanded_string)
    except Exception, e:
        # logging the command is only best effort, so don't care about failures
        print "{0}: {1}".format(e.__class__.__name__, e)

    _print_command_info(expanded_string)


def _update_command_end(db, timestamp, duration):
    db.execute('''
        UPDATE commands
        SET duration = ?
        WHERE timestamp = ?''', [
            duration,
            timestamp])
    db.commit()
    db.close()


def log_command_end(args):
    timestamp = int(args[0])
    duration = int(args[1])
    try:
        db = _get_db()
        _update_command_end(db, timestamp, duration)
    except Exception, e:
        print "{0}: {1}".format(e.__class__.__name__, e)


if __name__ == '__main__':
    if not os.environ.get('KILL_COMMAND_LOGGING'):
        action = sys.argv[1]
        if action in globals():
            globals()[action](sys.argv[2:])
        else:
            print 'Unknown count-commands action: %s' % action
