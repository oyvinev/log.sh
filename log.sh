#!/bin/bash
# Logging library for Bash
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

LS_VERSION=0.3

LS_OUTPUT=${LS_OUTPUT:-/dev/stdout}
# XXX need more flexible templating, currently manual padding for level names
LS_DEFAULT_FMT=${LS_DEFAULT_FMT:-'[$TS][$_LS_LEVEL_STR][${FUNCNAME[1]}:${BASH_LINENO[0]}]'}

LS_DEBUG_LEVEL=10
LS_INFO_LEVEL=20
LS_WARNING_LEVEL=30
LS_ERROR_LEVEL=40
LS_CRITICAL_LEVEL=50
LS_LEVEL=${LS_LEVEL:-$LS_WARNING_LEVEL}
# LS_LEVELS structure:
# Level, Level Name, Level Format, Before Log Entry, After Log Entry
LS_LEVELS=(
  $LS_DEBUG_LEVEL    'DEBUG   ' "$LS_DEFAULT_FMT" "\e[1;34m"    "\e[0m"
  $LS_INFO_LEVEL     'INFO    ' "$LS_DEFAULT_FMT" "\e[1;32m"    "\e[0m"
  $LS_WARNING_LEVEL  'WARNING ' "$LS_DEFAULT_FMT" "\e[1;33m"    "\e[0m"
  $LS_ERROR_LEVEL    'ERROR   ' "$LS_DEFAULT_FMT" "\e[1;31m"    "\e[0m"
  $LS_CRITICAL_LEVEL 'CRITICAL' "$LS_DEFAULT_FMT" "\e[1;37;41m" "\e[0m"
)

_LS_FIND_LEVEL_STR () {
  local LEVEL=$1
  local i
  _LS_LEVEL_STR="$LEVEL"
  for ((i=0; i<${#LS_LEVELS[@]}; i+=5)); do
    if [[ "$LEVEL" == "${LS_LEVELS[i]}" ]]; then
      _LS_LEVEL_STR="${LS_LEVELS[i+1]}"
      _LS_LEVEL_FMT="${LS_LEVELS[i+2]}"
      _LS_LEVEL_BEGIN="${LS_LEVELS[i+3]}"
      _LS_LEVEL_END="${LS_LEVELS[i+4]}"
      return 0
    fi
  done
  _LS_LEVEL_FMT="$LS_DEFAULT_FMT"
  _LS_LEVEL_BEGIN=""
  _LS_LEVEL_END=""
  return 1
}

# General logging function
# $1: Level
LSLOG () {
  local LEVEL=$1
  shift
  (( LEVEL < LS_LEVEL )) && return 1
  local TS=$(date +'%Y-%m-%d %H:%M:%S.%N')
  # Keep digits only up to milliseconds
  TS=${TS%??????}
  _LS_FIND_LEVEL_STR $LEVEL
  local OUTPUT
  eval "OUTPUT=\"$_LS_LEVEL_FMT\""
  # if no message was passed, read it from STDIN
  local _MSG
  [[ $# -ne 0 ]] && _MSG="$@" || _MSG="$(cat)"
  if [[ "$LS_OUTPUT" = "/dev/stdout" ]] ; then
    echo -ne "$_LS_LEVEL_BEGIN$OUTPUT "
    echo -n  "$_MSG"
    echo -e "$_LS_LEVEL_END"
  else
    echo -ne "$_LS_LEVEL_BEGIN$OUTPUT " >> "$LS_OUTPUT"
    echo -n  "$_MSG"                    >> "$LS_OUTPUT"
    echo -e "$_LS_LEVEL_END" >> "$LS_OUTPUT"
  fi
}

shopt -s expand_aliases
alias LSDEBUG='LSLOG 10'
alias LSINFO='LSLOG 20'
alias LSWARNING='LSLOG 30'
alias LSERROR='LSLOG 40'
alias LSCRITICAL='LSLOG 50'
alias LSLOGSTACK='LSDEBUG Traceback ; LSCALLSTACK'

# TODO Log Bash information
LSLOGBASH () {
  :
}

# TODO Log current user information
LSLOGUSER () {
  :
}

# Log Call Stack
LSCALLSTACK () {
  local i=0
  local FRAMES=${#BASH_LINENO[@]}
  # FRAMES-2 skips main, the last one in arrays
  for ((i=FRAMES-2; i>=0; i--)); do
    echo '  File' \"${BASH_SOURCE[i+1]}\", line ${BASH_LINENO[i]}, in ${FUNCNAME[i+1]}
    # Grab the source code of the line
    sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i+1]}"
    # TODO extract arugments from "${BASH_ARGC[@]}" and "${BASH_ARGV[@]}"
    # It requires `shopt -s extdebug'
  done
}
