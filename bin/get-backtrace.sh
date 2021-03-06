#!/bin/bash
# Author : Vishesh Handa <handa.vish@gmail.com>
#
# This script outputs the backtrace of any running prcoess when provided its PID
#

CONFFILE="/tmp/get-backtrace-conf"
echo "attach $1" > "$CONFFILE"
echo "thread apply all backtrace" >> "$CONFFILE"
echo "detach" >> "$CONFFILE"

echo "$2"
gdb --batch -x "$CONFFILE"
echo "============================="

rm "$CONFFILE"
