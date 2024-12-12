#include <iostream>
#include <sys/wait.h>
#include "suite.h"

int LaunchHTTPServer(); // Declaration of the function to launch the HTTP server

// Handler for the SIGCHLD signal
void HandleChildExitSignal(int signal) {
    std::cout << "[INFO] Signal SIGCHLD received. Handling child process exit.\n";
    pid_t childProcessId;
    int exitStatus;

    // Check the termination status of child processes
    while ((childProcessId = waitpid(-1, &exitStatus, WNOHANG)) > 0) {
        if (WIFEXITED(exitStatus)) {
            std::cout << "[INFO] Child process with PID " << childProcessId << " terminated normally.\n";
        }
    }
}

// Handler for the SIGINT signal
void HandleInterruptSignal(int signal) {
    std::cout << "[WARNING] Signal " << signal << " received. Initiating graceful shutdown.\n";
    pid_t activeProcessId;
    int terminationStatus;

    // Terminate all active child processes
    while ((activeProcessId = waitpid(-1, &terminationStatus, 0)) > 0) {
        if (WIFEXITED(terminationStatus)) {
            std::cout << "[INFO] Child process with PID " << activeProcessId << " terminated normally.\n";
        }
    }

    if (activeProcessId == -1) {
        std::cout << "[INFO] All child processes have been terminated.\n";
    }

    exit(EXIT_SUCCESS); // Exit the program
}

int main() {
    // Set signal handlers
    signal(SIGCHLD, HandleChildExitSignal); // Handler for child process termination
    signal(SIGINT, HandleInterruptSignal); // Handler for program termination signal (Ctrl+C)

    Suite computationSuite; // Object of Suite class for calculations
    int elementCount = 3;   // Number of elements
    double userInput;

    // Prompt the user to enter a value
    std::cout << "Please enter a value for x: ";
    std::cin >> userInput;

    // Output the result of the function computation
    std::cout << "Computation result of FuncA: " 
              << computationSuite.FuncA(elementCount, userInput) << std::endl;

    // Launch the HTTP server
    LaunchHTTPServer();

    return 0;
}
