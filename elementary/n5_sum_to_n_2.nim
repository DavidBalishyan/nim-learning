# 5. Modify the previous program such that only multiples of  3 or 5 are considered in the sum,
# e.g. 3, 5, 6, 9, 10, 12, 15 for `n` = 17
import strutils

stdout.write "Enter a number: "
let n: int = readLine(stdin).parseInt()
var sum: int = 0
for i in 1..n:
    if i mod 3 == 0 or i mod 5 == 0:
        sum += i
echo "The sum of multiples of 3 or 5 from 1 to " & $n & " is: " & $sum