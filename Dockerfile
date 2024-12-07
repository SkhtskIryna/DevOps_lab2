FROM alpine AS build

# Install required packages
RUN apk add --no-cache build-base make automake autoconf git pkgconfig glib-dev gtest-dev gtest cmake

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool
    
# Clone the repository and build the project
WORKDIR /home/app
RUN git clone --branch branchHTTPserver https://github.com/SkhtskIryna/DevOps_lab2.git
WORKDIR /home/app/DevOps_lab2
RUN autoreconf --install
RUN ./configure
RUN cmake

FROM alpine

# Copy the built program from the build stage
COPY --from=build /home/app/DevOps_lab2/program /usr/local/bin/program

# Set the entry point
ENTRYPOINT ["/usr/local/bin/program"]
