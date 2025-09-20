# Lesson 9: Managing Users and Groups
- 9.1 Understanding the Purpose of User Accounts
- 9.2 Setting User Properties
- 9.3 Creating and Managing Users
- 9.4 Defining User Default Settings
- 9.5 Limiting User Access
- 9.6 Managing Group Membership
- 9.7 Creating and Managin Groups
- 9.8 Setting Password Properties

## 9.2 Setting User Properties
- name
- password
- UID: a unique identifier for users
- GID: the ID of the primary group
- GECOS: additional non-mandatory information about the user
- Home Directory: the environment where users create personal files
- Shell: the program that will be started after successful authentication

## 9.3 Creating and Managing Users
- `useradd`: create user accounts
- `usermod`: modify user accounts
- `uderdel`: delete uder accounts
- `passwd`: set passwords

## 9.4 Defining User Default Settings
- `useradd -D`: Show or set `useradd`'s own defaults (shell, home directory base, group, etc.)
- `/etc/default/useradd`: The config file `useradd` reads for its defaults
- `/etc/login.defs`: Global login and password policies (aging, UID/GID, ranges) for all account tools.
`/etc/skel`: Files here are copied into every new user's home directory

## 9.5 Limiting User Access
- `usermod -L anna` to lock an account
- `usermod -U anna` to unlock an account
- `usermod -e YYYY-MM-DD` to set expiration for an account
- `usermod -s /sbin/nologin <username>`
- `usermod -aG profs anna`

## 9.6 Managing Group Membership
- Every user needs >= group
- Primary groups
    - Defined in `/etc/passwd`
    - Becomes the group-owner of files
- Secondary groups
    - Listed in `/etc/group`
    - Grant extra permissions
- Change primary group temporarily
    - `newgrp groupname`
- Show a user's groups
    - `id username`

## 9.7 Creating and Managing Groups
- `groupadd <groupname>` to add a group. Use `-g <GID>` to set a specific GID or -r for a system group
- `groupmod [options] <groupname>` to modify a group. Rename with `-n newname` or change its GID with `-g <GID>`.
- `groupdel <groupname>`to remove the group. It must not be any user's primary group
- `lid -g <groupname>` to show group members.
- `cat /etc/group` to list all groups

## Password encryption
- Encrypted passwords are stored in /etc/shadow
- The encrypted string shows 3 pieces of information\
    - The hashing algorithm
    - The random salt
    - The encrypted hash of the user password

### Manage Password Settings
- Basic password requirements are set in /etc/login.defs
- For advanced password properties, Pluggable Authentication Modules (PAM) can be used
    - Look for the pam_faillock module
- To change password settings for current users, use `chage` or `passwd` as root

## Lesson 9 Lab: Managing Users and Groups
- Make sure that new users require a password with a maximal validity of 90 days
```bash
sudo vim /etc/logic.defs

# edit the below:
PASS_MAX_DAYS 90
```
- Ensure that while creating users, an empty file with the name newfile is created to their home directory

```bash
touch /etc/skel/newfile
```

- Create users anna, audrey, linda, and lisa

```bash
useradd {anna,audrey,linda,lisa}
```

- Set the passwords for anna and audrey ti `password`, disanle the passwords for linda and lisa

```bash
echo password | passwd --stdin anna
# disable password by adding the below to /etc/sudoers or visudo
pass -l linda
linda ALL=NOPASSWD : ALL
lisa ALL=NOPASSWD : ALL
```

- Create the groups profs and students, and make users anna and audrey members of profs, and linda and lisa members of students

```bash
usermod -aG profs anna
groupmod -U anna,audrey profs
```