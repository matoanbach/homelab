## 4.1 Configuring Remote Repository Access
### Task: Confuguring remote repository access
- Configure your system such that it can use the repository `https://repository.example.com`
- Ensure that no GPG checks will be done while accessing this repository
- Ensure that the client will not actually use this directory
- To verify your work, the repository should not show while using the `dnf repolist` command, but its configuration should exist

### Solution
```bash
dnf config-manager --add-repo=https://repository.example.com

vim /etc/yum.repos.d/repository.example.com.repo
# start editing repository.example.com
[repository.example.com]
name=created by dnf config-manager from https://repository.example.com
baseurl=https://repository.example.com
enabled=0
gpgcheck=1
# end editing

dnf repolist # to verify the work
```

## 4.2 Configuring local repository access
### Task: Configure local repository access
- Make an ISO file of your installation disk and store it as `/rhel9.iso`
- Mount it persistently on the directory `/repo` on your local server.
- Configure your local server to access this mounted disk as a repository.
- Verify that you can install packages from this repository.

## Key Elements:
- To create an ISO file, use the `dd` command
- To mount it persistently, add a line to `/etc/fstab` and use the `iso9660`  filesystem type. Alternatively (not recommended) create a Systemd mount unit.
- Use `dnf config-manager --add-repo` or manually add a repository file to the `/etc/yum.repos.d/[repo directory]`
- In the baseurl statement, use `file://` as the resource type identifier.

### Solution
```bash
    lsblk
    dd /dev/sr2 if=/rhel9.iso bs=1M 
    dd if=/dev/sr2 of=/rhel9.iso bs=1M 
    mkdir /repo
    vim /etc/fstab
    findmnt --verify
    mount -a
    ls /repo
    dnf config-manager --add-repo=file:///repo/AppStream
    dnf config-manager --add-repo=file:///repo/BaseOS

   # edit AppStream.repo
   [repo_AppStream]
    name=created by dnf config-manager from file:///repo/AppStream
    baseurl=file:///repo/AppStream
    enabled=1
    gpgcheck=0
   # end editing

   # edit BaseOS.repo
    [repo_BaseOS]
    name=created by dnf config-manager from file:///repo/BaseOS
    baseurl=file:///repo/BaseOS
    enabled=1
    gpgcheck=0
   # end editing
```

## 4.3 Managing permissions
### Task: Managing Permissions
- Create a directory with the name `/data/profs`
- Create a group `groups`
- Create a user `linda`
- Configure permissions such that user `linda` can NOT read or write files in the directory `/data/profs`, but is allowed to change permissions on the directory `/data/profs`
- Members of the group `profs` should be able to read and write files in the directory `/data/profs`
- Nobody else should have access to the directory
    - Solution:

### Key Elements:
- Basic permissions are based on ownership
- Each file has a user-owner, a group-owner, and the other entities
- While evaluating permissions, Linux checks user-ownership and group-ownership. If the user accessing a fil eis neither user-owner, not group-owner, permissions for others are assigned.
- The check will exit on match: if a user is user-owner, group permissions and perissions for other are not checked.

```bash
mkdir -p /data/profs
groupadd profs
useradd linda
chown linda:profs /data/profs
chmod o= /data/profs
chmod u= /data/profs
chmod g=xwr /data/profs
usermod -G profs linda
id linda
ls -ld /data/profs
```

## 4.4 Finding files
### Task
- Find all files with a size bigger than 100 MiB, and write a long listing of these files to the file `/tmp/files`
- Solution:
    ```bash
    find / -size +100M -type f -exec ls -l {} \; 2>/dev/null > /tmp/myfiles
    find / -size +100M -type f 2>/dev/null -exec ls -l {} \; > /tmp/bigfiles
    ```

### Key Elements
- `find` is used to find files based on any property
- To perform a command on the result of the `find` command, add `-exec command {} \;` to `find` command
- `grep` is used to search for a regular expression in files or command output
- Different sets of regular expressions exist, including based regular expressions and extended regular expressions.
- To use extended regular expressions, use `grep -e`
- `awk` can be used as a powerfull alternative to `grep`