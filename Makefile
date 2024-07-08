SHELL=/bin/bash
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
