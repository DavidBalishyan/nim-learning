# 9. Write a guessing game where the user has to guess a secret number.
# After every guess the program tells the user whether their number was too large or too small.
# At the end the number of tries needed should be printed. 
# It counts only as one try if they input the same number multiple times consecutively.
import std/random
import strutils

randomize() # Initialize the default rng
let num: int = rand(100)
# echo "[DEBUG] The number is ", num

var tries = 0
var prevGuess = -1

while true:
  stdout.write "Your guess: "
  let guess = stdin.readLine().parseInt()

  if guess != prevGuess:
    inc tries
  prevGuess = guess

  if guess == num:
    echo "You're right"
    break
  elif guess < num:
    echo "Go higher"
  else:
    echo "Go lower"

echo "Number of tries: ", tries