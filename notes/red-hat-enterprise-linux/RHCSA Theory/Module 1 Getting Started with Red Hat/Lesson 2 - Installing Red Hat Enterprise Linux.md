## 2.3 Installing with Custom Partitioning

- Linux servers typically use multiple storage volumes
    - Partitions are the base solutions for offering multiple separated storage areas
    - Logical volumes can be used as an alternative for partitions
- A small partition containing all that is required for booting
- A root partition containing operating system essential files
- Other file typoes that are often organized on dedicated partitions:
    - Log files
    - User home directories
    - Server document roots
    - Container images and more
## Logging into the Server
- To work on Linux, you'll need to identify yourself by logging in using a user account
- A user account is created when the server installs
    - Some servers have a root user account with unlimited access privileges
    - Some servers only have a regular user account that can perform administrative tasks using `sudo`
    - Some servers have both

- Avoid logging in as root, because it has a higher risk of security-related problems

## Lab: Installing Red Hat Enterprise Linux

- Install a RHEL Server that meets the folliwng requirements:
    - Make sure a graphical user interface is installed
    - Configure a 10GiB Root partition
    - Use a 1GiB Swap partition
    - Make sure that at least 4GiB of disk space remains as unused
    - Set the root password to "password"
    - Create a user "user" with the password "password"
    - Configure the network interface to contact a DHCP server