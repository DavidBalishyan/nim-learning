# 4. Write a program that asks the user for a number `n` 
# and prints the sum of the numbers 1 to `n`
import strutils

stdout.write "Enter a number: "
let n: int = readLine(stdin).parseInt()
var sum: int = 0
for i in 1..n:
    sum += i
echo "The sum of numbers from 1 to " & $n & " is: " & $sum
