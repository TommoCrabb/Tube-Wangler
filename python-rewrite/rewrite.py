#!/usr/bin/env python3

import urllib
import xml
import sys
import os
import re
import time

# SETUP

class style: # Colours
    err = '\033[0;31m' # red
    log = '\033[0;34m' # blue
    end = '\033[0;m'   # reset to normal
    
date_s = time.strftime("%Y-%m%d-%H%M%S")
logging_b = False
verbose_b = True
feed_re = re.compile(r"""^
  (https?://www.youtube.com/feeds/videos.xml\?channel_id=[-\w]{24}) 
  (\s+(((?!/)\S)+))?
  (\s+(.+))?
  $""", re.VERBOSE) # Probably not going to need this after all
channel_re = re.compile(r'^https?://www.youtube.com/feeds/videos.xml\?channel_id=([\-\w]{24})(\s.*)?$', re.DOTALL)
video_re = re.compile(r'^https?://www.youtube.com/watch\?v=([\-\w]{11}) .*$')
filter_re = re.compile(r'')

# FILES
feed_f = open('feeds', 'r')
hist_f = open('history', 'r+')
hist_l = hist_f.readlines()

def log(msg):
    """Print a message to the log file and optionally to stdout."""
    if logging_b == True:
        try:
            log_f
        except:
            log_f = open(date_s + '.log', 'a')
        print(msg, file=log_f)

    if verbose_b == True:
        print(style.log + msg + style.end, file=sys.stdout, end='')

def error(msg):
    """Print a message to the error file and optionally to stderr."""
    try:
        err_f
    except:
        err_f = open(date_s + '.err', 'a')
    print(msg, file=err_f)
    print(style.err + msg + style.end, file=sys.stderr, end='')


# BODY

feeds_l = []
for line_s in feed_f:
    match_o = channel_re.match(line_s)
    try:
        match_o.group(1)
    except:
        log("SKIPPED LINE: " + line_s)
    else:
        feed_d = dict(zip( ["id","url","file","tags"], [match_o.group(1)] + line_s.strip().split(None, 2) ))
        feeds_l.append(feed_d)

feed_f.close()
print(feeds_l)
    
print("END")
