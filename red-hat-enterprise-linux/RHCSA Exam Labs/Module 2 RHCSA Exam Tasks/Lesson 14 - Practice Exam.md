# Practice Exam

## Task 1: Managing Repository Access
- Copy the content of the RHEL9.x installation disk to the `/rhel9.iso` file.
- Mount this iso file on the `/repo` directory
- Configure your system to use this local `/repo` directory as a repository, providing access to the BaseOS and AppStream packages.

## Task 2: Using Essential Tools
- Locate all files with a size bigger than 200 MiB. Do not inclyde any directories. Use the `ls -l` command to write of all the files to the directory `/root/bigfiles.txt`

## Task 3: Creating Shell Scripts
- Write a script that can be used as a countdonw time. Make sure it meets the following requirements:
    - The name of the script is `countdown.sh`
    - The script should take a number of minutes as its argument
    - If no argument is provided, the script should prompt the user to enter a value and use to enter a value and use that.
    - While running, the script should print `nn seconds remaining`, where nn is the number of seconds. This should happen every second. The current number of seconds should be stored in a variable `COUNTER`
    - The script should count down seconds to 0. When second 0 is reached, the script should stop and print the message `countdown is now finished`.
    - The script should be copied to the recommended location in the search path of regular users.

## Task 4: Operating Running Systems
- Run the command `sleep infinity` with adjusted priority. Make sure it meets the following requirements:
    - It should get the lowest priority that can be set.
    - It should automatically be started as a background job when the user `student` logs in.

## Task 5: Configuring Parititions
- On the secondary hard disk, create a primary partition that meets the following requirements:
    - The GPT partitionong scheme is used.
    - The partition has a size of 2 GiB
    - After creation, it will be listed as the first partition.

- On the secondary hard disk, create another partition that meets the following requirements:
    - The size is 5GiB.
    - The partition type is set to `lvm`.

## Task 6: Configuring LVM
- Create an LVM setup that meets the following requirements:
    - A volume with the name `vglabs` is created and uses the LVM partition that was created in the previous taks.
    - The volume group uses a physical extent size of 2MiB.
    - A logical volume with the name `lvlabs` is created. It uses `50%` of disk space available in the volume group.

## Task 7: Managing Filesystems
- Create and mount filesystems on the previously create devices, meeting the following requirements:
    - The partition uses the XFS filesystem. It is mounted persistently by using its UUID on the directory `/data`
    - The logical volume uses the Ext4 filesystem and is mounted persistently on the directory `/files`

- Use `/etc/fstab` for the persistent mounting, do NOT use systemd mounts.
- Use the systemd mount that is provided by a default installation to mount the `/tmp` directory persistently using the tmpfs driver. This mount should not be seen in `/etc/fstab`.

## Task 8: Deploying, Configuring, and Maintaining Systems
- Create a simple systemd unit with the name `sleep.service`. Make sure it meets the following requirements:
    - It runs the `sleep 3600` command.
    - The unit is stored in the appropriate location for adminstrator-created unit files.
    - The unit is automatically started in `multi-user.target`
    - If it stops for any reason, it will automatically restart.

## Task 9: Managing Basic Networking
- Set the hostname of your test machine to `examlabs.example.com`
- Install and enable the `httpd` service using default configuration.
- Ensure that the firewall allows non-secured access to the httpd service.

## Task 10: Managing Users and Groups
- Make sure that new users require a password with a maximal validity of 90 days.
- Ensure that while creating users, an empty file with the name `newfile` is created to their home directory.
- Create users `anna`, `anouk`, `linda`, and `lisa`.
- Set the password for all users to `password`.
- Create the groups `profs` and `students`, and make users `anna` and `anouk` members of `profs`, `lisa` and `linda` members of `students`.
- Create a shared group directory structure `/data/profs` and `/data/students` that meets the following condition:
    - Members of the groups have full access and write access to ther directories, other have no permissions at all.

## Task 11: Managing Security
- Configure the httpd service to meet the following requirements:
    - The DocumentRoot in `/etc/httpd/conf/httpd.conf` is set to `/web`.
    - Create a file `/web/index.html` that contains the text `hello from /web`.
    - Include the following in `/etc/httpd/conf/httpd.conf` to configure Apache to allow access to the non-default DocumentRoot:
        ```yaml
        <Directory "/web">
            AllowOverride None
            # Allow open access:
            Require all granted
        </Directory>
        ```
    - Verify that the content is served from the non-default DocumentRoot.

## Task 12: Building Containers from a Containerfile
- Ensure you have access to the course Git repository at `https:/github.com/sandervanvugt/rhcsa-labs`
- Build a container image with the name `greeter` based on the Containerfile you'll find in the course Git repository.
- Run this image as a container with the name `sleeper`.

## Task 13: Managing Containers
- Ensure that you have full access to the Red Hat container repositories.
- Run a Mariadb container, based on the `registry.redhat.io/rhel9/mariadb-105`, which meets the following conditions:
    - The container is started as a rootless container by user `student`
    - The container must be accessible at host port `3206`
    - The database root password should be set to `password`.
    - The container uses the name `mydb`
    - A bind-mounted directory is accessible: the directory `/home/student/mariadb` on the host must be mapped to `/var/lib/mysql` in the container.

## Task 14: Configuring Containers to Automatically Start
- Configure the container `mydb` that was created in the previous task to automatically be started by systemd when your system boots.
- Ensure that the container will also be started if the user `student` does NOT log in after the systemd has been started.