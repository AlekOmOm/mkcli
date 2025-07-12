#!/usr/bin/env bash
set -e
MKCLI_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)/mkcli"
chmod +x "$MKCLI_SRC"
sudo ln -sf "$MKCLI_SRC" /usr/local/bin/mkcli
echo "mkcli installed"
