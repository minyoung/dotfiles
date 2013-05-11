#!/usr/bin/env python

import itertools
import os
import re
import sqlite3
import sys
import time


DB_PATH = os.path.expanduser('~/bin/Data/count-commands/commands.sqlite3')
COLORS = {
    'red': '\033[31m',
    'light_red': '\033[91m',
    'green': '\033[92m',
    'yellow': '\033[93m',
    'gray': '\033[37m',
    'cyan': '\033[96m',
    'reset': '\033[0m',
}


def format_str(format_str, *args, **kwargs):
    kwargs.update(COLORS)
    return format_str.format(*args, **kwargs)


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


def normalize_user_string(user_string):
    return ' '.join(user_string.strip().split())


def print_box(text_block, color=COLORS['gray']):
    formatted_lines = text_block.split('\n')
    clean_lines = re.sub('\033\\[\\d+m', '', text_block.replace('\t', ' ' * 6))\
                    .split('\n')
    line_length = max(map(len, clean_lines))

    print format_str('{color}+-{0}-+{reset}', '-' * line_length, color=color)
    for line, clean in itertools.izip(formatted_lines, clean_lines):
        print format_str(
                '{color}|{reset} {line}{padding} {color}|',
                color=color,
                line=line,
                padding=' ' * (line_length - len(clean)))
    print format_str('{color}+-{0}-+{reset}', '-' * line_length, color=color)


def get_db():
    dirname = os.path.dirname(DB_PATH)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    db = sqlite3.connect(DB_PATH, timeout=0.3)
    db.row_factory = sqlite3.Row
    return db


def create_command_table(db):
    db.execute('''
        CREATE TABLE IF NOT EXISTS commands (
            uuid TEXT,
            timestamp INTEGER,
            duration INTEGER DEFAULT -1,
            command TEXT,
            user_string TEXT,
            expanded_string TEXT,
            PRIMARY KEY(uuid))''')
    db.execute(
        '''CREATE INDEX IF NOT EXISTS ix_commands_command
            ON commands(command)''')


def insert_command(db, uuid, timestamp, user_string, expanded_string):
    command = user_string.split()[0]
    db.execute('''
        INSERT INTO commands
            (uuid, timestamp, command, user_string, expanded_string)
        VALUES (?, ?, ?, ?, ?)''', [
            uuid,
            timestamp,
            command,
            user_string,
            expanded_string])
    db.commit()


def print_command_info(timestamp, user_command):
    print_box(format_str(
        "{cyan}{cwd} {reset}@ {yellow}{date}{reset}\n{user_command}",
        cwd=os.getcwd(),
        date=time.strftime('%F %T %Z', time.localtime(timestamp)),
        user_command=user_command))


def log_command(args):
    uuid = args[0]
    user_string = args[1]
    expanded_string = args[3]
    timestamp = time.time()

    try:
        db = get_db()
        create_command_table(db)
        insert_command(db, uuid, timestamp, user_string, expanded_string)
        db.close()
    except Exception, e:
        # logging the command is only best effort, so don't care about failures
        print format_str("{red}!!{reset} {0}: {1} {red}!!{reset}",
                e.__class__.__name__, e)

    print_command_info(timestamp, expanded_string)


def update_command_end(db, uuid, timestamp):
    row = db.execute('''SELECT * FROM commands WHERE uuid = ?''', [uuid])\
            .fetchone()
    db.execute('''UPDATE commands SET duration = ?  WHERE uuid = ?''',
                [timestamp - row['timestamp'], uuid])
    db.commit()
    return row


def print_command_end_info(timestamp, row):
    duration = timestamp - row['timestamp']
    if duration < 1 or duration > 43200:
        return

    ignored_commands = ['vim', 'man', 'less', 'tmux']
    if row['command'] in ignored_commands:
        return

    ignored_user_strings = ['g d', 'g show', 'g log']
    normalized = normalize_user_string(row['user_string'])
    for ignore_string in ignored_user_strings:
        if normalized.startswith(ignore_string):
            return

    if duration > 3600:
        elapsed_color = COLORS['red']
    elif duration > 60:
        elapsed_color = COLORS['light_red']
    else:
        elapsed_color = COLORS['green']

    print_box(format_str(
            "{cyan}{cwd}\n"
            "{yellow}{start} {red}~ {yellow}{end}\n"
            "{elapsed_color}Elapsed: {duration}\n\n"
            "{reset}{user_command}",
            cwd=os.getcwd(),
            start=time.strftime('%F %T %Z', time.localtime(row['timestamp'])),
            end=time.strftime('%F %T %Z', time.localtime(timestamp)),
            elapsed_color=elapsed_color,
            duration=format_duration(duration),
            user_command=row['expanded_string']))


def log_command_end(args):
    uuid = args[0]
    timestamp = time.time()

    try:
        db = get_db()
        row = update_command_end(db, uuid, timestamp)
        db.close()
        print_command_end_info(timestamp, row)
    except Exception, e:
        print format_str("{red}!!{reset} {0}: {1} {red}!!{reset}",
                e.__class__.__name__, e)


if __name__ == '__main__':
    if not os.environ.get('KILL_COMMAND_LOGGING'):
        action = sys.argv[1]
        if action in ['log_command', 'log_command_end']:
            globals()[action](sys.argv[2:])
        else:
            print 'Unknown count-commands action: %s' % action
