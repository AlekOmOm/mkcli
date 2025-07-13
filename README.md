# *mkcli*

**Purpose**: 
- `mkcli` -> *make cli*

>  one wrapper → many makefiles → zero cd gymnastics.

---

   -> *make any Makefile a global CLI*
   -  current-dir agnostic      
   -  auto-exposes make targets 
   -  posix-shell portable      

## quick start

```bash
make install
```

```bash
# register an alias
mkcli add <alias> <path-to-dir-with-Makefile>
```

fx.
```bash
mkcli add vm /Users/jason/code/devvm
# or relative path
mkcli add vm .
```

```bash
vm create
vm deploy ./trading-bot
vm ssh
```

## TL;DR:

- functions simply as registry of aliases.
- and ensures executability of make cmds from any directory.
- while prioritizing safety and simplicity.


## How 

1. **Install**: `make install`
2. **Register an Alias**: `mkcli add <alias> <path-to-dir-with-Makefile>`  
   - Creates a global symlink in `/usr/local/bin/<alias>` (requires sudo for that step only).  
   - Registers the path in `~/.config/mkcli/registry`.
3. **Run Targets**: `<alias> <target> [args]` (e.g., `vm ssh`)—proxies to `make -C <dir>`.  
   - For help: `<alias> --help` (dynamically lists targets).  
4. **Manage**:  
   - `mkcli a <alias> <path-to-dir-with-Makefile>` (register an alias).  
   - `mkcli ls` (show registered aliases).  
   - `mkcli rm <alias>` (delete alias and symlink).  
5. **Safety**: Prompts for permission when handling $PATH.

Onboarding: ≤1 min per alias. No edits needed when adding Makefile targets.

## Why mkcli?
Developers juggle directories to run `make`. 
-> mkcli creates safe, global aliases that work from anywhere, with dynamic target exposure and built-in management. 

See [PRD.md](docs/PRD.md) for full goals, architecture, and success metrics.

## Documentation Links
- [PRD.md](docs/PRD.md): Product requirements, commands, architecture, and logic sketches.
- [externals.md](docs/externals.md): Filesystem paths, env vars, dependencies, and safety footprint.
- [logic-sketches.md](docs/logic-sketches.md): Detailed flows for each command.
- [use-case-devvm-flow.md](docs/use-case-devvm-flow.md): Example walkthrough for registering and using an alias.

## Nice-to-Have Extensions (Not MVP)
- `mkcli` as NPM, pip or binary
- `mkcli` as a `make` plugin

## Contributing
Follow PRD.md's premises: POSIX-Bash portable, ≤150 LOC wrapper, safety-first. Test on macOS 13+ and Ubuntu 24.04+.

License: See [LICENSE](LICENSE). 
