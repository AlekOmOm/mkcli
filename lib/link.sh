link_create() {
    alias_name="$1"
    src="$2"
    dst_dir="${LINK_DIR:-/usr/local/bin}"
    dst="$dst_dir/$alias_name"
    if [ -e "$dst" ]; then
        if [ -L "$dst" ]; then
            target="$(readlink "$dst")"
            if [ "$target" != "$src" ]; then
                echo "$dst already points elsewhere" >&2
                exit 1
            fi
            printf 'Override existing link? [y/N]: '
            read -r ans
            [ "$ans" = "y" ] || exit 1
        else
            echo "$dst exists and is not a symlink" >&2
            exit 1
        fi
    fi
    sudo ln -sf "$src" "$dst"
}

link_remove() {
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
            sudo rm "$dst"
        else
            echo "$dst is not a symlink" >&2
            exit 1
        fi
    fi
}
