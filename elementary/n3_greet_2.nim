# 3. Modify the previous program such that only the 
# users Alice and Bob are greeted with their names.
import strutils, os

# Greet the user by name, reading from stdin
proc greet_stdin(): void =
    stdout.write "Enter your name: "
    let str: string = stdin.readLine()
    if(str.toLower == "alice" or str.toLower == "bob"):
        echo "Hello, ", str, "!"
    else:
        echo "Only Bob and Alice are greeted"


# Greet the user by name, reading from command line arguments
proc greet_cmd(): void =
    let args: seq[string] = commandLineParams()
    if(args.len == 0):
        quit "Please provide your name as a cmdline argument"
    else:
        if(args[0].toLower == "alice" or args[0].toLower == "bob"):
            echo "Hello, " & args[0] & "!"
        else:
            echo "Only Bob and Alice are greeted"

when isMainModule:
    # greet_stdin()
    greet_cmd()
