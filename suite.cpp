#include "suite.h"
#include <cmath>

//Calculation of the amount
double Suite::FuncA(int n, double x) {
  double sum = 0; //The initial value of the amount

  for(int i = 1; i <= n; ++i) {
       sum += ((std::pow(-1, i) * std::tgamma(2*i+1)) /
         ((1 - 2*i) * std::tgamma(i+1) * std::tgamma(i+1) * std::pow(4, i)) *
         std::pow(x, i));
  }
  return sum;
}
