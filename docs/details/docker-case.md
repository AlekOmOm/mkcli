short answer

yep—no extra work. once mkcli has registered devvm, any make target that shells out to docker (or docker-compose / podman) will run exactly as if you had cd’d into the project and typed make docker-run.

why it “just works”

mkcli dispatch
└─ make -C /abs/path/to/terraform-dev-server   docker-run
     · cwd for every recipe line = that dir
     · env = your current shell's env (DOCKER_HOST, etc.)

docker-compose looks for docker-compose.yml in the current working directory—which is now the project root thanks to -C, so relative paths / volumes resolve correctly. make doesn’t care what the recipe executes; it can be docker compose up, kubectl, terraform, whatever.

caveats & tips
	1.	docker installed + permissions
your user still needs to belong to the docker group (linux) or have Docker Desktop running (mac).
	2.	interactive targets
if your make recipe launches an interactive container (docker run -it …), it inherits the tty from mkcli, so prompts work.
	3.	env-file expectations
recipes that expect .env in the project dir are fine; that’s where the cwd now is. if they inspect PWD inside the container, nothing changes.
	4.	relative host paths inside recipes
because make -C switches cwd, any $(shell pwd) inside the Makefile points to the project root, not the original directory you invoked devvm from. that’s usually what you want; if you need the caller’s path, capture it in a variable before invoking devvm.

example target snippet

docker-run:
	@echo "starting stack…"
	docker compose up --build

invocation:

any/where $ devvm docker-run

result: same as running make docker-run in research/terraform-dev-server/.

bottom line

mkcli is just a location-agnostic bridge to make; whatever your Makefile can do—including Docker workflows—remains intact.