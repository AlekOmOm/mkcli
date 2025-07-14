# mkcli – universal makefile cli wrapper – prd v1.0.0

> purpose: one wrapper → many makefiles → zero cd gymnastics.

---

## premises recap

```
a  current-dir agnostic      (–C <dir>)
b  auto-exposes make targets (make "$@")
c  posix-shell portable      (/usr/bin/env bash)
```

---

## 1. problem statement

---

developers jump across dirs to run make. hard-coded wrappers diverge. we need a single, safe, up-to-date, multi-project cli.

---

## 2. goals

---

1. register any makefile dir as a cli alias.
2. alias works from any pwd.
3. zero maintenance when makefile evolves.
4. explicit safety prompts for privileged ops.
5. integrated versioning inside the caesari2 monorepo.

---

## 3. architecture

---

```
mkcli (wrapper script)
│
├─ registry.user   ~/.config/mkcli/registry
└─ registry.team   <repo>/devops/mkcli/registry.team
```

* **wrapper**: single bash file; entry-point for both `CLI` meta-commands and each alias.
* **registry**: newline pairs `<alias> <abs_path> [version]`.

resolution order: team → user (user can override).

---

## 4. command surface

---

| cmd                        | intention                                                                |
| -------------------------- | ------------------------------------------------------------------------ |
| `mkcli add <alias> <path>` | register dir (abs or `.`) and create symlink in `/usr/local/bin/<alias>` |
| `mkcli list`               | print merged registry (team/user)                                        |
| `mkcli remove <alias>`     | delete symlink + registry entry (with safety checks)                     |
| `mkcli doctor`             | audit: broken links, path collisions, version drift                      |
| `mkcli upgrade-all`        | `git pull` monorepo → recreate symlinks where wrapper `VERSION` changed  |
| `<alias> [target [args…]]` | proxy to `make -C <dir> "$@"`                                            |
| `<alias> --help / ""`      | dynamic usage scraped from makefile                                      |
| `<alias> --list-targets`   | machine-readable target list for completion                              |

flags: `--yes` (non-interactive), `--version`, `--registry <path>` override.

---

## 5. logic sketch

---

```bash
register() {                         # mkcli add
  alias="$1"; dir="$(realpath "$2")"
  [ -f "$dir/Makefile" ] || abort "no Makefile"
  confirm_symlink_write "$alias"    # ask unless --yes
  save_registry "$alias" "$dir" "$VERSION"
  sudo ln -sf "$(command -v mkcli)" "/usr/local/bin/$alias"
}

dispatch_alias() {                  # executed when called as <alias>
  alias="$(basename "$0")"
  entry="$(lookup_registry "$alias")" || abort "unknown alias"
  dir="$(echo "$entry" | cut -d' ' -f2)"
  case "${1-}" in
    ""|help|--help) show_usage "$dir" ;;
    --list-targets) list_targets "$dir" ;;
    *) make -C "$dir" "$@" ;;
  esac
}

remove() {                          # mkcli remove
  alias="$1"
  entry="$(lookup_registry "$alias")" || abort "not registered"
  link="/usr/local/bin/$alias"
  [ -L "$link" ] || abort "not a symlink"
  target="$(readlink "$link")"
  [[ "$target" == *mkcli ]] || abort "link points elsewhere"
  confirm "remove $alias?"          # unless --yes
  sudo rm "$link"
  delete_registry "$alias"
}
```

---

## 6. versioning model

---

* (in monorepo) ´mkcli´ lives in `devops/mkcli/`.
* file `VERSION` bumped on breaking/feature change.
* monorepo tag format: `cli-vX.Y.Z`.
* registry stores installed version; `doctor` warns if repo version > installed.
* `upgrade-all` = `git pull` + re-init every entry.

---

## 7. safety contract

---

| risk                                 | mitigation                                           |
| ------------------------------------ | ---------------------------------------------------- |
| clobbering files in `/usr/local/bin` | refuse overwrite unless it’s a mkcli-created symlink |
| unintended sudo                      | isolate sudo to the single `ln -s` / `rm` call       |
| silent destructive ops               | interactive confirm (default)                        |
| stale links                          | `doctor` identifies & proposes fixes                 |
| path hijack                          | on remove, verify link target matches registry       |

non-interactive automation sets `MKCLI_YES=1` or `--yes`.

---

## 8. non-functional

---

* run time ≤ 50 ms typical.
* wrapper ≤ 150 loc; grep/awk/sort only.
* tested on macOS 13, ubuntu 24.04, git-bash 2.x.

---

## 9. out of scope

---

* native powershell/cmd binary.
* parsing recursive `include` statements in makefiles.
* packaging to pip/npm/crates (future).

---

## 10. success metrics

---

* ≤ 1 min onboarding for new alias.
* 0 manual edits to wrapper after 3 months usage.
* ≥ 90 % of team aliases installed via `mkcli add` in first sprint.

