# Lesson 8: Using root Privileges

- 8.1 Understanding the root User
- 8.2 Switching User with `su`
- 8.3 Performing Administrator Tasks with `sudo`
- 8.4 Managing `sudo` Configuration
- 8.5 Using `ssh` to Log In remotely

## 8.2 Switching User with `su`
- the su command is used to switch current user account from a shell environment
- if su is used with the `-` option, the complet environment of the target user is loaded
- While using su, the password of the target user is entered
- If the root user has a passowrd, `su - ` can be used
- Using `su -` to open a root shell is considered bad practice, use `sudo -i` instead
- The `su` command can be usefull for testing other user accounts

## 8.3 Performing Administrator Tasks with sudo
- `sudo` is more sucure mechanism to perform administration tasks
- Behind `sudo` is the /etc/sudoers configuration file
- While edit /etc/sudoers through visudo, very detailed administration privileges can be assigned
- To run an administration task using `sudo`, use `sudo command`
- This will prompt for the current user password, and run the command if this allowed through /etc/sudoers
- To open a root shell, `sudo -i` can be used

## 8.4 Managing sudo Configuration
- `/etc/sudoers` is a primary sudoers file that defines with users or groups can run which commands as which targets.
- `visudo` to edit `/etc/sudoers` safely.
- use drop-ins in `/etc/sudoers.d` that place small snippets (e.g. admins, developers) here instead of editing the main file
    ```bash
    sudo visudo -f /etc/sudoers.d/myrules.conf
    ```
- /etc/sudoers is installed from packages and **may be overwritten**, drop-in files will **never be overwritten**

### Providing Administrator Access
- Enable sudo for the `wheel` group
    - Ensure `/etc/sudoers` contains `%wheel ALL=(ALL) ALL`
    - Then add users with `usermod -aG wheel myuser`
- Avoid passwordless:
    - Do no enable: `%wheel ALL=(ALL) NOPASSWD: ALL` because it will grant full access without any password.
- Extend sudo's password timeout. By default, sudo re-prmpts every 5 minutes. To change it to 60 minutes, add via visudo:
    ```bash
    Defaults timestamp_type=global
    Defaults timestamp_timeout=60
    ```

### Providing Access to Specific Tasks
- To give a user just a few commands
    - Create `/etc/sudoers.d/lisa` with `lisa ALL=(ALL) /sbin/useradd, /usr/bin/passwd`
- Limit a group to a specific device
    - In `/etc/sudoers.d/users`, add `%users ALL=(ALL) /bin/mount /dev/sdb, /bin/umount /dev/sdb`
- Allow a user to change only their own password
    - In `/etc/sudoers.d/linda`, add `linda ALL=(ALL) /usr/bin/passwd, !/usr/bin/passwd root`

### Using ssh to Log in Remotely 

- By default, all RHEL servers run a Secure Shell (SSH) server
- Use `systemctl` to verify
    - `systemctl status sshd`
- SSH access is allowed through the firewall by default
- Notice that root access is often denied
- Use `ssh` to connect to a remote server
    - On the remote server, use `ip a` to find the IP address
    - `ssh 192.168.29.100` will connect to this IP address using your current user account
    - `ssh user@192.168.100` will connect as a specific user

## Lesson 8 Lab: configuring `sudo`
- Use `useradd linda` to create a user linda
- Create a sudo configuration that allows linda to perform common user management tasks
    - Allow using `useradd`, `usermod` and `userdel`
    - Allow changing passwords, but not the password for user root
- Ensure that the user only needs to enter a password for `sudo` operations every 60 minutes