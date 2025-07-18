#!/bin/bash

# link.sh
#
# This script is used to create and remove links to the source code.
#
# Usage:
#   link.sh <alias> <src>
#

LIB_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$LIB_DIR/ui.sh"

link_create() {
    debug "link_create: alias='$1' src='$2'"

    local alias_name="$1"
    local src="$2"
    local dst_dir="${LINK_DIR:-/usr/local/bin}"
    local dst="$dst_dir/$alias_name"
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            local target
            target="$(readlink "$dst")"
            if [ "$target" != "$src" ]; then
                warn "$dst already points elsewhere"
                return 1
            fi
            confirm "Override existing link?" || return 1
        else
            warn "$dst exists and is not a symlink"
            return 1
        fi
    fi
    debug "link_create: creating link '$dst' -> '$src'"
    sudo ln -sf "$src" "$dst"
}

link_remove() {
    debug "link_remove: alias='$1' src='$2'"
    alias_name="$1"
    src="$2"
    dst_dir="${LINK_DIR:-/usr/local/bin}"
    dst="$dst_dir/$alias_name"
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            target="$(readlink "$dst")"
            if [ "$target" != "$src" ]; then
                warn "$dst points elsewhere"
                return 1
            fi
            debug "link_remove: removing link '$dst'"
            sudo rm "$dst"
        else
            warn "$dst is not a symlink"
            return 1
        fi
    fi
}
