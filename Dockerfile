FROM alpine AS build

# Install required packages for building the project
RUN apk add --no-cache \
    bash \                  
    autoconf \               
    automake \              
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
    g++                   

# Copy the deb directory to the /opt/$(PACKAGE) folder in the container
COPY . /home/DevOps_lab2
# Clone the repository from GitHub, specifying the branch to build
WORKDIR /home/DevOps_lab2

# Run the build commands to configure and compile the project
RUN aclocal              
RUN autoconf              
RUN automake --add-missing            
RUN ./configure
RUN pkg-config --cflags --libs gtest glib-2.0        
RUN make clean
RUN make VERBOSE=1

# List the files in the project directory to verify the build
RUN ls -la /home/DevOps_lab2

FROM alpine

# Copy the compiled program from the build stage to the runtime image
COPY --from=build /home/DevOps_lab2/program /usr/local/bin/program

# Ensure the program is executable
RUN chmod +x /usr/local/bin/program

# Set the entry point to run the program when the container starts
ENTRYPOINT ["/usr/local/bin/program"]

RUN ls -la /usr/local/bin
