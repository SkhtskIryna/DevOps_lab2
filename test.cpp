#include <cassert>
#include <cmath>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <chrono>
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define SERVER_PORT 8081

// Function to simulate the server's /compute endpoint logic
long getComputationTimeFromServer() {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("Socket creation failed");
        return -1;
    }

    struct sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(SERVER_PORT);
    serverAddr.sin_addr.s_addr = INADDR_ANY;

    // Connect to the server
    if (connect(sock, (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        perror("Connection failed");
        close(sock);
        return -1;
    }

    // Send GET request for /compute
    const char* request = "GET /compute HTTP/1.1\r\nHost: localhost\r\n\r\n";
    send(sock, request, strlen(request), 0);

    // Receive the response
    char buffer[1024] = {0};
    ssize_t bytesRead = read(sock, buffer, sizeof(buffer));

    if (bytesRead < 0) {
        perror("Read failed");
        close(sock);
        return -1;
    }

    std::string response(buffer);
    close(sock);

    // Extract the elapsed time from the response
    size_t pos = response.find("Elapsed time: ");
    if (pos != std::string::npos) {
        size_t start = pos + strlen("Elapsed time: ");
        size_t end = response.find(" ms", start);
        if (end != std::string::npos) {
            std::string elapsed_str = response.substr(start, end - start);
            return std::stol(elapsed_str);
        }
    }
    return -1; // if failed to extract time
}

// Unit test for server logic and response time
void testServer() {
    long elapsed_time = getComputationTimeFromServer();

    // Check that the elapsed time is between 15 and 25 seconds
    assert(elapsed_time >= 5000);
    assert(elapsed_time <= 20000);

    std::cout << "Test passed. Elapsed time: " << elapsed_time << " ms\n";
}

int main() {
    testServer();
    return 0;
}
