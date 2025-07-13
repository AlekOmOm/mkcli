#!/usr/bin/env bash

# TUI library for consistent output formatting.
# inspired by: docs/ui.md

_COLOR_SUPPORT=''

_init_colors() {
    if [ -z "$_COLOR_SUPPORT" ]; then
        if [ -t 1 ] && [ -z "${NO_COLOR-}" ]; then
            if command -v tput >/dev/null && tput setaf 1 >/dev/null 2>&1; then
                _COLOR_SUPPORT=true
                _COLOR_TITLE=$(tput setaf 6)
                _COLOR_INFO=$(tput setaf 7)
                _COLOR_SUCCESS=$(tput setaf 2)
                _COLOR_WARN=$(tput setaf 3)
                _COLOR_ERROR=$(tput setaf 1)
                _COLOR_DEBUG=$(tput setaf 5)
                _COLOR_ACCENT=$(tput bold)
                _COLOR_RESET=$(tput sgr0)
            else
                _COLOR_SUPPORT=false
            fi
        else
            _COLOR_SUPPORT=false
        fi
    fi
}

_log() {
    local type="$1"
    local glyph="$2"
    local color_var="$3"
    shift 3
    local msg="$*"

    local level_num
    case "${MKCLI_LOG_LEVEL-info}" in
    minimal) level_num=0 ;;
    info) level_num=1 ;;
    debug) level_num=2 ;;
    *) level_num=1 ;;
    esac

    local type_num
    case "$type" in
    info | title) type_num=1 ;;
    debug) type_num=2 ;;
    *) type_num=0 ;; # ok, warn, fail always show
    esac

    [ "$level_num" -ge "$type_num" ] || return 0

    _init_colors
    if [ "$type" = "title" ]; then
        if [ "$_COLOR_SUPPORT" = true ]; then
            printf '\n%s%s %s%s\n' "$color_var" "$glyph" "$msg" "$_COLOR_RESET"
        else
            printf '\n%s %s\n' "$glyph" "$msg"
        fi
    else
        if [ "$_COLOR_SUPPORT" = true ]; then
            printf '%s%s %s%s\n' "$color_var" "$glyph" "$msg" "$_COLOR_RESET"
        else
            printf '%s %s\n' "$glyph" "$msg"
        fi
    fi
}

title() {
    _log "title" "◆" "${_COLOR_TITLE-}" "$@"
}

info() {
    _log "info" "→" "${_COLOR_INFO-}" "$@"
}

ok() {
    _log "ok" "✔" "${_COLOR_SUCCESS-}" "$@"
}

warn() {
    _log "warn" "!" "${_COLOR_WARN-}" "$@"
}

fail() {
    _log "error" "✖" "${_COLOR_ERROR-}" "$@" >&2
    exit 1
}

debug() {
    if [ "$MKCLI_LOG_LEVEL" = "debug" ]; then
        _log "debug" "🐛" "${_COLOR_DEBUG-}" "$@"
    fi
}

confirm() {
    local prompt="$1"
    if [ "${MKCLI_YES-}" = "1" ]; then
        info "(auto-yes) $prompt"
        return 0
    fi
    _init_colors
    if [ "$_COLOR_SUPPORT" = true ]; then
        printf '%s→ %s [y/N]%s ' "$_COLOR_INFO" "$prompt" "$_COLOR_RESET"
    else
        printf '→ %s [y/N] ' "$prompt"
    fi
    local reply
    read -r reply
    [ "${reply-}" = "y" ] || [ "${reply-}" = "Y" ]
}

table() {
    column -t -s $'\t'
}

spinner() {
    # Not implemented in MVP
    :
}
