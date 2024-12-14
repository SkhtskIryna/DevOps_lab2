PACKAGE = program
VERSION = 1.0
PACKAGE_BUGREPORT = foxira242@gmail.com

# Specify the program to build
bin_PROGRAMS = program

# Specify the source files for the program
program_SOURCES = main.cpp suite.cpp HTTP_Server.cpp suite.h HTTP_Server.h

# Additional linker flags
program_LDFLAGS = -static

# Automake options
AUTOMAKE_OPTIONS = foreign subdir-objects

# Files to clean
CLEANFILES = $(bin_PROGRAMS)

# Ensure phony targets are not confused with files
.PHONY: deb debug docker docker-push clean

# Target for debugging information
debug:
	@echo "Package: $(PACKAGE)"
	@echo "Version: $(VERSION)"
	@echo "Bug Report: $(PACKAGE_BUGREPORT)"
	@echo "Source Files: $(program_SOURCES)"

# Create Debian package structure and control file
deb:
	mkdir -p $(CURDIR)/deb/DEBIAN
	echo "Package: $(PACKAGE)" > $(CURDIR)/deb/DEBIAN/control
	echo "Version: $(VERSION)" >> $(CURDIR)/deb/DEBIAN/control
	echo "Architecture: all" >> $(CURDIR)/deb/DEBIAN/control
	echo "Maintainer: $(PACKAGE_BUGREPORT)" >> $(CURDIR)/deb/DEBIAN/control
	echo "Description: Calculation software" >> $(CURDIR)/deb/DEBIAN/control
	make DESTDIR=$(CURDIR)/deb install

# Build a Docker image
docker:
	@echo "Building Docker image..."
	echo "FROM ubuntu:latest" > Dockerfile
	echo "MAINTAINER $(PACKAGE_BUGREPORT)" >> Dockerfile
	echo "COPY deb /opt/$(PACKAGE)" >> Dockerfile
	echo "RUN apt-get update && apt-get install -y build-essential g++ make" >> Dockerfile
	echo "RUN apt-get clean" >> Dockerfile
	echo "ENTRYPOINT [\"/opt/$(PACKAGE)/bin/program\"]" >> Dockerfile
	docker build -t $(PACKAGE):$(VERSION) .

# Push the Docker image to DockerHub
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

