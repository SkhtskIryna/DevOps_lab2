PACKAGE = program
VERSION = 1.0
PACKAGE_BUGREPORT = foxira242@gmail.com

AUTOMAKE_OPTIONS = foreign subdir-objects

bin_PROGRAMS = program
program_SOURCES = main.cpp suite.cpp

bin_PROGRAMS += test
test_SOURCES = tests/main_test.cpp suite.cpp

CTRLF_DIR = $(CURDIR)/deb/DEBIAN
CTRLF_NAME = $(CTRLF_DIR)/control

uninstall-hook:
	rm -d $(datarootdir)/$(PACKAGE)/data
	rm -d $(datarootdir)/$(PACKAGE)

.PHONY: deb debug

.PHONY: deb debug docker docker-push

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
	@echo "Creating Docker image..."
	make docker

docker:
	@echo "Building Docker image..."
	echo "FROM ubuntu:latest" > Dockerfile
	echo "MAINTAINER $(PACKAGE_BUGREPORT)" >> Dockerfile
	echo "COPY deb /opt/$(PACKAGE)" >> Dockerfile
	echo "RUN apt-get update && apt-get install -y ./opt/$(PACKAGE)" >> Dockerfile
	echo "ENTRYPOINT [\"/opt/$(PACKAGE)/bin/program\"]" >> Dockerfile
	docker build -t $(PACKAGE):$(VERSION) .

docker-push:
	@echo "Pushing Docker image to DockerHub..."
	@if [ -z "$(DOCKER_USER)" ] || [ -z "$(DOCKER_PASS)" ]; then \
		echo "Please set DOCKER_USER and DOCKER_PASS environment variables"; \
		exit 1; \
	fi
	echo "$(DOCKER_PASS)" | docker login -u "$(DOCKER_USER)" --password-stdin
	docker tag $(PACKAGE):$(VERSION) $(DOCKER_USER)/$(PACKAGE):$(VERSION)
	docker push $(DOCKER_USER)/$(PACKAGE):$(VERSION)
	docker logout
	echo Maintainer: $(PACKAGE_BUGREPORT) >> $(CTRLF_NAME)
	echo -n "Description: " >> $(CTRLF_NAME)
	echo "calculation software" >> $(CTRLF_NAME)
	make DESTDIR=$(CURDIR)/deb install
