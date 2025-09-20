# Lesson 23: Automating with Bash Scripts
- 23.1 Understanding Bash Scripts
- 23.2 Exploring Essential Script Components
- 23.3 Executing Conditional Code with `if` and `test`
- 23.4 Using `for` and `while`

## 23.1 Understanding Bash Scripts
### Understanding Shell Scripts
- A shell script is just a text file with commands you'd normally type at the prompt, saved so you can run them all at once
- People write shell scripts to automoate everyday tasks (backups, starting services, checking logs, etc.) instead of typing each command by hand
- At its core, a script is just a list of commands that run one after the other
- You can use variables (like $USER or custom ones you define) so the same script can work on different machines or with different inputs
- You can also add simple logic - loops (for, while) and checks (if, case) - to make the script only do certain things when certain conditions are met

### Bash Scripts Compared
- They're easy to write and anyone can run them - every Linux system already has a shell to interpret them.
- If you only use built-in shell commands (no external programs), the script runs very quickly since nothing extra needs loading.
- There's no compilation step: you just save the text file, make it executable, and run it
- When tasks get more complicated (heavy data processing, complex logic, or interacting with APIs), people often switch to languages like Python - or use automation tools like Ansible - because they offer richer libraries and features

## 23.2 Exploring Essential Script Components
### Exploring Shell Script Components
- `chmod +x myscript` to make your script file executable, so you can run it directly
- You can name it anything, but using a .sh extension is a common convention
- At the very top of the file, include a shebang line like `#!/bin/bash`. This tells the system to use Bash to run your commands
- Start comments with `#`

### Using Arguments and Variables
- Why use variable? - They let your script adapt to different environments or inputs without changing the code
- Defining a variable inside the script:
```bash
color=red
echo $color
``` 
- Passing arguments when you run the script. Inside the script, "$1" holds the first argument (hello)
```bash
./myscript.sh hello
```
- Example using an argument:
```bash
#!/bin/bash
name=$1
echo "Hello, $name!"
```
## 23.3 Executing Conditional Code with if and test
### Using `test`
- The `test` command (or its shorthand [ ... ]) lets you check conditions in a script, for example:
- File properties:
    - [ -f /path/to/file ] -> true if that file exists and is a regular file
    - [ -d /path/to/file ] -> true if that directory exists
- String checks:
    - [ "$str" = "hello" ] -> true if the variable $str exactly equals "hello"
    - [ -z "$str" ] -> true if $str is empty (zero length)
- Integer comparison:
    - [ "$n" -gt 10 ] -> true if the number is $n is greater than 10
    - [ "$n" -eq 5 ] -> true if $n equals 5

- In practice, you almost always see it inside an if..then..else block. For example:
```bash
#!/bin/bash
if [-f /etc/passwd ]; then
    echo "/etc/passwd exists"
else
    echo "/etc/passwd is missing"
fi
```

## 23.4 Usign for and while
### Understanding for and while
- `while` loop runs a block of code repeatedly as long as a condition stays true
    - example: check if a file exists; keep waiting until it appears
- `for` loop go through a list of items one by one
    - common uses:
        - loop over every word or value in a variable
        - loop oever every file in a folder that matches a pattern (e.g. all *.log files)

## Lesson 23 Lab: Writing Shell Scripts
- Write a script that makes a copy of each file that has *.txt extension. The copy should be named filename.txt.bak. After making the copy, the script should move it to the /tmp directory
- While running the script, the directory where it should look for the files should be provided as an argument
- If no argument was provided, the script should stop with exit code 9

```bash
#!/bin/bash

if [ -z $1 ]
then
    echo No directory provided. Exiting...
    exit
else
    dir=$1
fi

for file in /dir/*.txt
do
    cp $file $file.bak
    mv $file.bak /tmp
done
```