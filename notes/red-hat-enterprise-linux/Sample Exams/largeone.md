## Large Sample Exam
- Link: https://docs.google.com/document/d/1y_LHzl0LkQkBfgvlCLlfLjJntMfrNOXmPIwrh40tT9k/edit?pli=1&tab=t.1 

## Setup for Large Sample Exam:
- Build 2 virtual machines with RHEL 9.3 Server with GUI. Use a 20GB disk for the OS with default partitioning. Add an additional 20GB disk and a network interface. Do not configure the network interface or create a normal user account during installation. When you set up the network connections in a later task make sure they have an internet connection for the purpose of this exam, the actual exam will have no internet connection. You will need to be able to download images from Docker or the RH registry for the steps below.


## Tasks
1. Assume the root user password is lost, and your system is running in multi-user target with no current root session open. Reboot the system into an appropriate target level and reset the root user password to root1234. After completing this task, log in as the root user and perform the remaining tasks presented below.

2. On VM1 configure a network connection on the primary network device with IP address 192.168.0.241/24, gateway 192.168.0.1, and nameserver 192.168.0.1. Use different IP assignments based on your lab setup.
- Tips:
    - `ip route` to check the default gateway
- How to verify:
    - `ping [new ip]` to make the new IP is working
    - `ping 8.8.8.8` to make sure the gateway is working

3. On VM2 configure a network connection on the primary network device with IP address 192.168.0.242/24, gateway 192.168.0.1, and nameserver 192.168.0.1. Use different IP assignments based on your lab setup.

- Solution:
    ```bash
    nmcli con add con-name concon ifname ens160 ipv4.addresses 192.168.182.242/24 ipv4.gateway 192.168.182.2 ipv4.method manual type ethernet
    ```

4. On VM1 set the system hostname to rhcsa1.example.com and alias rhcsa1. Make sure that the new hostname is reflected in the command prompt.

5. On VM2 set the system hostname to rhcsa2.example.com and alias rhcsa2. Make sure that the new hostname is reflected in the command prompt.

6. Run “ping -c2 rhcsa2” on rhcsa1. Run “ping -c2 rhcsa1” on rhcsa2. You should see 0% loss in both outputs.

7. On rhcsa1, add HTTP port 8081/TCP to the SELinux policy database persistently.

8. On rhcsa1 change the system time to the “America/New_York” timezone.

9. On both VMs attach the RHEL 9 ISO image to the VM and mount it persistently to /repo. Define access to both repositories and confirm.

10. On both VMs, all new users should have a file named ‘CONGRATS’ in their home folder after account creation.

11. On rhcsa2, all user passwords should expire after 90 days and should be at least 9 characters in length.

12. On rhcsa2, create users edwin and santos and make them members of the group dbadmin as a secondary group membership. Also, create users serene and alex and make them members of the group accounting as a secondary group. Ensure that user santos has UID 1234 and cannot start an interactive shell.

13. On rhcsa2, create shared group directories /groups/dbadmin and /groups/accounting, and make sure the groups meet the following requirements:
    - Members of the group dbadmin have full access to their directory.
    - Members of the group accounting have full access to their directory.
    - New files that are created in the group directory are group owned by the group owner of the parent directory.
    - Others have no access to the group directories.

14. On rhcsa2, Find all files that are owned by user edwin and copy them to the directory /root/edwinfiles.

15. Create user bob and set this user’s shell so that this user can only change the password and cannot do anything else.

16. On rhcsa1, list all files that are part of the “setup” package, and use regular expressions and I/O redirection to send the output lines containing “hosts” to /var/tmp/setup.pkg

17. On both VMs set the default boot target to multi-user.

18. Export /share1 on rhcsa1 and mount it to /share2 persistently on rhcsa2. Create a test file from each server in the directory to ensure the share is working properly.

19. On rhcsa1 Perform a case-insensitive search for all lines in the /usr/share/dict/linux.words file that begin with the pattern “essential”. Redirect the output to /var/tmp/pattern.txt file. Make sure that empty lines are omitted.

20. On rhcsa1 change the primary command prompt for the root user to display the hostname, username, and current working directory information in that order. Update the per-user initialization file for permanence.

21. On both VMs create user accounts called user10, user20, and user30. Set their passwords to Temp1234. Make user10 and user30 accounts to expire on December 31, 2025.

22. On both VMs create a group called group10 and add user20 and user30 as secondary members.

23. Use NFS to export home directories for all users (user100, user200, and user300) on rhcsa2 so that their home directories become available automatically under /home1 when they log on to rhcsa1. Create user100, user200, and user300. Ensure the UUIDs on both servers for these users are the same.

24. On rhcsa1, members (user100 and user200) of group100 should be able to collaborate on files under /shared but cannot delete each other’s files.

25. On rhcsa1 create a user account called user70 with UID 7000 and comments “I am user70”. Set the maximum allowable inactivity for this user to 30 days.

26. On rhcsa1 create a user account called user50 with a non-interactive shell.

27. On rhcsa1 set up a cron job for user70 to search for files by the name “core” in the /var directory and copy them to the directory /var/tmp/coredir1. This job should run every Monday at 1:20 a.m.

28. On rhcsa1 create a logical volume called lvol1 of size 280MB in vgtest volume group. Mount the ext4 file system persistently to /mnt/mnt1.

29. On rhcsa1 create a logical volume called lvo2 of size 400MiB in vgo2 volume group. Mount the vfat file system persistently to /mnt/vfatfs.

30. On rhcsa1 set up a web server that serves index.html that contains “hello world” out of the /webfiles directory. Make sure that rhcsa2 can access the web page using the curl command.

31. Change group membership on /mnt/mnt1 to group10. Set read/write/execute permissions on /mnt/mnt1 for group members and revoke all permissions for public

32. On rhcsa1, create a group called group30 with GID 3000, and add user60 and user80 to this group. Create a directory called /sdata, enable setgid bit on it, and add write permission bit for group members. Set ownership and owning group to root and group30. Create a file called file1 under /sdata as user60 and modify the file as user80 successfully.

33. On rhcsa1, create directory /var/dir1 with full permissions for everyone. Disallow non-owners to remove files. Test by creating file /var/dir1/stkfile1 as user60 and removing it as user80.

34. On rhcsa1 create a swap partition of size 200MB on the secondary disk. Use its UUID and ensure it is activated after every system reboot.

35. On rhcsa1 create a disk partition of size 1GiB on the secondary disk and format it with Ext4 file system structures. Assign label stdlabel to the file system. Mount the file system on /mnt/stdfs1 persistently using the label. Create file stdfile1 in the mount point.

36. On rhcsa2 create a logical volume called lv1 of size equal to 10 LEs in vg1 volume group (create vg1 with PE size 8MB in a partition on the secondary disk). Initialize the logical volume with XFS type and mount it on /mnt/lvfs1. Create a file called lv1file1 in the mount point. Set the file system to automatically mount at each system reboot.

37. On rhcsa2 add a group called group20 and change group membership on /mnt/lvfs1 to group20. Set read/write/execute permissions on /mnt/lvfs1 for the owner, group members, and others.

38. On rhcsa2 extend the file system in the logical volume lv1 by 64MB without unmounting it and without losing any data. Confirm the new size for the logical volume and the file system.

39. On rhcsa2, create file lnfile1 under /var/tmp and create three hard links called hard1, hard2, and hard3 for it. Identify the inode number associated with all four files. Edit any of the files and observe the metadata for all the files for confirmation

40. Create shared group directories /groups/sales and /groups/account, and make sure these groups meet the following requirements:
    - Members of the group sales have full access to their directory.
    - Members of the group account have full access to their directory.
    - Users have permissions to delete only their own files, but Alex is the general manager, so user alex has access to delete all users’ files.

41. On rhcsa2 use the combination of tar and bzip2 commands to create a compressed archive of the /usr/lib directory. Store the archive under /var/tmp as usr.tar.bz2

42. On rhcsa1 use the tar and gzip command combination to create a compressed archive of the /etc directory. Store the archive under /var/tmp using a filename of your choice.

43. On rhcsa1, create a group sysadmins. Make users linda and anna members of this group and ensure that all members of this group can run all administrative commands using sudo.

44. On rhcsa1, search for all manual pages for the description containing the keyword “password” and redirect the output to file /var/tmp/man.out.

45. On rhcsa2 create a directory hierarchy /dir1/dir2/dir3/dir4 and apply SELinux contexts of /etc on it recursively.

46. On rhcsa2 search for all files in the entire directory structure that have been modified in the past 30 days and save the file listing in the /var/tmp/modfiles.txt file.

47. On rhcsa2 enable access to the atd service for user20 and deny for user30.

48. On rhcsa2 add a custom message “This is RHCSA sample exam on $(date) by $LOGNAME” to the /var/log/messages file as the root user. Use regular expression to confirm the message entry to the log file and redirect the output to /root/customlogmessage.

49. On both VMs allow user20 to use any sudo command without being prompted for their password.

50. On rhcsa1 create a directory /direct01 and apply SELinux contexts for /root to it. Make sure this is persistent.

51. On rhcsa1, set SELinux type shadow_t on a new file testfile1 in /usr and ensure that the context is not affected by a SELinux relabeling.

52. On rhcsa1, flip the value of the Boolean nfs_export_all_rw persistently.

53. On rhcsa1, configure journald to store messages permanently under /var/log/journal and fall back to memory-only option if /var/log/journal directory does not exist or has permission/access issues.

54. On rhcsa2 modify the bootloader program and set the default autoboot timer value to 2 seconds.

55. On rhcsa1 boot messages should be present (not silenced).

56. On rhcsa2 determine the recommended tuning profile for the system and apply it.

57. On rhcsa1, set the tuning profile to powersave.

58. On rhcsa2 write a bash shell script to create three user accounts—user555, user666, and user777—with no login shell and passwords matching their usernames. The script should also extract the three usernames from the /etc/passwd file and redirect them into /var/tmp/newusers.

59. On rhcsa2 write a bash shell script so that it prints RHCSA when RHCE is passed as an argument, and vice versa. If no argument is provided, the script should print a usage message and quit with exit value 5.

60. On rhcsa2, write a bash shell script that defines an environment variable called ENV1=book1 and creates a user account that matches the value of the variable.

61. On rhcsa2, write a bash shell script that checks for the existence of files (not directories) under the /usr/bin directory that begin with the letters “ac” and display their statistics (the stat command).

62. On rhcsa2, write a bash shell script named ‘yes-no.sh’ that does the following:
    - If the argument passed in is 'yes', the script should print “that's nice”.
    - If the argument passed in is 'no', the script should print "I am sorry to hear that".
    - If the argument passed in is anything else, the script print "unknown argument provided".

63. On rhcsa1 configure Chrony to synchronize system time with the hardware clock. Remove all other NTP sources.

64. On rhcsa1 Install package group called “Development Tools” and capture its information in /var/tmp/systemtools.out file.

65. On rhcsa1 lock user account user70. Use regular expressions to capture the line that shows the lock and store the output in file /var/tmp/user70.lock.

66. Configure passwordless ssh access for user100 from rhcsa1 to rhcsa2. Copy the directory /etc/sysconfig from rhcsa1 to rhcsa2 under /var/tmp/remote securely.

67. On rhcsa1, add HTTP port 8400/UDP to the public firewall zone persistently.

68. On rhcsa1, add the http service to “external” firewalld zone persistently.

69. On rhcsa1 launch a container as user20 using the latest version of ubi8 image. Configure the container to auto-start at system reboots without the need for user20 to log in.

70. On rhcsa1 launch a container as user20 using the latest version of ubi9 image with two environment variables SHELL and HOSTNAME. Configure the container to auto-start via systemd without the need for user20 to log in. Connect to the container and verify variable settings.

71. On rhcsa1, launch a named rootless container as user100 with /data01 mapped to /data01 and two variables KERN=$(uname -r) and SHELL defined. Use the latest version of the ubi8 image. Configure a systemd service to auto-start the container at system reboots without the need for user100 to log in. Create a file under the shared mount point and validate data persistence. Verify port mapping using an appropriate podman subcommand.

72. On rhcsa2 launch a named rootful container with host port 443 mapped to container port 443. Employ the latest version of the ubi9 image. Configure a systemd service to auto-start the container at system reboots. Validate port mapping using an appropriate podman subcommand.

73. On rhcsa2 launch a rootless container as user80 with /data01 mapped to /data01 using the latest version of the ubi9 image. Configure a systemd service to auto-start the container on system reboots without the need for user80 to log in. Create files under the shared mount point and validate data persistence.

74. On rhcsa2, configure a container that runs the mysql:latest image and ensure it meets the following conditions
    - It runs as a rootless container in the user santos account.
    - It is configured to use the mysql root password password.
    - It bind mounts the host directory /home/santos/mysql to the container directory /var/lib/mysql.
    - It automatically starts through a systemd job, where it is not needed for user santos to log in.

75. On rhcsa2, configure SSH so that it meets the following requirements:
    - User root is allowed to connect through SSH.
    - The server offers services on port 2022.

76. On rhcsa2, configure your system to automatically start a mariadb container as user edwin. This container should expose its services at port 3306 and use the directory /var/mariadb-container on the host for persistent storage of files it writes to the /var directory.

77. Configure your system such that the container created in the step before is automatically started as a Systemd user container.

### Bonus Shell Scripting Prompts

1. Write a bash shell script that creates three user accounts—user101, user202, and user303—with a primary group of developers. If the group does not exist, the script should create it before adding users. The script should also validate that each user was successfully created by checking the /etc/passwd file and logging the results to /var/tmp/user_creation.log

2. Write a bash shell script that finds all .conf files under /etc modified within the last 7 days and archives them into /var/tmp/conf_backup.tar.gz. The script should log the number of files backed up and the archive size in /var/tmp/backup.log

3. Write a bash shell script that takes a service name as an argument and checks whether it is active. If the service is running, print "Service <name> is running". If it is inactive or does not exist, print "Service <name> is not running". If no argument is provided, print a usage message and exit with status 2.

4. Write a bash shell script that checks disk usage on the /home directory. If usage exceeds 80%, append a warning message to /var/log/homedir_usage.log with the timestamp and current usage percentage. Otherwise, append a normal status message with the current usage.

5. Write a bash shell script that finds all files in /var/log owned by root that have write permissions for others (o+w) and removes that permission while logging the changes to /var/tmp/permissions_fixed.log.