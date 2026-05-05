# Lesson 32.1 Exploring RHCSA Practice Exam Assignments
### Setting up a Base Server
- Install two servers using the minimal installation pattern. Use the names server1.example.com and server2.example.com and use DHCP to get an IP address from the local DNS server.
- Ensure that the partition for `/` is 15GiB. Also create a 1GiB swap partition. Do NOT register the servers with Red Hat
- Solution:
    - On both servers, config both using the below configuration:
    ```yml
    - /: 15GiB
    - /home: 3 GiB
    - /boot: 500 MiB
    - swap: 1 GiB
    - /boot/efi: 500 MiB
    ```


### Resetting the Root Password
- Use the appropriate solution to reset the root password on server2, assuming that you have lost the root password and you have no administrator access to the server anymore.
- Solution:
    - Reboot and then press `e`. Add line `init=/bin/bash`
    - `mount -o remount,rw /`
    - `passwd root`
    - `touch /.autorelabel`
    - `exec /usr/lib/systemd/systemd`

### Configuring a Repository
- On both servers, create an ISO file based on the installation DVD. Mount this ISO file persistently and configure the servers to use the local ISO file as the repositories. After carefully completing this assignment, you should be able to install software on both servers.

- Solution:
    - Install the ISO file to DVD on both RHEL instances
      - On **VMWare**, go VM > Settings > Add a CD/DVD > Pick an RHEL image on your host machine filesystem.
    - Run the following:
    ```bash
    dd if=/dev/sr0 of=/rhel9.iso bs=1M
    mkdir /repo
    cp /etc/fstab /etc/fstab.bak
    echo "/rhel9.iso     /repo    iso9660        defaults  0  0" >> /etc/fstab
    mount /rhel9.iso /repo
    mount -a
    dnf config-manager --add-repo file:///repo/BaseOS
    dnf config-manager --add-repo file:///repo/AppStream
    ```

### Managing Partitions
- On server1, use your virtualization software to increase the size of your primary disk in such a way that at least 10 GiB of unallocated disk space is available.
    - Solution:
        - Shutdown the RHEL instance, and add one more Disk using `VMWare` control center
- In the free disk space, create a 1 GiB partition and format it with vfat filesystem. Make sure it is mounted persistently on the `/winfile` directory.

- Also create a 1 GiB swap partition and ensure it is mounted persistently.

- Solution:
    ```bash
    # note UUID is optional
    fdisk /dev/sdb
    p # to create a new partition
    t # to change the partition type to fat32 (vfat) partition

    p # to create a new partition
    t # to change the partition type to swap 

    w # write and exit fdisk
    mkfs.vfat /dev/sda4
    swapon /dev/sda4
    # add the line below to /etc/fstab 
    /dev/sda4 /winfile vfat defaults 0 0

    mkswap /dev/sda5
    # add the line below to /etc/fstab 
    /dev/sda5 none swap defaults 0 0
    swapon /dev/sdaa5

    findmnt --verify # to verify everything before reboot
    ```

### Managing LVM Logical Volumes
- Create a logical volume with the name myfiles. Ensure it uses 8 MiB extents. Configure the volume to use 75 extents. Format it with the ext4 file system and ensure it mounts persistently on `/myfiles`
- If volume groups need to be created, create them as needed
    - Solution:
        ```yml
        fdisk /dev/sda
        #Then create an extended partion and then create logical partitions with LVM type
        pvcreate /dev/sda6
        vgcreate -s 8M myvg /dev/sdb6
        lvcreate myvg -n myfiles -l 75
        mkfs.ext4 /dev/myvg/myfiles
        ```
- Increase the size of the `/` logical volume by 5 GiB
    - Solution:
        ```bash
        lvextend -r -L +5G /dev/myvs/myfiles
        ```
     

### Creating Users and Groups
- Create a user lisa. Ensure she has the password set to "password" and is using UID 1234. She must be a member of the secondary group sales
    - Solution:
        ```bash
        groupadd sales
        useradd -s /usr/sbin/nologin -u 1234 -p password -G sales lisa
        ```

- Create a user myapp. Ensure this user cannot open an interactive shell.
    - Solution:
        ```bash
        useradd myapp
        usermod -s /sbin/nologin myapp
        usermod -s /bin/bash myapp
        ```

### Managing Permissions
- Create a shared group directory `/sales`  and ensure that `lisa` is the owner of that directory. The owner and the group sales should have permissions to access this directory and read and write files in it. Other user should have no permission at all. Ensure that any new file that is created in this directory is group-owned by the group sales automatically
    - Solution:
        ```yml
        mkdir /sales
        groupadd sales
        usermod -aG sales lisa
        chown lisa:sales /sales
        chmod g+ws /sales` # to set SGID so that any files or sub directories will inherit the rules from the parent folder.
        ```
        - note: SGID only works with group

### Scheduling Jobs
- Schedule a job that writes "hello folks" to syslog every Monday through Friday at 2 AM. Make sure this job is executed as the user lisa.
    - Solution:
        ```yml
        su - lisa
        crontab -e # or if under root, run: crontab -u lisa -e
        ```
        ```yml
        SHELL=/bin/bash
        PATH=/sbin/:bin/:/usr/sbin:/usr/bin
        MAILTO=root

        0 2 * * * 1-5 logger "hello folks"
        ```

### Managing Containers as Services
- Create a container with the name mydb that runs the mariadb database as user lisa. The container should automatically be started at system start, regardless of whether or not user lisa is logging in. The container further should meet the following requirements:
    1. The host directory `/home/lisa/mydb` is mounted on the container directory `/var/lib/mysql`
    2. The container is accessible on host port 3206
    3. You do not have to create any databases in it.

    - Solution:
        ```yml
        su - lisa
        podman login registry.access.redhat.com
        podman search mariadb-103-centos
        podman pull docker.io/centos/mariadb-103-centos7
        podman inspect docker.io/centos/mariadb-103-centos7 | grep User

        podman unshare cat /proc/self/uid_map
        podman unshare chown $(UUID):$(UUID) /home/lisa/mydb
        podman run -d --name mydb -e MYSQL_ROOT_PASSWORD=password -p 3206:3206 -v /home/lisa/mydb:/var/lib/mysql:Z docker.io/centos/mariadb-103-centos7 
        firewall-cmd --add-port=3206/tcp --permanent
        firewall-cmd --reload
        loginctl enable-linger lisa
        mkdir -p ~/.config/systemd/user; cd ~/.conf/systemd/user
        podman generate systemd --name mydb --files --new        systemctl --user daemon-reload
        systemctl --user start container-mydb.service
        systemctl --user status container-mydb.service
        ```

### Managing Automount
- On server2, create the directories `/homes/user1` and `/homes/user2`. Use NFS to share these directories and ensure the firewall does not block access to these directories.
    - Solution:
        - `dnf install -y nfs-utils`
        - `systemctl enable --now nfs-server`
        - `firewall-cmd --add-service=mountd --permanent`
        - `firewall-cmd --add-service=rpc-bind --permanent`
        - `firewall-cmd --add-service=nfs --permanent`
        - `firewall-cmd --reload`
        - `vim /etc/exports`
            ```vi
            /homes/user1    *(rw,no_root_squash)
            /homes/user2    *(rw,no_root_squash)
            ```
        - `showmount -e server2`
- On server1, create a solution that automatically, on-demand mounts `server2:/homes/user1` on `/homes/user1` and also that automatically, on-demand mounts `server2:/homes/user2` on `/homes/user2` when these directories are accessed.
    - Solution:
        - `dnf install -y autofs`
        - `vim /etc/auto.master`
            ```vim
            /homes       /etc/auto.homes
            ```

        - `vim /etc/auto.homes`
            ```vim
            *   -rw     server2:/homes/& 
            # or
            user1 -rw server2:/homes/user1
            user2 -rw server2:/homes/user2
            ```


### Setting Time
- Configure server1 and server2 as an NTP client for pool.ntp.org.

### Managing SELinux
- Ensure that the Apache web server is installed and configure it to offer access on port 82.

- Install the graphical interface
```yml
dnf groupinstall "Server with GUI"
reboot
```

- Install sealert
```bash
dnf install setroubleshoot-server
```

- solution
```bash
dnf install httpd
vim /etc/httpd/conf/httpd.conf
# edit httpd.conf
Listen 82
# end edit

firewall-cmd --add-service=http,https --permanent
firewall-cmd --add-port=82/tcp --permanent

systemctl enable --now httpd
# if error run:
journactl | grep sealert
sealert -l 94f10b28-d87d-400b-9c0b-0cc947e1c9b4
# endif
semanage port -a -t http_port_t -p tcp 82 
systemctl restart httpd
curl localhost:82 
```

- Copy the file `/etc/hosts` to `/tmp/hosts`. Next, move `/tmp/hosts` to the directory `/var/www/html/hosts` and ensure this file can be access by the Apache web server.
- `semanage fcontext`

```yml
  326  journalctl | grep sealert
  327  sealert -l 94f10b28-d87d-400b-9c0b-0cc947e1c9b4
  328  semanage port -a -t http_port_t -p tcp 82
  329  systemctl restart httpd
  330  systemctl status httpd
  331  cat /etc/httpd/conf/httpd.conf 
  332  c;ear
  333  curl localhost
  334  curl localhost:82
  335  clear
  336  cp /etc/hosts /tmp/hosts
  337  cat /tmp/hosts
  338  clear
  339  mv /tmp/hosts /var/www/html/hosts
  340  ls /tmp
  341  ls /var/www/html/
  342  ls -lZ /var/www/html/
  343  vim /etc/httpd/conf/httpd.conf 
  344  systemctl restart httpd
  345  systemctl status httpd
  346  curl localhost:82
  347  ls -lZ /var/www/html/hosts 
  348  ls -lZ /var/www/html 
  349  ls -ldZ /var/www/html
  350  semanage --help
  351  semanage fcontext
  352  semanage fcontext -l
  353  semanage fcontext -l | grep http
  354  clear
  355  semanage-fcontext
  356  # httpd_sys_rw_content_t
  357  man semanage-fcontext
  358  semanage fcontext -a -t httpd_sys_content_t "/web(/.*)?"
  359  ls /web
  360  ls /
  361  semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?"
  362  restorecon /var/www/html/hosts 
  363  ls -lZ /var/www/html/hosts
```