parse_list_targets() {
    dir="$1"
    make -C "$dir" -pRrq -f "$dir/Makefile" : 2>/dev/null | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:/ {print $1}' | sort -u
}
