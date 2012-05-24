PREFIX=/usr/local
DESTDIR=

INSTDIR=$(DESTDIR)$(PREFIX)
INSTBIN=$(INSTDIR)/bin

all:
	@echo do nothing. try one of the targets:
	@echo
	@echo "  install"
	@echo "  uninstall"

install:
	test -d $(INSTDIR) || mkdir -p $(INSTDIR)
	test -d $(INSTBIN) || mkdir -p $(INSTBIN)

	install -m 0755 log.sh $(INSTBIN)

uninstall:
	rm -f $(INSTBIN)/log.sh

.PHONY: all install uninstall
