# proposed project architecture

```
<monorepo-name>/
└─ devops/
   └─ mkcli/
      ├─ mkcli                ← single entry-point wrapper
      ├─ lib/
      │   ├─ registry.sh      ← add/read/remove helpers
      │   ├─ link.sh          ← symlink + sudo guard
      │   ├─ parse.sh         ← makefile target scraper
      │   └─ ui.sh            ← prompts, colors, logging
      ├─ scripts/
      │   ├─ install.sh       ← install mkcli
      │   ├─ uninstall.sh     ← uninstall mkcli
      │   └─ setup.sh         ← setup mkcli (one-time setup script)
      ├─ completions/
      │   ├─ mkcli.bash       ← generator template
      │   └─ mkcli.zsh
      ├─ registry.team        ← blessed aliases (devvm, …)
      ├─ VERSION              ← echoed in `mkcli --version`
      ├─ Makefile             ← lint, test, install, pkg
      ├─ tests/
      │   ├─ init.bats        ← behavior specs in bash-taps
      │   └─ doctor.bats
      ├─ README.md            ← one-page quick-start
      └─ docs/
          ├─ architecture.md  ← this file 
          ├─ externals.md     ← filesystem paths, env vars, dependencies, safety
          ├─ logic-sketches.md ← detailed flows for each command
          ├─ PRD.md            ← product requirements, commands, architecture, and logic sketches
          └─ use-scenario.md   ← example walkthrough for registering and using an alias (`devvm` scenario)

```

## component rationale

| layer                 | purpose                              | notes                                                                              |
| --------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| **`mkcli`**           | *thin* command router                | `#!/usr/bin/env bash`; delegates to functions in `lib/` – keeps top file < 80 LOC. |
| **`lib/registry.sh`** | pure data ops                        | canonicalises paths, merges team+user, JSON-free (simple space-delimited).         |
| **`lib/link.sh`**     | single choke-point for sudo          | validates targets, handles `MKCLI_LINK_DIR` but defaults to `/usr/local/bin`.      |
| **`lib/parse.sh`**    | grep/awk helpers                     | zero side effects; returns target list.                                            |
| **`lib/ui.sh`**       | prompts + color echo                 | isolates interactivity; obeys `--yes`.                                             |
| **completions/**      | keep shell-specific code out of core | templates call `mkcli --list-targets`; generated by `Makefile completions`.        |
| **`registry.team`**   | declarative defaults                 | read-only for users; merged before user registry.                                  |
| **tests/**            | confidence for refactors             | use `bats` (Bash Automated Testing System) → fits posix shell.                     |
| **Makefile**          | dog-foods tool                       | targets: `install`, `lint-shellcheck`, `test`, `release`.                          |
| **docs/**             | single source of truth               | short README for end-users, design doc for maintainers.                            |

## execution flow recap

```
$ devvm plan
└─shell finds /usr/local/bin/devvm (symlink)
   └─points to mkcli
      ├─determine alias=devvm
      ├─lib/registry.sh → dir
      ├─case argv: plan
      └─exec make -C dir plan
```

## principles kept

* **monolithic CLI feel, modular guts** – top script simple, libs testable.
* **no global state** – only writes: symlinks + `~/.config/mkcli/registry`.
* **POSIX baseline** – works in mac/linux/git-bash without gnu-isms.
* **one sudo touch-point** – `lib/link.sh` centralises privilege.

## future-proof hooks

* packaging path (pip/rust/go) → wrap `mkcli` in installer, libs stay.
* windows → shim script that forwards to WSL/git-bash or future native impl.
* features (doctor, upgrade) → drop into `lib/` without bloating entry-point.

this layout stays lean, readable, and scales if mkcli grows beyond the single-file phase.
