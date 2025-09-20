## 5.1  Using looping constructs
### Task
- Write a script with the name `/root/lab51.sh` that makes a backup copy of files. The script should meet the following requirements:
    - The script prompts for the directory in which the files need to be backed up.
    - The script will make a backup of all files that have the extension `.txt`, but not of any other files.
    - The backup should have the `.txt` extension replaced with the `.bak` extension. so the backup of the file `myfile.txt` will use the name `myfile.bak`
- To test this script, create the files `testfile{1..9}.txt` in the directory `/tmp`

- Solution:

    ```bash
    #!/bin/bash
    read -p "What dir: " dir

    for file in ${dir}/*.txt
    do
        rename .txt .bak $file
    done
    ```

    ```bash
    #!/bin/bash
    read -p "What dir: " dir

    for file in ${dir}/*.txt
    do
        cp $file "${file%.txt}.bak"
    done
    ```

### Key Elements
- The `for` statement is used to evaluate a range of items.
- It's a good solution for evaluating multiple files, arguments, usernames, and more.
- To remove a part from a string, pattern matching operators can be used:
    - `${name##/*}` remove the longest match of the pattern `/*` from the left side.
    - `${name#/*}` remove the shortest match of the pattern `/*` from the left side.
    - `${name%%/*}` remove the longest match of the pattern `/*` from the right side.
    - `${name%/*}` remove the shortest match of the pattern `/*` from the right side.
- To create a range of items in one command, put the items between {}

## 5.2 Conditionally executing code
### Task
- Write a script with the name `/root/lab52.sh` that checks if a user exists. If the user exists, the script should print the login shell for that user. If the user doesn't exist, the script should just print a message that the user doesn't exist.
    - Ensure this script allows providing the user name as a command line argument.
    - If no command line argument was provided, the script should prompt for it.
    - The script should aslo be able to work on multiple users, if multiple names were provided.

- Solution:
    ```bash
    #! /bin/bash

    if [[ -z $1 ]]
    then
        read -p "what users: " users
    else
        users=$@
    fi

    for user in ${users}
    do
        if id $user &>/dev/null
        then
            echo "User -- ${user} -- has login shell: $(cat /etc/passwd | grep $user | awk -F: '{ print $NF }')"
        else
            echo "User ${user} does not exist"
        fi
    done
    ```

    ```bash
    #!/bin/bash

    if [ -z $1 ]
    then
        echo provide one or more user names
        read USERS
    else
        USERS=$@
    fi

    for i in ${USERS}
    do
        grep $i /etc/passwd &>/dev/null && echo user $i uses the shell $(grep $i /etc/passwd | awk -F: '{ print $NF}') || echo the user $i doesn't exist
        
    done

    ```