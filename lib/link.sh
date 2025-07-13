source lib/ui.sh

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
                info "WARN: $dst already points elsewhere"
                return 1
            fi
        else
            info "WARN: $dst exists and is not a symlink"
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
                echo "$dst points elsewhere" >&2
                exit 1
            fi
            debug "link_remove: removing link '$dst'"
            sudo rm "$dst"
        else
            echo "$dst is not a symlink" >&2
            exit 1
        fi
    fi
}
