VERSION_TXT    := version.txt
FILE_VERSION   := $(shell cat $(VERSION_TXT))
VERSION        ?= $(FILE_VERSION)

SHELL = /bin/bash
FILES = autokubeconfig.sh autokubectl.sh showkubectl.sh

.ONESHELL:

all:

install:
	install -m 644 $(FILES) /etc/profile.d/

install-user:
	echo 'source $(PWD)/autokubeconfig.sh' >> ~/.bashrc
	echo 'source $(PWD)/autokubectl.sh' >> ~/.bashrc
	echo 'source $(PWD)/showkubectl.sh' >> ~/.bashrc

help:
	source autokubectl.sh
	autokubectl_help HELP

test:
	source autokubectl.sh
	autokubectl flush
	source autokubectl.sh
	autokubectl_test

release: is-git-clean
	git pull --tags
	git commit -am "Built release $(VERSION)" $(VERSION_TXT)
	git tag $(VERSION)
	git push origin main --tags

is-git-clean:
	@if git status --porcelain | grep '^[^?]' | grep -vq $(VERSION_TXT); then
		git status
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n"
		exit 1
	fi

