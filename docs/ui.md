tui design spec – v0.1

guiding ideas

clarity > flair
semantic coloring, no hard-coded ansi (use tput); auto-disable when not a tty
functional units (log, prompt, list, table) → reusable across all sub-scripts


⸻

### 1. Color palette (tput)

| Semantic | `tput` call | Fallback | Glyph |
|----------|-------------|----------|-------|
| title    | `setaf 6`   | cyan     | ◆     |
| info     | `setaf 7`   | white    | →     |
| success  | `setaf 2`   | green    | ✔     |
| warn     | `setaf 3`   | yellow   | !     |
| error    | `setaf 1`   | red      | ✖     |
| debug    | `setaf 5`   | magenta  | 🐛    |
| accent   | `bold`      | —        | n/a   |

`reset=$(tput sgr0)` after every colored segment.

⸻

	2.	ui api (lib/ui.sh)

⸻


_color()     # $1 = color var   : echoes sequence or ""
_log()       # $1 = glyph  $2 = color  $3.. = msg
info()       # → _log "→"  $INFO  "$@"
ok()         # → _log "✔"  $SUCCESS
warn()       # …
fail()       # exits 1 after printing
title()      # newline + accent cyan big message
confirm()    # prompt Y/n, obey $MKCLI_YES
table()      # cols…  tab-separated → aligned output
spinner()    # cmd & pid … shows /-\ until wait (for long make ops)

these functions never echo raw ANSI; they call _color which internally checks tput availability and [[ -t 1 ]].

⸻

	3.	layout conventions

⸻


$ mkcli init devvm ~/terraform-dev-server
◆ mkcli init
→ registering alias: devvm
→ link dir: /usr/local/bin        (/custom if env set)
✔ added to registry
✔ symlink created

	•	first line: title.
	•	each subsequent step: info.
	•	terminal successes: ok.
	•	warnings use warn, errors use fail.

help screen

◆ devvm – targets
usage: devvm <target> [args]

available targets
  apply           Apply Terraform changes
  destroy         Destroy the development server
  plan            Plan Terraform changes

	•	commands & columns aligned with table.

⸻

	4.	prompt pattern

⸻


confirm "override existing alias devvm?"
→ override existing alias devvm? [y/N] _

	•	default answer capitalized ([y/N]); only explicit y/Y continues.
	•	in non-interactive mode (--yes or env) prompt auto-answers “yes” and prints → (auto-yes).

⸻

	5.	error handling

⸻


fail() {
  _log "✖" $ERROR "$*"
  exit 1
}

	•	one exit point per script block; upstream propagates status code.
	•	no stack traces; messages concise + actionable.

⸻

	7.	logging verbosity

⸻

to control output verbosity, mkcli supports three modes, configurable via the `mkcli mode <level>` command. the setting is persisted in `~/.config/mkcli/config`.

	•	`minimal`: only shows essential output (`ok`, `warn`, `fail`, `title`, and confirmation prompts). silences `info` and `debug` messages.
	•	`info` (default): shows all messages except `debug`. this is the standard operating mode.
	•	`debug`: shows all messages, including verbose `debug` logs for troubleshooting.

the implementation resides in `lib/ui.sh`, where functions like `info()` and `debug()` check a `MKCLI_LOG_LEVEL` environment variable before printing.

⸻

	6.	adoption rules

⸻

	•	every script sources lib/ui.sh first.
	•	raw echo allowed only for machine-parseable output (--list-targets).
	•	never duplicate color codes outside ui lib.
	•	tests mock tput to verify glyphs stripped in no-tty mode.

⸻

this gives a small, orthogonal ui toolkit: color-safe, tty-aware, consistent glyphography, easy to extend.