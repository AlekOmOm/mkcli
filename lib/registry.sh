#!/bin/bash

# registry.sh
#
# This script is used to manage the registry of aliases.
#
# Usage:
#   registry.sh <alias> <path> <version>
#

LIB_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$LIB_DIR/ui.sh"

# check if alias is registered
registry_lookup() {
    local user_reg="${REG_USER}"
    [ -f "$user_reg" ] || user_reg=/dev/null
    awk -v alias="$1" '$1 == alias {print $2; exit}' "$user_reg"
}

registry_write() {
    local alias_name="$1"
    local abs_path="$2"
    local version="$3"
    local tmp
    tmp="$(mktemp)"
    if [ -f "${REG_USER}" ]; then
        grep -v -E "^$alias_name " "${REG_USER}" >"${tmp}"
    fi
    echo "$alias_name $abs_path $version" >>"${tmp}"
    mv "${tmp}" "${REG_USER}"
}

registry_list() {
    local user_reg="$REG_USER"
    [ -f "$user_reg" ] || user_reg=/dev/null
    awk '!seen[$1]++' "$user_reg"
}

registry_delete() {
    local alias_name="$1"
    if [ -f "${REG_USER}" ]; then
        local tmp
        tmp="$(mktemp)"
        grep -v -E "^$alias_name " "${REG_USER}" >"${tmp}"
        mv "${tmp}" "${REG_USER}"
    fi
}
