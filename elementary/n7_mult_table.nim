# 7. Write a program that prints a multiplication table for numbers up to 12.
import strutils

const Colors = [
  "\e[31m",
  "\e[32m",
  "\e[33m",
  "\e[34m",
  "\e[35m",
  "\e[36m",
  "\e[91m",
  "\e[92m",
  "\e[93m",
  "\e[94m",
  "\e[95m",
  "\e[96m",
]

const Reset = "\e[0m"

for tableStart in countup(1, 12, 3):
  for i in 1..12:
    for j in tableStart .. min(tableStart + 2, 12):
      let prod = i * j
      let entry = $i & " x " & $j & " = " & $prod
      let color = Colors[(j - 1) mod Colors.len]
      stdout.write(color & alignLeft(entry, 15) & Reset)
    stdout.write("\n")
  stdout.write("\n")
