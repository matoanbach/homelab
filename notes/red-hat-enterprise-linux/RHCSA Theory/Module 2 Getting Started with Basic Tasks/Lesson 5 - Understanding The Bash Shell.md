## 5.1 Using I/O Redirection and Piping

- Redirection uses STDIN, STDERR and STDOUT to work with command input and output in a flexible way
    - `>` sends the output to a file
    - `>>` append the output to a file
    - `2> /dev/null` redirect file descriptor 2 to /dev/nul
    - `<` takes input from a file
- In piping, the STDOUT of the first command is used as STDIN of the second command

## 5.2 Exploring History
- There are different ways to repeat commands from history
    - The up arrow key allows you to scroll backwards through history
    - `Ctrl-r` performs a reverse search based on the pattern entered
    - `!nn` repears a command from history based on its number
    - `!a` repeats the last command tgat starts with letter a

### Managing History
- `history -w` synchronizes the current history from memory to history file
- `history -c` clears current history, don't forget to also use `history -w` when you want to remove everything
- `hsitory -d nn` removes line `nn` from current history

## 5.3 Using Keyboard Shortcuts

- `Ctrl-c` quits the current interactive process
- `Ctrl-d` sends an end-of-file character to the current interactive process
- `Ctrl-a` moves cursor to start of current line
- `Ctrl-e` moves cursor to end of current line
- `Ctrl-r` reverse search in history
- `Ctrl-u` clears screen
- `Alt-b` moves cursor one word backward
- `Alt-f` moves cursor one word forward

## 5.4 Introducing Shell Expansion

- Shell expansion allows for more efficient command line use
- Globbing expands filenames based on wildcards
    - `ls *`
    - `ls ?*`
    - `ls [a-e]*`
- Other types of expansion also exist
    - Brace expansion: `touch file{1..9}` or `useradd {lisa,linda,anna}`
    - Tilde expansion: `cd ~`
    - Command substitution: `ls -l ${which ls}`
    - varialbe substitution: `echo $PATH`

## 5.5 Understanding Special Characters
- In expansion, special characters are interpreted by the shell to attribute a special meaning to the variables
- In escaping, this special meaning is taken away
    - Double quotes suppress globbing and shell expansion but do allow command and variable substitution
    - Single quotes take away the special meaning of any characters
    - Backslash protects the following characters only from expansion

## 5.8 Tuning the Bash Environment

### Understanding Startup Files

- `/etc/profile` is the generic Bash startup file containing all system settings that are processed in a login shell
- `/etc/bashrc` is porcessed while opening a subshell
- `~/.bash_profile` is the user-specific version of `/etc/profile`
- `~/.bashrc` is the user-specific version of `/etc/bashrc`
- Use custom startup files to make settings like variables and alias persistent