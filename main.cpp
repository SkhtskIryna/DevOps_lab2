#include <iostream>
#include "suite.h"

int main() {
  Suite suite;
  int n = 5; //number of elements
  double x;
 
  std::cout << "Enter x";
  std::cin >> x;

  std::cout << "FuncA result: " << suite.FuncA(n, x) << std::endl;

  return 0;
}
