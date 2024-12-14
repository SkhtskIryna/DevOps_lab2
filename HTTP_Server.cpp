#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/sendfile.h>
#include <sys/stat.h>
#include <random>
#include <netinet/in.h>
#include <string.h>
#include <vector>
#include <errno.h>
#include <chrono>
#include <algorithm>
#include <thread>
#include "suite.h"
#include "HTTP_Server.h"

#define PORT 8081

// HTTP headers
#define HTTP_200HEADER "HTTP/1.1 200 OK\r\n"
#define HTTP_404HEADER "HTTP/1.1 404 Not Found\r\n"
#define HTTP_201HEADER "HTTP/1.1 201 Created\r\n"
#define HTTP_400HEADER "HTTP/1.1 400 Bad Request\r\n"
#define HTTP_404HEADER "HTTP/1.1 404 Not Found\r\n"

int CreateHTTPserver() {
    int connectionSocket, clientSocket, pid; 
    struct sockaddr_in address;
    int addrlen = sizeof(address);
    
    // Create the server socket

    if ((connectionSocket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket creation failed\n");
        exit(EXIT_FAILURE);
    }
    
    // Configure the server address
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    memset(address.sin_zero, '\0', sizeof(address.sin_zero));
    
    // Bind the socket to the address
    if (bind(connectionSocket, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("Socket bind failed\n");
        close(connectionSocket);
        exit(EXIT_FAILURE);
    }
    
    // Listen for incoming connections
    if (listen(connectionSocket, 10) < 0) {
        perror("Socket listen failed\n");
        exit(EXIT_FAILURE);
    }
    
    // Main server loop: wait for and handle client connections
    while(1) {
        printf("\nWaiting for a new connection...\n\n");
        
        // Accept a new client connection
        if ((clientSocket = accept(connectionSocket, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
            perror("Error accepting client connection\n");
            exit(EXIT_FAILURE);
        }

        // Create a child process to handle the client request
        pid = fork();
        if (pid < 0) {
            perror("Fork failed\n");
            exit(EXIT_FAILURE);
        }   

        if (pid == 0) { // Child process: handle the client request
            char buffer[30000] = {0};
            char* ptrBuffer = &buffer[0];
            
            // Read client request
            int iBytesRead = read(clientSocket, ptrBuffer, 30000);
            printf("\nClient message of %d bytes:\n%s\n", iBytesRead, buffer);
            
            if (iBytesRead == 0) {
                printf("Client closed connection prematurely\n");
                close(clientSocket);
                continue;
            }

            printf("\nParsing client request...\n");

            // Parse HTTP request method (e.g., GET, PUT)
            char strHTTP_requestMethod[10] = {0};
            char* pch = strchr(ptrBuffer, ' ');
            strncpy(strHTTP_requestMethod, ptrBuffer, pch - ptrBuffer);
            printf("Client method: %s\n", strHTTP_requestMethod);
            
            ptrBuffer = pch + 1;

            // Parse HTTP request path (e.g., /index.html)
            char strHTTP_requestPath[200] = {0};
            pch = strchr(ptrBuffer, ' ');
            strncpy(strHTTP_requestPath, ptrBuffer, pch - ptrBuffer);
            printf("Client requested path: %s\n", strHTTP_requestPath);
            
            // Parse the file extension (e.g., .jpg, .html)
            char strHTTPreqExt[200] = {0};
            pch = strrchr(strHTTP_requestPath, '.');
            if (pch != NULL) strcpy(strHTTPreqExt, pch + 1);

            char strFilePath[500] = {0};
            char strResponse[500] = {0};

            // Handle different request paths and methods
            if (!strcmp(strHTTP_requestMethod, "GET")) {
                if (!strcmp(strHTTP_requestPath, "/")) {
                    // Serve the index.html file if the path is "/"
                    sprintf(strFilePath, "./index.html");
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: text/html\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                } else if (!strcmp(strHTTP_requestPath, "/compute")) {
                    // Handle the /compute request by performing heavy computation
                    auto t1 = std::chrono::high_resolution_clock::now();    

                    std::vector<double> aValues;
                    aValues.reserve(2000000);
                    Suite computationSuite;
                    std::mt19937 mtre {123};
                    std::uniform_int_distribution<int> distr {5, 25};

                    for (int i = 0; i < 2000000; i++) {
                        aValues.push_back(computationSuite.FuncA(distr(mtre)));
                    }

                    for (int i = 0; i < 1200; i++) {
                        sort(begin(aValues), end(aValues));
                    }
                    
                    auto t2 = std::chrono::high_resolution_clock::now();
                    auto int_ms = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);

                    int iMS = int_ms.count();

                    char strTimeEllapsed[20];
                    sprintf(strTimeEllapsed, "%i", iMS);

                    sprintf(strResponse, "%sContent-type: text/html\r\nContent-Length: %ld\r\n\r\n", HTTP_200HEADER, strlen(strTimeEllapsed));

                    ssize_t bytesWritten = write(clientSocket, strResponse, strlen(strResponse));
		    if (bytesWritten < 0) {
    			perror("Write failed");
		    }
                    printf("\nResponse: \n%s\n", strResponse);

                    bytesWritten = write(clientSocket, strTimeEllapsed, strlen(strTimeEllapsed));
                    if (bytesWritten < 0) {
                        perror("Write failed");
                    }
		    printf("Elapsed time: %s ms\n", strTimeEllapsed);
                } else if ((!strcmp(strHTTPreqExt, "JPG")) || (!strcmp(strHTTPreqExt, "jpg"))) {
                    // Serve image file if the request is for a JPG
                    sprintf(strFilePath, ".%s", strHTTP_requestPath);
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: image/jpeg\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                } else if (!strcmp(strHTTPreqExt, "ico")) {
                    // Serve favicon.ico if requested
                    sprintf(strFilePath, "./img/favicon.png");
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: image/vnd.microsoft.icon\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                } else if (!strcmp(strHTTPreqExt, "js")) {
                    // Serve JavaScript file if requested
                    sprintf(strFilePath, ".%s", strHTTP_requestPath);
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: text/javascript\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                } else if (!strcmp(strHTTPreqExt, "png")) {
                    // Serve PNG image file if requested
                    sprintf(strFilePath, ".%s", strHTTP_requestPath);
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: image/png\r\nCache-Control: max-age=3600\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                } else {
                    // Default response for unknown mime types
                    sprintf(strFilePath, ".%s", strHTTP_requestPath);
                    sprintf(strResponse, "%s%s", HTTP_200HEADER, "Content-Type: text/plain\r\n");

                    SendGETresponse(clientSocket, strFilePath, strResponse);
                }
            } else if (!strcmp(strHTTP_requestMethod, "PUT")) {
                // Handle PUT request to upload data
                ptrBuffer = strstr(buffer, "\r\n\r\n");
                ptrBuffer += 4;

                if (ptrBuffer) {
                    sprintf(strFilePath, ".%s", strHTTP_requestPath);
                    sprintf(strResponse, "%s", HTTP_201HEADER);

                    SendPUTresponse(clientSocket, strFilePath, ptrBuffer, strResponse);
                }
            }

            // Close the client connection
            close(clientSocket);
            return 0;
        } else { // Parent process branch
            printf("Forked a child process with PID: %d \n", pid);
            close(clientSocket);
        }
    }

    // Close the server connection socket
    close(connectionSocket);
    return 0;
}

void SendPUTresponse(int fdSocket, char* strFilePath, char* strBody, char* strResponse) {
    // Open the file for writing, create or truncate it
    int fdFile = open(strFilePath, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (fdFile < 0) {
        // Generate and send an HTTP 400 response if the file cannot be opened
        sprintf(strResponse, "%s", HTTP_400HEADER);
        ssize_t bytesWritten = write(fdSocket, strResponse, strlen(strResponse));
        if (bytesWritten < 0) {
       	     perror("Write failed");
        }
        // Log the error
        printf("\nError: Unable to save file path: %s (error code: %d)\n", strFilePath, fdFile);
        printf("Response sent to client:\n%s\n", strResponse);
        return;
    }

    // Log the response before sending it
    printf("\nResponse to client:\n%s\n", strResponse);
    int iRes = write(fdSocket, strResponse, strlen(strResponse));
    if (iRes < 0) {
        // Log the error if unable to write to the client socket
        printf("\nError: Unable to write to client socket (error code: %d)\n", iRes);
        return;
    }

    // Write the body content to the file
    iRes = write(fdFile, strBody, strlen(strBody));
    if (iRes < 0) {
        // Log the error if unable to write to the file
        printf("\nError: Unable to write to file: %s (error code: %d)\n", strFilePath, fdFile);
        return;
    }

    // Close the file after successful write
    close(fdFile);
}

void SendGETresponse(int fdSocket, char* strFilePath, char* strResponse) {
    // Open the file in read-only mode
    int fdFile = open(strFilePath, O_RDONLY);
    if (fdFile < 0) {
        // Send an HTTP 404 response if the file cannot be opened
        sprintf(strResponse, "%s", HTTP_404HEADER);
        ssize_t bytesWritten = write(fdSocket, strResponse, strlen(strResponse));
        if (bytesWritten < 0) {
             perror("Write failed");
        }

        // Log the error and response
        printf("\nError: Unable to open file path: %s (error code: %d)\n", strFilePath, fdFile);
        printf("Response sent to client:\n%s\n", strResponse);
        return;
    }
     
    // Get file metadata, such as size and block size
    struct stat stat_buf;
    fstat(fdFile, &stat_buf);
    int file_total_size = stat_buf.st_size;
    int block_size = stat_buf.st_blksize;
    
    // Append the Content-Length header to the response
    char* strOffset = strResponse + strlen(strResponse);
    sprintf(strOffset, "Content-Length: %d\r\n\r\n", file_total_size);

    // Log the response header
    printf("\nResponse header:\n%s\n", strResponse);
    int iRes = write(fdSocket, strResponse, strlen(strResponse));
    if (iRes < 0) {
        // Log the error if unable to write to the client socket
        printf("\nError: Unable to write to client socket (error code: %d)\n", iRes);
        return;
    }
		
    // Send the file content in chunks using sendfile()
    while (file_total_size > 0) {
        int iToSend = (file_total_size < block_size) ? file_total_size : block_size;
        int done_bytes = sendfile(fdSocket, fdFile, NULL, iToSend);
        if (done_bytes < 0) {
            // Log the error if unable to send the file content
            printf("\nError: Unable to write file content to client socket (error code: %d)\n", done_bytes);
            return;
        }
		  
        file_total_size -= done_bytes; // Update the remaining file size
    }

    // Close the file descriptor
    close(fdFile);
}
