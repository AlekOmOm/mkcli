# MVP of TUI design 

## todo checklist - test case | expected output | actual output | pass/fail (✅/❌)

table:

| test case | expected output | actual output | pass/fail/not-tested (✅/❌/ )  |
| --- | --- | --- | --- |
| `mkcli` - with mode: `minimal`  | expect overwrite current `MKCLI_LOG_LEVEL` (aka `mode`) -> showing TUI output always, and then set log level to original after | `◆ mkcli 0.1.0`<br>`→ usage: mkcli <command> [options]`<br>`→ commands:`<br>`  add <alias> <path>  add a new Makefile project`<br>`  list                list all registered aliases`<br>`  remove <alias>      remove an alias`<br>`  mode <level>        set log level (minimal, info, debug)`<br>`→ options:`<br>`  --help  show this help message`<br>`→ aliases:`<br>`  <alias> --help           list targets for an alias`<br>`  <alias> <target> [args]  execute a make target` | ✅ |
| `mkcli` - with mode: `info`  | expect TUI output | `◆ mkcli 0.1.0`<br>`→ usage: mkcli <command> [options]`<br>`→ commands:`<br>`  add <alias> <path>  add a new Makefile project`<br>`  list                list all registered aliases`<br>`  remove <alias>      remove an alias`<br>`  mode <level>        set log level (minimal, info, debug)`<br>`→ options:`<br>`  --help  show this help message`<br>`→ aliases:`<br>`  <alias> --help           list targets for an alias`<br>`  <alias> <target> [args]  execute a make target` | ✅ |
| `mkcli` - with mode: `debug`  | expect TUI output | `◆ mkcli 0.1.0`<br>`→ usage: mkcli <command> [options]`<br>`→ commands:`<br>`  add <alias> <path>  add a new Makefile project`<br>`  list                list all registered aliases`<br>`  remove <alias>      remove an alias`<br>`  mode <level>        set log level (minimal, info, debug)`<br>`→ options:`<br>`  --help  show this help message`<br>`→ aliases:`<br>`  <alias> --help           list targets for an alias`<br>`  <alias> <target> [args]  execute a make target` | ✅ |
| `mkcli add/list/remove` - with mode: `minimal`  | no design, but clean cmd output | `mkcli add test-dev .` <br> `→ Alias 'test-dev' already exists, override? [y/N] y` <br> `[debug] link_create: alias='test-dev' src='/Users/alek/code/work/devops/mkcli/mkcli'` <br> `[debug] link_create: creating link '/usr/local/bin/test-dev' -> '/Users/alek/code/work/devops/mkcli/mkcli'` <br> `Password:` <br> `✔ test-dev registered /Users/alek/code/work/devops/mkcli` |  | 
| `mkcli add/list/remove` - with mode: `info`  | expect TUI designed output | `list`: `→ listing aliases`<br>`→ structure: <alias> <path> <version*> - note: version = version of mkcli at time of alias registration`<br>`dev /Users/alek/code/work/caes/research/terraform-dev-server 0.1.0`<br>`devvm /Users/alek/code/work/caes/research/terraform-dev-server 0.1.0` | ✅ |
| `mkcli add/list/remove` - with mode: `debug`  | expect TUI designed debugging output  | `list`: `→ listing aliases`<br>`→ structure: <alias> <path> <version*> - note: version = version of mkcli at time of alias registration`<br>`dev /Users/alek/code/work/caes/research/terraform-dev-server 0.1.0`<br>`devvm /Users/alek/code/work/caes/research/terraform-dev-server 0.1.0` | ✅ |
| `mkcli mode` - with mode: `minimal`  | expect overwrite + info + back to original | `→ usage: mkcli mode <mode-options>`<br>`→ crnt mode: minimal` | ✅ |
| `mkcli mode` - with mode: `info`  | expect TUI designed info output | `→ usage: mkcli mode <mode-options>`<br>`→ crnt mode: info` | ✅ |
| `mkcli mode` - with mode: `debug`  | expect TUI designed debugging output | `→ usage: mkcli mode <mode-options>`<br>`→ crnt mode: debug` | ✅ |


