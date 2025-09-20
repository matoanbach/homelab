# Lesson 7: Managing Text Files
- 7.1 Exploring Common Text Tools
- 7.2 Using `grep`
- 7.3 Applying Regular Expressions
- 7.4 Exploring `awk`
- 7.5 Using `sed`

## 7.1 Exploring Common Text Tools

### First and Last Lines
- Use `head` to show the first 10 lines of a text file
- Use `tail` to show the last 10 lines
- Use `-[n ]nn` to specify another number of lines

### Printing File Contents
- `cat` dumps text file contents on screen
    - `-A` shows all non-printable characters
    - `-b` number lines
    - `-s` suppresses repeated empty lines
- `tac` is doing the same, but in reversed order

### Other Common Tools
- `cut`: filter output: `cut -d: -f 1 /etc/passwd`
- `sort`: sort ouput: `cut -d: -f 1 /etc/passwd | sort`
- `tr`: translates: `echo hello | tr [:lower:] [:upper:]` 

## 7.2 Using `grep`
- `grep` is excellent to find text in files or in output
    - `ps aux | grep ssh`
    - `grep linda *`
    - `grep -i linda *`
    - `grep -A 5 linda /etc/passwd`
    - `grep -R root /etc`

## 7.3 Applying Regular Expressions
- Regular Expressions are text patterns that are used by tools like grep and others
- Always put your regex between single quotes
- Don't confuse regular expressions with globbing (shell wildcards)
- They look like file globbing, but they are not the same
    - `grep 'a*' a*`
- For use with specific tools only (`grep`, `vim`, `awk`, `sed`)    
- See `man 7 regex` for details

```bash
grep '^l' users
grep 'anna$' users
grep 'anna\b' users
grep 'b.*t' users
grep 'bo\{4\}t' users
grep -E '{ svm | vmx }' /proc/cpuinfo
```

## 7.4 Managing Text Files
- `awk` is powerfull text processing utility that is specialized in data extraction and reporting
- It can perform actions based on selectors
- Examples:

```bash
awk -F : '{print $4}' /etc/passwd
awk -F : '/linda/ {print $4}' /etc/passwd
awk -F : '{print $NF}' /etc/passwd
```

## 7.5 Using `sed`
- `sed` is a stream editor, used to search and transform text
- It can be used to search for text, and perform an operation on matching text
- Examples:
```bash
sed -n 5p /etc/passwd
sed -i s/old/new/g myfile
sed -i -e '2d' myfile
```

## Lesson 7 Lab: Working with Text Files
1. Use `head` and `tail` to display the fifth line of the file `/etc/passwd`

```bash
head -5 /etc/passwd | tail -1 
```

2. Use sed to display the fifth line of the file` /etc/passwd (-n 5p)`

```bash
sed -n 5p /etc/passwd
```

3. Use `awk` in a pipe to filter the last column out of the results of the command ps aux `'{ print $NF}'`

```bash
ps aux | awk {print $NF}
```

4. Use `grep` to show the names of all files in /etc that have lines that contain the text `'root'` as a word

```bash
grep 'root\b' * 2>/dev/null
```

5. Use `grep` to show all lines from all files in /etc that contain exactly 3 characters

```bash
grep '^...$' * 2>/dev/null
grep '.\{3\}' * 2>/dev/null
```

6. Use `grep` to find all files that contain the string `"alex"`, but make sure that `"alexander"` is not included in the result

```bash
grep '\balex\b' * 2>/dev/null
```