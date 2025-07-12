### why */usr/local/bin* is in the picture

* it’s just the **drop-zone that most unix-like shells search first**.
* we don’t store a *binary* there; we only place a **tiny symlink** called *\<alias>* → *mkcli*.
* when you type `devvm`, the shell looks through `$PATH`, hits `/usr/local/bin/devvm`, follows the link back to *mkcli*, and the wrapper does the rest.

so: `/usr/local/bin` is a convenient, conventional handshake point between the shell and *mkcli*, nothing more.
if you prefer a different directory that’s already on your `$PATH` (`~/bin`, `~/.local/bin`, etc.) you can patch `mkcli` with `--link-dir` or export `MKCLI_LINK_DIR`. (nice-to-have extension consideration)

---

### walk-through: registering **devvm** with *mkcli*

> command issued
> `mkcli init devvm D/devdrive/0._GitHub/06._Caesari/caesari2/research/terraform-dev-server`

*(assume you’re inside Git-Bash, WSL, or any bash where that windows path is visible; on native linux/mac replace with a unix path)*

#### 1. argument intake

```
alias   = “devvm”
pathraw = “D:\devdrive\0._GitHub\06._Caesari\caesari2\research\terraform-dev-server”
```

#### 2. canonicalise path

* `realpath` converts the windows-style mount into a posix path, e.g.
  `/d/devdrive/0._GitHub/06._Caesari/caesari2/research/terraform-dev-server`

#### 3. validation gates

1. does `<abs>/Makefile` exist?

   * yes → continue, else abort “there’s no makefile here”.
2. is `devvm` already in the merged registry?

   * if yes → ask “override?” unless `--yes`.
3. inspect `/usr/local/bin/devvm`

   * *no file* → good.
   * *symlink to mkcli* → prompt to replace.
   * *anything else* → abort (unknown foreign file).

#### 4. registry write

```
append or update ~/.config/mkcli/registry
devvm  /d/devdrive/.../terraform-dev-server  VERSION=0.2
```

#### 5. link creation (privileged)

```
sudo ln -sf $(which mkcli) /usr/local/bin/devvm
```

* `sudo` only for this single step.
* if sudo unavailable (e.g. plain git-bash on windows), you’d run `mkcli init` with `--link-dir ~/bin` (no sudo needed, just ensure `~/bin` is on `$PATH`).

#### 6. success output

```
[✔] alias 'devvm' registered → /d/devdrive/.../terraform-dev-server
run `devvm --help` to see targets.
```

---

### now what happens when you type `devvm plan`

1. **shell lookup** finds `/usr/local/bin/devvm` → follows symlink to `mkcli`.
2. **mkcli dispatch**

   * `alias = basename($0) ⇒ "devvm"`
   * load registry → maps to project dir `/d/.../terraform-dev-server`.
3. mkcli forks: `make -C /d/.../terraform-dev-server plan`
4. output of your make target appears; exit code is propagated.

you never cd; any new make target you add to that makefile becomes instantly callable, e.g. `devvm restart`.

---

### scope reminder

*mkcli* is aimed at **make-driven projects wanting easy aliases**, not at installing compiled binaries.
`/usr/local/bin` is just the most portable spot for placing those alias symlinks—feel free to override it if your environment differs.
