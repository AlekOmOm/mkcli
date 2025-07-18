#!/bin/bash

# parse.sh
#
# This script is used to parse the Makefile of a project and extract the list of targets.
#
# Usage:
#   parse.sh <dir>
#

LIB_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$LIB_DIR/ui.sh"

parse_list_targets() {
    debug "parse_list_targets: dir='$1'"
    dir="$1"
    make -C "$dir" -pr -f "$dir/Makefile" : 2>/dev/null | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:/ {print $1}' | sort -u
}
