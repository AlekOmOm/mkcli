## key externals — what lives **outside** the repo

```
notation
  path/var/cmd : context → purpose
```

### 1. filesystem paths

* `/usr/local/bin/<alias>`
  → *global launcher*
  • symlink per registered alias pointing back to `mkcli`.
  • sits on the default `$PATH` for mac + most linux distros → lets the user type `devvm` anywhere.

* `/usr/local/bin/mkcli` **(optional)**
  → *wrapper cache*
  • if you prefer a single system-wide copy instead of calling into the repo.
  • keeps aliases working even when the repo isn’t cloned yet.

* `~/.config/mkcli/registry`
  → *user registry*
  • flat text “alias abs\_path version” per line.
  • mkcli writes/reads here; edit by hand only when scripts fail.

* `~/.config/mkcli/completion/` **(optional)**
  → *shell completion snippets*
  • bash/zsh completion files dropped here (or the distro’s system directory).

### 2. environment variables

* `PATH`
  → command resolution. aliases land in a dir already on this list.

* `MKCLI_YES=1` (or `--yes` flag)
  → non-interactive mode; suppresses confirmation prompts.

* `MKCLI_REGISTRY=/custom/file` **(optional)**
  → override default registry location for power users / CI.

### 3. privileged boundary

* `sudo` (single invocation)
  → required only for `ln -s` and `rm` inside `/usr/local/bin`.
  • mkcli guards the call with explicit confirmation; no other sudo needed.

### 4. mkcli dependencies (must exist on host)

```
bash    - interpreter
make    - execute targets
git     - used by upgrade-all
readlink realpath grep awk sort cut -> basic parsing & path resolution
```

all are coreutils or posix-ish; no extra packages.

### 5. safety footprint recap

```
writes:
  /usr/local/bin/<alias>     (symlink, needs sudo)
  ~/.config/mkcli/*          (registry, completion, logs)

reads:
  PATH, HOME, registry files, Makefile
executes:
  bash built-ins, make, git, coreutils
```

nothing else touches the host—no network, no other system dirs.
