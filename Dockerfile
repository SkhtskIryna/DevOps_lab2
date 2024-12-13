FROM alpine AS build

# Install required packages for building
RUN apk add --no-cache \
    autoconf \
    m4 \
    make \
    perl \
    build-base \
    automake \
    git \
    pkgconfig \
    glib-dev \
    gtest-dev \
    gtest \
    cmake \
    libstdc++ \
    g++

# Clone the repository and build the project
WORKDIR /home/app
RUN git clone --branch branchHTTPserver https://github.com/SkhtskIryna/DevOps_lab2.git
WORKDIR /home/app/DevOps_lab2

# Regenerate the build system using autoreconf
RUN autoreconf -i  # Automatically runs autoconf, aclocal, autoheader, and automake

# Configure and build the project
RUN ./configure
RUN cmake
RUN make clean
RUN make

# Ensure the program binary exists
RUN test -f /home/app/DevOps_lab2/program

FROM alpine

# Install runtime dependencies, including libstdc++ and g++
RUN apk add --no-cache \
    libstdc++ \
    g++

# Copy the built program from the build stage
COPY --from=build /home/app/DevOps_lab2/program /usr/local/bin/program

# Ensure the binary is executable
RUN chmod +x /usr/local/bin/program

# Set the entry point
ENTRYPOINT ["/usr/local/bin/program"]

