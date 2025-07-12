registry_lookup() {
    registry_effective | awk -v alias="$1" '$1==alias {print $2; exit}'
}
registry_write() {
    alias_name="$1"
    abs_path="$2"
    version="$3"
    tmp="$(mktemp)"
    grep -v -E "^$alias_name " "${REG_USER}" 2>/dev/null >"${tmp}" || true
    echo "$alias_name $abs_path $version" >>"${tmp}"
    mv "${tmp}" "${REG_USER}"
}
registry_list() {
    registry_effective
}
REG_TEAM="${REG_TEAM:-$SCRIPT_DIR/registry.team}"
registry_effective() {
    {
        [ -f "${REG_USER}" ] && cat "${REG_USER}"
        [ -f "${REG_TEAM}" ] && cat "${REG_TEAM}"
    } | awk '!seen[$1]++'
}
registry_delete() {
    alias_name="$1"
    tmp="$(mktemp)"
    grep -v -E "^$alias_name " "${REG_USER}" 2>/dev/null >"${tmp}" || true
    mv "${tmp}" "${REG_USER}"
}
