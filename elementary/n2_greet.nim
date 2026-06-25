# 2. Write a program that asks the user for their name 
# and greets them with their name.
import strutils, os

# Greet the user by name, reading from stdin
proc greet_stdin(): void =
    stdout.write "Enter your name: "
    let str: string = stdin.readLine()
    echo "Hello, ", str, "!"

# Greet the user by name, reading from command line arguments
proc greet_cmd(): void =
    let args: seq[string] = commandLineParams()
    if(args.len == 0):
        quit "Please provide your name as a cmdline argument"
    else:
        echo "Hello, " & args[0] & "!"

when isMainModule:
    # greet_stdin()
    greet_cmd()
