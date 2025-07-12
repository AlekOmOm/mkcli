# mkcli: Universal Makefile CLI Wrapper

**Purpose**: One wrapper for many Makefiles—run targets from any directory without `cd`, with zero maintenance as Makefiles evolve. Portable for Bash on macOS and Linux.

## TL;DR: Quick Start

1. **Install**: Clone this repo and add `mkcli` to your `$PATH` (e.g., symlink or copy to `~/bin`).
2. **Register an Alias**: `mkcli init <alias> <path-to-dir-with-Makefile>`  
   - Creates a global symlink in `/usr/local/bin/<alias>` (requires sudo for that step only).  
   - Registers the path in `~/.config/mkcli/registry`.
3. **Run Targets**: `<alias> <target> [args]` (e.g., `myproj build`)—proxies to `make -C <dir>`.  
   - For help: `<alias> --help` (dynamically lists targets).  
4. **Manage**:  
   - `mkcli list` (show registered aliases).  
   - `mkcli remove <alias>` (delete alias and symlink).  
   - `mkcli doctor` (audit for issues like broken links).  
   - `mkcli upgrade-all` (pull repo updates and refresh aliases if version changed).  
5. **Safety**: Confirms privileged actions; use `--yes` for non-interactive mode.

Onboarding: ≤1 min per alias. No edits needed when adding Makefile targets.

## Why mkcli?
Developers juggle directories to run `make`. mkcli creates safe, global aliases that work from anywhere, with dynamic target exposure and built-in management. Integrated with monorepos for easy versioning.

See [PRD.md](docs/PRD.md) for full goals, architecture, and success metrics.

## Documentation Links
- [PRD.md](docs/PRD.md): Product requirements, commands, architecture, and logic sketches.
- [externals.md](docs/externals.md): Filesystem paths, env vars, dependencies, and safety footprint.
- [logic-sketches.md](docs/logic-sketches.md): Detailed flows for each command.
- [use-case-devvm-flow.md](docs/use-case-devvm-flow.md): Example walkthrough for registering and using an alias.

## Nice-to-Have Extensions (Not MVP)
- Custom link directories (e.g., via `--link-dir` or `MKCLI_LINK_DIR` for non-/usr/local/bin paths).
- Override registry path with `MKCLI_REGISTRY`.

## Contributing
Follow PRD.md's premises: POSIX-Bash portable, ≤150 LOC wrapper, safety-first. Test on macOS 13+ and Ubuntu 24.04+.

License: See [LICENSE](LICENSE). 