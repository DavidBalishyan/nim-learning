# 6. Write a program that asks the user for a number `n` 
# and gives them the possibility to choose between computing the sum
# and computing the product of 1,…,`n`
import strutils

stdout.write "Enter a number: "
let n: int = readLine(stdin).parseInt()
stdout.write "Choose sum (s) or product (p): "
let choice: string = readLine(stdin).strip()

var result: int
if choice == "s":
  result = 0
  for i in 1..n:
    result += i
  echo "The sum of 1 to ", n, " is: ", result
elif choice == "p":
  result = 1
  for i in 1..n:
    result *= i
  echo "The product of 1 to ", n, " is: ", result
else:
  echo "Invalid choice"