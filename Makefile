VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)

SHELL         ?= /bin/bash
FILES_SH      = autokubeconfig.sh autokubectl.sh showkubectl.sh
FILES_PY      = autokubectl.py
PROFILE_D_DIR ?= /etc/profile.d
BIN_DIR       ?= /usr/local/bin

.ONESHELL:

all: autokubectl.sh

autokubectl.sh: autokubectl.sh.in
	sed -e 's|^BIN_PATH=.*|BIN_PATH=$(BIN_DIR)/autokubectl.py|' $< > $@

install: autokubectl.sh
	install -m 644 $(FILES_SH) $(PROFILE_D_DIR)/
	install -m 755 $(FILES_PY) $(BIN_DIR)/

install-user: autokubectl.sh
	@for rc in ~/.bashrc ~/.zshrc; do
		if ! [ -e ~/.bashrc ] && ! [ -e ~/.zshrc ]; then
			rc=~/.profile
		fi
		if [ -e $$rc ] && ! grep -q autokubeconfig.sh $$rc; then
			echo Installing in $$rc
			echo
			echo '## Installed by Autokubectl: https://github.com/caruccio/autokube'
			echo 'source $(PWD)/autokubeconfig.sh' >> $$rc
			echo 'source $(PWD)/autokubectl.sh' >> $$rc
			echo 'source $(PWD)/showkubectl.sh' >> $$rc
		fi
	done

#help:
#	source autokubectl.sh
#	autokubectl_help HELP

#test:
#	source autokubectl.sh
#	autokubectl.py test

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

