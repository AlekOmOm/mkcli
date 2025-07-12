## start plan

```
goal mvp
  g1  dispatch alias  → make -C <dir> <target> [args]
  g2  mkcli init      → register + create symlink
assumption
  repo layout already decided (devops/mkcli/)
deliverables
  d1  mkcli     (single file, self-contained)
  d2  setup.sh  (one-liner bootstrap for teammates)
```

---

1. coding order

---

```
step 1  write mkcli skeleton
        • parse $0 to detect “alias” vs “mkcli”
        • when called as alias: exec_make()
        • when called as mkcli: subcmd router (init only for now)

step 2  implement init flow
        • validate args, path, makefile
        • write ~/.config/mkcli/registry  (mkdir –p)
        • sudo ln -sf $(realpath $0) /usr/local/bin/<alias>

step 3  dispatch flow
        • load registry → resolve dir
        • if argv[1] in { "", help, --help } → scrape + print targets
        • else exec: make -C dir "$@"

step 4  write setup.sh
        • cd to repo root
        • chmod +x devops/mkcli/mkcli
        • sudo ln -sf $(pwd)/devops/mkcli/mkcli /usr/local/bin/mkcli
        • echo "[✔] mkcli installed. run: mkcli init devvm <path>"

step 5  smoke-test
        • mkcli init devvm /abs/.../terraform-dev-server
        • devvm help
        • devvm plan
```

---

2. minimal file breakdown

---

```
mkcli
  #!/usr/bin/env bash
  set -euo pipefail

  REG_USER="$HOME/.config/mkcli/registry"
  LINK_DIR="/usr/local/bin"

  mkdir -p "$(dirname "$REG_USER")"

  _alias_dispatch() {        # called when $0 != mkcli
    alias=$(basename "$0")
    dir=$(grep "^$alias " "$REG_USER" | cut -d' ' -f2) || \
         { echo "unknown alias $alias"; exit 1; }
    case "${1-}" in
      ""|help|--help) _show_usage "$dir"; exit ;;
    esac
    exec make -C "$dir" "$@"
  }

  _cmd_init() {
    alias="$1"; path="$(realpath "$2")"
    [ -f "$path/Makefile" ] || { echo "no Makefile in $path"; exit 1; }
    grep -v "^$alias " "$REG_USER" > "$REG_USER.tmp" 2>/dev/null || true
    echo "$alias $path" >> "$REG_USER.tmp"
    mv "$REG_USER.tmp" "$REG_USER"
    sudo ln -sf "$(realpath "$0")" "$LINK_DIR/$alias"
    echo "[✔] $alias registered → $path"
  }

  main() {
    if [[ "$(basename "$0")" != "mkcli" ]]; then
      _alias_dispatch "$@"
    else
      case "$1" in
        init) _cmd_init "$2" "$3" ;;
        *)    echo "usage: mkcli init <alias> <path>"; exit 1 ;;
      esac
    fi
  }
  main "$@"
```

*(just a conceptual skeleton; not production-ready yet)*

## setup.sh

```
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MKCLI_SRC="$SCRIPT_DIR/devops/mkcli/mkcli"

chmod +x "$MKCLI_SRC"
sudo ln -sf "$MKCLI_SRC" /usr/local/bin/mkcli
echo "[✔] mkcli installed. eg: mkcli init devvm $(pwd)/research/terraform-dev-server"
```

---

3. why start here

---

```
since  g1+g2 form the core feedback loop
then   you can dog-food immediately (devvm plan etc.)
since  only one file changes PATH (mkcli), setup.sh is trivial
therefore  early value with minimal surface; add registry merging, doctor, etc. later.
```

---

4. next milestones

---

* harden path + sudo checks (logic sketch already written).
* extract libs (`registry.sh`, `link.sh`) once skeleton stabilises.
* add `cli list`, `remove`, `--help` polish, shell completion.

start simple, iterate.
