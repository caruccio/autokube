SHELL=/bin/bash

all:

install:
	install -m 644 autokubeconfig.sh autokubectl.sh showkubectl.sh /etc/profile.d/

help:
	. autokubectl.sh && autokubectl_help HELP

test:
	source autokubectl.sh && autokubectl_test
