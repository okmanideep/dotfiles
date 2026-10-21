.PHONY: install secrets

SECRETS_BIN := $(HOME)/.cache/dotfiles/bin/secrets
SECRETS_SOURCES := $(wildcard secrets/*.go) secrets/go.mod

install:
	./scripts/install.sh
	$(MAKE) secrets

secrets: $(SECRETS_BIN)
	mkdir -p "$(HOME)/.local/bin"
	ln -sfn "$(SECRETS_BIN)" "$(HOME)/.local/bin/secrets"

$(SECRETS_BIN): $(SECRETS_SOURCES)
	mkdir -p "$(dir $(SECRETS_BIN))" "$(HOME)/.local/bin"
	mise exec -- go build -C secrets -o "$(SECRETS_BIN)" .
	pkill -f "$(HOME)/.local/bin/secrets serve" || true
