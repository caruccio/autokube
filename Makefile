VERSION_TXT    = version.txt
FILE_VERSION   = $(shell cat $(VERSION_TXT))
VERSION        = $(FILE_VERSION)

SHELL         = /bin/bash
FILES_SH      = autokubeconfig.sh autokubectl.sh showkubectl.sh
FILES_PY      = autokubectl.py
PROFILE_D_DIR = /etc/profile.d
BIN_DIR       = $(shell pwd)

.ONESHELL:

all:

install:
	install -m 644 $(FILES_SH) $(PROFILE_D_DIR)/

install-user:
	@for rc in ~/.bashrc ~/.zshrc; do
		if ! [ -e ~/.bashrc ] && ! [ -e ~/.zshrc ]; then
			rc=~/.profile
		fi
		if [ -e $$rc ] && ! grep -q autokubeconfig.sh $$rc; then
			echo Installing in $$rc
			{
				echo
				echo '## Installed by Autokubectl: https://github.com/caruccio/autokube'
				echo '[ -e "$(BIN_DIR)/autokubeconfig.sh" ] && source "$(BIN_DIR)/autokubeconfig.sh"'
				echo '[ -e "$(BIN_DIR)/autokubectl.sh" ] && source "$(BIN_DIR)/autokubectl.sh"'
				echo '[ -e "$(BIN_DIR)/showkubectl.sh" ] && source "$(BIN_DIR)/showkubectl.sh"'
			} >> $$rc
		else
			echo "Already intalled in $$rc"
		fi
	done

test:
	bash ./test.sh

release: is-git-clean
	git pull --tags
	git commit -m "Built release $(VERSION)" $(VERSION_TXT)
	git tag $(VERSION)
	git push origin main --tags

is-git-clean:
	@if git status --porcelain | grep '^[^?]' | grep -vq $(VERSION_TXT); then
		git status
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n"
		exit 1
	fi

