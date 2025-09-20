# Lesson 10: Scuring Files with Permissions

- 10.1 Understanding Ownership
- 10.2 Chaning File Ownership
- 10.3 Understanding Basic Permissions
- 10.4 Managing Basic Permission
- 10.5 Configuring Shared Group Directories
- 10.6 Applying Defailt Permissions

## 10.1 Understanding Ownership

- Files have three permission classes:
    1. **Users** (the owner)
    2. **Group** (members of the file's group)
    3. **Others** (everyone else)
- The kernel checks them in order - user -> group -> others and stop at the first match. Permissions are not additive
- Check a file's owner, group, and mode with `ls -l`
- **Tips**: Always set the correct owner/group (chown) before adjusting permission bits (chmod)


## 10.2 Chaning File Ownership
- `chown user[:group] file` to change the file's owner (and its group if you include `:group`)
    - Example: `chown alice report.txt`
- `chgrp group file` to change only the file's group
    - Example: `chgrp alice:developers projects/`
- `chgrp admins /var/log/app.log` to change group only
- To recursively change in a directory:
    ```bash
    chown -R bob /home/bob
    chgrp -r interns /mnt/share
    ```


## 10.3 Understanding Basic Permissions

|             | files  | dir           |
| ----------- | ------ | ------------- |
| read (4)    | open   | list          |
| write (2)   | modify | create/delete |
| execute (1) | run    | cd            |

- when `x` is applied recursively, it would make directories as well as files executable
- in recurseive command, use `X` instead
    - Directories will be granted the execute permission
    - Files will only get the execute permission if it is set already elsewhere on the file

## 10.4 Managing Basic Permissions
- `chmod` changes a file or directory's access bits (read, write, execute).
- Absolute (numeric) mode:
    - Three digits: owner, group, others (each ranges from 0 - 7)
    - Example: `chmod 750 myfile`
        - Owner = 7 (rwx)
        - Group = 5 (r-x)
        - Others = 0 (---)
- Relative (symbolic) mode:
    - Syntax: `[ugoa...][+-=][rwx]`
    - Example: `chmod +x myscript`
        - Adds execute permission for user, group, and others
    - More example:
        - `chmod g+w report.txt` -> add write for group
        - `chmod o-r secret.txt` -> remove read for others
        - `chmod u=rw,go=r config.cfg` -> set owner=rw, group/others=r
- More examples:
    - `chmod 644 document.txt`
    - `chmod -R 755 /var/www` (recursive)
    - `chmod a+rw shared.txt` (everyone read/write)
 
## 10.5 Configuring Shared Group Directories
- `chmod g+s mydir` will apply SGID to the directory
- `chmod +t mydir` assigns sticky bit to the directory
- In absolute mode, a four digit number is used, of which the first digit for the special permissions
- `chmod 3660 mydir` assigns SGID and sticky it, as well as rwx for user and group

## 10.6 Applying Default Permissions
- The `umask` is a shell setting that substracts the umask from the default permission
    - Default is set in /etc/bashrc
    - Set user-specific overrides in ~/.bashrc
- Default permissions for file are 666
- Default permissions for directory are 777

## Lesson 10 Lab: Managing Permissions
- Create a shread group directory structure /data/profs and /data/students that meets the following conditions
    - Members of the groups have full read and write access to their directories, others has no permissions at all

    ```bash
    mkdir /data/{profs,students}
    chgrp profs /data/profs 
    chgrp students /data/students
    chmod 770 /data/{profs,students} 
    ```

- Modify default permission settings such that normal users have a umask that allows the user and group to write, create and execute files and directories while denying all other access to others

```bash
umask 007
```