FROM alpine AS build

# Install required packages
RUN apk add --no-cache build-base make automake autoconf git pkgconfig glib-dev gtest-dev gtest cmake
RUN apt-get update && \
    apt-get install -y autoconf m4 make perl

# Clone the repository and build the project
WORKDIR /home/app
RUN git clone --branch branchHTTPserver https://github.com/SkhtskIryna/DevOps_lab2.git
WORKDIR /home/app/DevOps_lab2
RUN autoconf
RUN ./configure
RUN cmake .
RUN make

# Ensure the program binary exists
RUN test -f /home/app/DevOps_lab2/program

FROM alpine

# Copy the built program from the build stage
COPY --from=build /home/app/DevOps_lab2/program /usr/local/bin/program

# Ensure the binary is executable
RUN chmod +x /usr/local/bin/program
# Set the entry point
ENTRYPOINT ["/usr/local/bin/program"]
