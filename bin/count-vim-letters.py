#!/usr/bin/env python2.7

import code
import collections
import glob
import math
import os
import cPickle as pickle
import sys
import time

from texttable import Texttable

DEFAULT_LOGS = os.path.expanduser('~/bin/Data/vim-logs/*.log')
PICKLE_PATH = os.path.expanduser('~/bin/Data/vim-logs/data/vim_stats.p')

KEY_MAP = {
    '\r': '<CR>',
    '\x1b': '<ESC>',
    '\x80': '<BS>',
    '\n': '\\n',
    ' ': '<SPACE>',
}


def mean(data_list):
    return float(sum(data_list)) / len(data_list)

def standard_deviation(data_list):
    mean_value = mean(data_list)
    deviations_squared = [math.pow(i - mean_value, 2) for i in data_list]
    mean_deviation = mean(deviations_squared)
    standard_deviation = math.sqrt(mean_deviation)
    return standard_deviation

def median(data_list):
    n = len(data_list)
    index = n / 2
    data_list.sort()
    # grab middle value if odd
    if n & 1:
        return float(data_list[index])

    # else average the two values at the center
    average = float(data_list[index - 1] + data_list[index]) / 2
    return average


def to_raw(ch):
    return chr(ord(ch.upper()) - ord('A') + 1)

def from_raw(ch):
    return '^' + chr(ord(ch)-1 + ord('A'))

def printable(ch, with_repr=False):
    result = ch
    if ch in KEY_MAP:
        result = KEY_MAP[ch]
    if ord(ch) < 27:
        result = from_raw(ch)
        # result = '^' + chr(ord(ch)-1 + ord('A'))
    if with_repr:
        result += '\t%r' % ch
    return result

def printable_str(s):
    return ''.join(map(printable, s))


class TrieNode(object):
    def __init__(self):
        self.children = {}

    def insert(self, word):
        if not word:
            return
        start, rest = word[0], word[1:]
        if start not in self.children:
            self.children[start] = [0, TrieNode()]
        node = self.children[start]
        node[0] += 1
        node[1].insert(rest)

    def get(self, word):
        if not word:
            return self
        start, rest = word[0], word[1:]
        if start not in self.children:
            return None
        return self.children[start][1].get(rest)

    def get_count(self, word):
        start, rest = word[0], word[1:]
        if not rest:
            return self.children[start][0]
        return self.children[start][1].get_count(rest)

    def __getstate__(self):
        return self.__dict__

    def __setstate__(self, d):
        self.__dict__.update(d)

    def __getitem__(self, key):
        return self.get(key)

    def __getattr__(self, attr):
        return self.get(attr)

    def __repr__(self):
        return '<TrieNode: %r>' % (
                { k: v[0] for k, v in self.children.iteritems() })

    def __str__(self):
        if not self.children:
            return 'Sorry, no data'

        percentage = 100.0 / sum(v[0] for v in self.children.values())
        data = sorted(
                ((v[0], printable(k, with_repr=True))
                    for k, v in self.children.iteritems()),
                reverse=True)

        table = Texttable()
        table.set_deco(Texttable.HEADER)
        table.header(('c', '#', '%'))
        table.set_cols_align(('l', 'r', 'r'))
        table.add_rows(
                ((v[1], v[0], v[0] * percentage) for v in data[:20]),
                header=False)

        return table.draw()


class SuffixTrie(object):
    def __init__(self):
        self.trie = TrieNode()

    def insert_words(self, words):
        for word in words:
            self.insert(word)
        return self

    def insert(self, word, max_len=10):
        for start in xrange(len(word)):
            self.trie.insert(word[start:][:max_len])
        return self

    def get(self, word):
        return self.trie.get(word)

    def get_count(self, word):
        assert word, 'word must not be empty'
        return self.trie.get_count(word)

    def __getstate__(self):
        return self.__dict__

    def __setstate__(self, d):
        self.__dict__.update(d)

    def __getitem__(self, key):
        return self.get(key)

    def __getattr__(self, attr):
        return self.get(attr)

    def __repr__(self):
        return repr(self.trie)

    def __str__(self):
        return str(self.trie)


class SessionStats(object):
    def __init__(self):
        self.input_count = 0
        self.lengths = []
        self.letter_counts = collections.defaultdict(int)
        self.histogram = collections.defaultdict(int)

    def load_inputs(self, inputs):
        self.lengths.extend(map(len, inputs))
        self.lengths.sort()

        for i in inputs:
            for c in i:
                self.letter_counts[c] += 1
            self.histogram[len(i)] += 1

        return self

    @staticmethod
    def _format_histogram_row(start, previous, current_sum, maximum, **kwargs):
        if not start:
            _range = previous
        elif start == previous:
            _range = start
        else:
            _range = (start, previous)

        if current_sum > maximum:
            line = '*' * (maximum - 3) + '...'
        else:
            line = '*' * current_sum

        return (_range, current_sum, line)

    def print_histogram(self, minimum=5, maximum=100, max_range=10):
        table = Texttable()
        table.set_deco(Texttable.HEADER)
        table.set_cols_align(('l', 'r', 'l'))
        table.set_cols_width((10, 3, maximum))
        table.header(('range', '#', ''))

        start = 0
        previous = 0
        current_sum = 0

        for value, count in sorted(self.histogram.items()):
            new_row = \
                    (value - start) > max_range or \
                    current_sum >= minimum or \
                    current_sum + count >= maximum
            if new_row:
                # passing **locals() is such a hax, don't do this
                table.add_row(self._format_histogram_row(**locals()))
                start = value
                previous = value
                current_sum = count
            else:
                previous = value
                current_sum += count

        # passing **locals() is such a hax, don't do this
        table.add_row(self._format_histogram_row(**locals()))
        print table.draw()

    def p(self, n):
        return self.lengths[int(n/100.0 * len(self.lengths))]

    def print_session_stats(self):
        print 'Input counts: %d' % self.input_count
        print 'Max: %d' % max(self.lengths)
        print 'median: %d' % median(self.lengths)
        print 'stddev: %f' % standard_deviation(self.lengths)
        print 'p50: %d' % self.p(50)
        print 'p75: %d' % self.p(75)
        print 'p90: %d' % self.p(90)
        print 'mean: %d' % mean(self.lengths)

    def print_top_key_presses(self):
        flipped = [(v, k) for (k, v) in self.letter_counts.iteritems()]
        flipped.sort(reverse=True)

        percentage = 100.0 / sum(self.letter_counts.values())

        table = Texttable()
        table.set_deco(Texttable.HEADER)
        table.set_cols_align(('r', 'r', 'l'))
        table.header(('count', '%', 'letter'))
        for pair in flipped[:20]:
            count, key = pair
            table.add_row((count, count * percentage, printable(key)))
        print table.draw()


class VimStats(object):
    def __init__(self):
        self.session_stats = SessionStats()
        self.suffix_trie = SuffixTrie()
        self.sessions = []

    def print_stats(self, session_stats=False, histogram=False):
        print 'Session counts: %d' % len(self.sessions)
        print '= Top Key Presses ='
        self.session_stats.print_top_key_presses()
        print
        if session_stats:
            print '= Session Stats ='
            self.session_stats.print_session_stats()
            print
        if histogram:
            print '= Histogram ='
            self.session_stats.print_histogram()
            print

    def load_content(self, content, timestamp=None):
        self.sessions.append((timestamp or time.time(), content))

        inputs = filter(None, content.split('\x1b'))
        self.session_stats.load_inputs(inputs)
        self.suffix_trie.insert_words(inputs)

        return self

    def search(self, content, count=-1):
        lines = [s[1] for s in self.sessions if content in s[1]]
        for line in lines[:count]:
            accum = []
            head, sep, tail = line.partition(content)
            while head:
                accum.append(repr(printable_str(head))[1:-1])
                accum.append('\033[91m' + repr(printable_str(content))[1:-1] + '\033[0m')
                head, sep, tail = tail.partition(content)
            print ''.join(accum)
            print '\033[91m' + ('-' * 20) + '\033[0m'


def save_state(state, pickle_path):
    with open(pickle_path, 'wb') as f:
        pickle.dump(state, f)

def load_state(pickle_path):
    try:
        with open(pickle_path, 'rb') as f:
            return pickle.load(f)
    except:
        return VimStats()

def main(filenames):
    vim_stats = load_state(PICKLE_PATH)

    updated = False
    for filename in filenames:
        try:
            f = open(filename)
        except:
            print 'Warning: could not open file %r' % filename
            continue

        content = f.read()
        f.close()
        if content:
            vim_stats.load_content(content)
            os.unlink(filename)
            updated = True

    if updated:
        save_state(vim_stats, PICKLE_PATH)
    return vim_stats

if __name__ == '__main__':
    args = sys.argv[1:] or glob.glob(DEFAULT_LOGS)
    interactive = False
    if '-i' in args:
        args.remove('-i')
        interactive = True
    stats = main(args)
    s = stats.suffix_trie
    stats.print_stats()
    if interactive:
        code.interact(local=locals())
