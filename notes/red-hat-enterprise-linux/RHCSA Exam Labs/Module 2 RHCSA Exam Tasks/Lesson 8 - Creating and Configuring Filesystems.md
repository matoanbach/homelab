## 8.1 Mounting filesystems
### Task
- Mount the `lvlabs` LVM logical volume created in Lesson 7 persistently on `/lvlabs`, in such a way that no executable files can be started from it.
- Also, ensure the file access time is not updated while files are accessed.

- Solution:

```bash
# edit /etc/fstab
/dev/vglabs/lvlabs      /lvlabs     xfs     defaults,noexec,noatime     0 0
findmnt --verify # to verify the syntax in /etc/fstab
mount -a
```

### Key Elements
- While mounting filesystems, different options can be used.
- Some options are filesystem-specific, other options are generic.
- You can find more information about these options in the man pages of the `mount` command, or the specific filesystems.

## 8.2 Managing autofs
### Task
- Configure `autofs` such that the `/dev/sda1` device is mounted on the directory `/start/files` when this directory is accessed.

- Solution:
```bash
dnf install autofs -y
autofs enable --now autofs
vim /etc/auto.master
# added the line below to /etc/auto.master
/start      /etc/auto.start

vim /etc/auto.start
# added the line below to /etc/auto.start
files   -fstype=xfs     :/dev/sda1 

systemctl restart --now autofs
mount # to verify the /start is mounted on /dev/sda1
```

### Key Elements
- `autofs` is a service that can be used to mount filesystems on demand.
- It is primarily used for mounting NFS shares, but can also be configured for local device mounting.
- Use `man autofs` for more details.
- The file `/etc/auto.misc` provides good examples of configuration options.


## 8.3 Resizing LVM volumes
### Task
- Add 10GiB to the logical volume on which your root filesystem is mounted.
- Configure any additional required devices up to your discretion.
- Solution:

```bash
fdisk /dev/[dev name] # to create a new partition with 10 GiB more.
vgextend rhel /dev/sda2
lvextend -r -L +10G /dev/rhel/root # might not work, so try below instead
lvextend -r -l +5999 /dev/rhel/root
```

### Key Elements
- To grow the size of a logical volume, free extents must be available in the volume group.
- If no free extents are available, additional extents can be allocated by adding physical volumes to the volume group.
- While resizing the logical volume, you should always use the `-r` option to resize its filesystem as well.

## 8.4 Configuring directories for collaboration
### Task
- Create a group `sales` with users `lisa` and `lori` as its members.
- Ensure that the group `sales` has full access to the `/data/sales` directory. All files created in this directory should be group-owned by the group `sales`.
- Also ensure that files can only deleted by the user that has created the files, as well ass user `lisa`, who is a member of the group `sales`.

- Solution:
```bash
groupadd sales
useradd lisa -G sales
useradd lisa -G sales
mkldir -p /data/sales
chown lisa:sales /data/sales
chmod g+ws /data/sales
chmod +t /data/sales
```

### Key Elements
- Special permissions can be used ot get collaboration options.
- The Set-Group ID permission, if set on a directory, ensures that all files created in that directory will be group-owned by the group owner of that directory.
- Sticky bit, if applied on a directory, guarantees that only the user that is the owner of the file is allowed to delete files.