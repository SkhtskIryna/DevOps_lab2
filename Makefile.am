PACKAGE = program
VERSION = 1.0
PACKAGE_BUGREPORT = foxira242@gmail.com

AUTOMAKE_OPTIONS = foreign
bin_PROGRAMS = program
program_SOURCES = main.cpp suite.cpp

CTRLF_DIR = $(CURDIR)/deb/DEBIAN
CTRLF_NAME = $(CTRLF_DIR)/control

uninstall-hook:
	rm -d $(datarootdir)/$(PACKAGE)/data
	rm -d $(datarootdir)/$(PACKAGE)

.PHONY: deb debug

debug:
	@echo "Package: $(PACKAGE)"
	@echo "Version: $(VERSION)"
	@echo "Bug Report: $(PACKAGE_BUGREPORT)"
	@echo "Source Files: $(program_SOURCES)"

deb:
	mkdir -p $(CTRLF_DIR)
	echo Package: $(PACKAGE) > $(CTRLF_NAME)
	echo Version: $(VERSION) >> $(CTRLF_NAME)
	echo Architecture: all >> $(CTRLF_NAME)
	echo Maintainer: $(PACKAGE_BUGREPORT) >> $(CTRLF_NAME)
	echo -n "Description: " >> $(CTRLF_NAME)
	echo "calculation software" >> $(CTRLF_NAME)
	make DESTDIR=$(CURDIR)/deb install
