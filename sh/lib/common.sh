#!/usr/bin/env bash
#
# Commong functions
unset ERROR #

error() {
  echo -e "\e[31m$(date '+%x %X') ERROR: $1\e[0m"
  ERROR=$2
}

errorAndExit() {
  echo -e "\e[31m$(date '+%x %X') ERROR: $1\e[0m"
  exit $2
}

info() {
  echo -e "\e[34m$(date '+%x %X') INFO: ${1}\e[0m"
}

warn() {
  echo -e "\e[33m$(date '+%x %X') WARNING: ${1}\e[0m"
}
