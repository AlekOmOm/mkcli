# logic sketches—command by command

(common axioms: registry = merged view of `registry.team` → `registry.user`; wrapper path = `mkcli`; “confirm” means *ask unless --yes/ \$MKCLI\_YES*)

---

## mkcli init \<alias> \<path>

```
premise  user intends to create a new alias
assume   <path> may be abs or '.'
flow
  • canonicalize path → realpath(〈path〉)
  • assert file exists: 〈path〉/Makefile
  • look-up alias in registry
      if found → warn about override, require confirm
  • inspect /usr/local/bin/<alias>
      – if no file → ok
      – if symlink + target resolves to mkcli → overwrite after confirm
      – else (regular file or foreign symlink) → abort with diagnostic
  • write/overwrite registry entry 〈alias〉 〈abs_path〉 〈VERSION〉
  • sudo ln -sf mkcli → /usr/local/bin/<alias>
  • emit success message with next steps
post-condition  alias resolvable from any cwd
```

---

## mkcli list

```
goal  present current state with provenance
flow
  • read team registry, then user registry
  • merge, preferring user overrides
  • print table: alias  path  version(installed|—)
      mark conflicts (team vs user) and missing links
```

---

## mkcli remove \<alias>

```
premise  user wants to delete alias
flow
  • locate entry in effective registry
        if missing → inform & exit non-error
  • compute expected link = /usr/local/bin/<alias>
        if link absent → warn stale registry, ask confirm to prune entry only
        if link present but not symlink → abort (foreign file)
        if symlink target ≠ mkcli → abort (hijack risk)
  • confirm
  • sudo rm link  (if it existed)
  • delete entry from user registry
  • report completion
```

---

## mkcli doctor  (nice-to-have)

```
intent  audit and suggest fixes
checks
  1. dangling registry
        alias present but Makefile missing
  2. broken symlink
        link absent or target ≠ mkcli
  3. version drift
        repo VERSION > entry.version
  4. path collision
        file in /usr/local/bin shares name but not registered
output
  • each finding: alias, issue, recommended cmd (init/remove/upgrade)
  • exit non-zero if any critical issues
```

---

## mkcli upgrade-all  (nice-to-have)

```
premise  monorepo already git-cloned
flow
  • git pull origin main  (or current branch)
  • read repo VERSION (new_version)
  • iterate registry entries
        if entry.version < new_version
            • re-run init alias path with --yes (non-interactive)
            • update stored version
  • run doctor; abort on critical issues
```

---

## \<alias> \[target \[args…]]  (core)

fx. `devvm plan` or `devvm apply --auto-approve`

```
dispatch  (mkcli invoked via symlink name)
flow
  • alias = basename($0)
  • entry = lookup merged registry
        if absent → fatal “unknown alias”
  • dir = entry.path
  • case on $1
        "" | help | --help → show_usage(dir)
        --list-targets     → list_targets(dir)
        *                  → exec('make -C dir "$@"')
post-condition  exit status mirrors underlying make
```

---

## \<alias> --help / “”  (nice-to-have)

```
flow
  • parse makefile in dir → collect targets (grep/awk heuristic)
  • print:
        usage pattern
        dynamic target list (sorted)
        hint for tab completion
```

---

## \<alias> --list-targets  (nice-to-have)

```
purpose  machine-friendly enumeration
flow
  • print target names one per line (no decoration)
  • used by shell completion scripts
```

---

## safety invariant summary

```
∀ mutate_ops ∈ {init, remove, upgrade}
    writes into /usr/local/bin only after
        – alias belongs to registry or confirmed override
        – target path validation passes
        – explicit user confirmation unless --yes
```

these sketches encode the control logic, assumptions, decision points, and safety gates—implementation merely instantiates them in bash.
