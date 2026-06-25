# 11. Write a program that computes the sum of an alternating series where each element of the series is
# an expression of the form $((-1)^{k+1})/(2 * k-1)$ for each value of $k$ from 1 to a million,
# multiplied by 4

import std/math

var sum = 0.0
for k in 1..1_000_000:
  sum += 4.0 * pow(-1.0, float(k + 1)) / float(2 * k - 1)

echo sum
