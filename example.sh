#!/bin/bash
# Example of log.sh
# Copyright (c) 2012 Yu-Jie Lin
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

source log.sh

echo "=== Prints one message to each level and call stack ===
 * You won't see Debug and Info because logging level is default
 * LS_WARNING_LEVEL = 30"
echo
LSDEBUG Debug message
LSINFO Info message
LSWARNING Warning message
LSERROR Error message
LSCRITICAL Critical message
func1 () {
  func2
}
func2 () {
  func3
}
func3 () {
  LSLOGSTACK
}
func1

echo
echo "=== Set level to LS_DEBUG_LEVEL 10 ==="
echo "=== Prints one message to each level ==="
echo
LS_LEVEL=LS_DEBUG_LEVEL

LSDEBUG Debug message
LSINFO Info message
LSWARNING Warning message
LSERROR Error message
LSCRITICAL Critical message

echo
echo "=== Prints 1 to 5 via pipe ==="
echo " * for ... | LSINFO"
echo

for i in {1..5}; do
  echo $i
done | LSINFO

echo
echo "=== Prints one message to level 35 ==="
echo
LSLOG 35 Message for level 35

echo
echo "=== Log on to /dev/stderr ==="
echo " * Try to rerun with $0 > /dev/null"
echo
LS_OUTPUT=/dev/stderr
LSERROR Error message to stderr

echo
echo "=== Set LS_LEVELS to simple cases ==="
echo
LS_OUTPUT=/dev/stdout
LS_LEVELS=(
  $LS_INFO_LEVEL     'INFO    ' "- I -" "\e[1;32m"    "\e[0m"
  $LS_WARNING_LEVEL  'WARNING ' "- * -" "\e[1;33m"    "\e[0m"
  $LS_ERROR_LEVEL    'ERROR   ' "- ! -" "\e[1;31m"    "\e[0m"
)

LSINFO Info message
LSWARNING Warning message
LSERROR Error message
