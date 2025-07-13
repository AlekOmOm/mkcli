# Makefile
#
# This Makefile is used to install the mkcli script.
#
# Usage:
#   make install
#

.PHONY: install uninstall help

install: ## install mkcli 
	chmod +x ./scripts/setup.sh
	./scripts/setup.sh

uninstall: ## uninstall mkcli
	rm -f /usr/local/bin/mkcli

help: ## show this help message
	@echo "Available commands:"
	@grep -h -E '^[a-zA-Z_-]+:[[:space:]]*.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[[:space:]]*.*## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort
