# 8. Write a program that prints *all* prime numbers.
# NOTE: Compile with `nim c --path:include ./elementary/prime_numbers.nim`

import std/cmdline
include bigint

proc isPrime(x: BigInt): bool =
  let zero = initBigInt(0)
  let two = initBigInt(2)
  if x < two: return false
  if x mod two == zero: return x == two
  var i = initBigInt(3)
  while i * i <= x:
    if x mod i == zero:
      return false
    i = i + two
  true

let n = initBigInt(paramStr(1))
let one = initBigInt(1)
var i = initBigInt(2)
while i <= n:
  if isPrime(i):
    echo i
  i = i + one
