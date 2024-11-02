#include <cassert>
#include <cmath>
#include <iostream>
#include "../suite.h"

void testFuncA() {
    Suite suite;
    double result = suite.FuncA(5, 1.0);
    std::cout << "Result: " << result << std::endl;

    double expected = 0.425781;
    double epsilon = 1e-6;
    assert(fabs(result - expected) < epsilon);
}

int main() {
    testFuncA();
    return 0;
}
