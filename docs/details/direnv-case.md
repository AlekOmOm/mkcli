direnv & mkcli—what actually happens

why the env isn’t automatically loaded

direnv wires itself into your interactive shell prompt.
the hook runs only when the shell changes directory:

$ cd project/          # shell fires `direnv export bash`

mkcli does:

make -C /abs/path plan   # no cd in the parent shell

so the hook never triggers → the direnv-exported variables are absent.

⸻

three easy patterns to fix it

pattern	how	pros	cons
direnv exec (recommended)	wrap make call:direnv exec <dir> make -C <dir> …	canonical direnv way; respects allow policy	adds small direnv dependency
inline export	evaluate once at start:eval "$(direnv export bash)" then run make	no subshell; variables visible to mkcli itself	contaminates mkcli process env for rest of run
makefile self-aware	first rule in Makefile:include $(shell direnv export makefile)	stays inside Makefile world	slightly magical; harder to debug


⸻

minimal adjustment to mkcli (flow sketch)

if [ -f "$dir/.envrc" ] && command -v direnv >/dev/null; then
    # user already did `direnv allow` earlier
    exec direnv exec "$dir" make -C "$dir" "$@"
else
    exec make -C "$dir" "$@"
fi

	•	behaviour: transparent when .envrc present & trusted; otherwise fallback.

toggle with env flag:

export MKCLI_DIRENV=0   # force-disable


⸻

edge cases & safety
	1.	first-time repo clone
user still must run direnv allow manually once—direnv exec will refuse until then.
	2.	sudo not required—direnv executes under same user id.
	3.	performance negligible; direnv exec just spawns a subshell with the correct environment.
	4.	shell completion unchanged.

⸻

take-away

mkcli + direnv exec = full .envrc experience, no cd needed. add the 6-line check above (or make it opt-in via --direnv) and docker, terraform, etc. inherit the intended environment seamlessly.