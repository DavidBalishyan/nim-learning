# 10. Write a program that prints the next 20 leap years
import std/times

proc isLeapYear(year: int): bool =
  (year mod 4 == 0 and year mod 100 != 0) or year mod 400 == 0

let currentYear: int = now().year
var year: int = currentYear + 1
var count: int = 0

echo "The next 20 leap years are:"
while count < 20:
  if isLeapYear(year):
    echo year
    inc count
  inc year