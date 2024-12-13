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
RUN git clone --branch branchHTTPservMulti https://github.com/SkhtskIryna/DevOps_lab2.git
WORKDIR /home/app/DevOps_lab2

# Configure and build the project
RUN autoreconf -fiv
RUN ./configure
RUN cmake
RUN make clean
RUN make

RUN ls -la /home/app/DevOps_lab2

FROM alpine

# Copy the built program from the build stage
COPY --from=build /home/app/DevOps_lab2/program /usr/local/bin/program

# Ensure the binary is executable
RUN chmod +x /usr/local/bin/program

# Set the entry point
ENTRYPOINT ["/usr/local/bin/program"]

RUN ls -la /usr/local/bin

