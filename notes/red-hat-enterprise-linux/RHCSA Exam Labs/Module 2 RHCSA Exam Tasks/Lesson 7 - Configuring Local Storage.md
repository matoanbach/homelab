## 7.1 Managing MBR partitions
### Task
- On the primary disk in your server, add an extended partition that includes all remaining disk space.
- Within this extended partition, create a 1GiB logical partition.
- Format this partition with the Ext4 filesystem.
- Mount the partition persistently on the directory `/mnt/data`, using the label **EXTFILES**

### Key Elements
- MBR is old, but sill used a lot, mainly on smaller Linux installations.
- In MBR, there is place for 4 partitions. If more partitions are needed, the fourth partition should be created as an extended partition.
- Within the extended partition, logical partitions can be created.
- After formatting, the partition can be mounted.
- To mount the partition, it's recommended not to refer to its device name, but to use a lable or a UUID instead.
- Use `blkid` to find labels of formatted devices.

- Solution:
    ```bash
    fdisk /dev/[dev name] # to first create an extended MBR partition and then create a new logical partition
    mkfs.ext4 -L EXTFILES /dev/[dev name]/[newly created partition]
    vim /etc/fstab
     # put the below into /etc/fstab
    LABEL=EXTFILES      /mnt/data    ext4   defaults 0 0

    mkdir /mnt/data
    findmnt --verify # to verify the syntax in /etc/fstab
    mount -a
    reboot # to verify one more time
    ```

## 7.2 Managing GPT partitions
### Task
- Create a GPT partition with a size with 2 GiB on your second hard disk.
- Format this partition with the `vfat` filesytem.
- Mount this partition on the directory `/mnt/files`, using its UUID.
- Solution:

```bash
# first step is to add another hard disk that is bigger than 2GiB
fdisk /dev/sdb 
press g # to create an GPT type
press n # to create a Linux Filesystem partition (compatible with vfat)
press w # to save the configuration

mkfs.vfat /dev/sdb1
blkid /dev/sda1 | awk '{ print $1 }' >> /etc/fstab
vim /etc/fstab 
# write the below
UUID=...    /mnt/files   vfat   defaults 0 0

findmnt --verify # to verify the /etc/fstab syntax
mount -a 
reboot # to verify the syntax again
```

### Key Elements
- GPT was introduced in 2010 to bypass limitations of the MBR partitioning scheme.
- As 128 partitions can be treated, there is no more difference between primary, extended, and logical partitions.
- The vfat filesystem can be mounted on Linux, Windows, and MacOS, and for that reason is very compatible.
- UUIDs can be used to mount filesystems in a device-independent way.
- The vfat filesystem doesn't support any labels.

## 7.3 Managing LVM
### Task
- On the secondary hard disk, add a 2GiB partition to be used for creating LVM logical volumes.
- Create a volume group with the name `vglabs`, and add the partition you just created in it.
- In this volume group, create a logical volume with the name `lvlabs`, which uses half of the available disk space in the logical volume.
- Format this logical volume with the XFS filesystem.

- Solution:
```bash
fdisk /dev/sda
press n # to create a new partition type Linux LVM (lvm as an alias)
press w # to save and exit

vgcreate vglabs /dev/sda1
lvcreate -l 50%FREE -n lvlabs vglabs
mkfs.xfs /dev/vglabs/lvlabs
pvs # to list all available pvs
vgs # to list all available vgs
lvs # to list all available lvs
```

### Key Elements
- LVM logical volumes are allocated from a volume group.
- The volume group is composed of one or more physical volumes, which represent available block devices.
- If a partition is used as a physical volume, it should be marked with the lvm partition type.
- While creating a volume group, the physical extent size is used to specify the minimal allocation unit.
- Each volume group uses one physical extent to store metadata.

## 7.4 Managing swap
### Task
- Create a 1GiB swap file with the name `/swapfile`.
- Mount this swap persistently.

- Solution:
```bash
touch /swapfile
dd if=/dev/zero     of=/swapfile    bs=1M   count=2024
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon --show # to verify the /swapfile is on
free -m # also to verify more swap space are addded
```

### Key Elements
- On Linux, swap can make working with memory more efficient, as unused application memory can be moved to swap.
- Swap can be allocated on a block device, or on a swap file.
- After creating an empty file with the `dd` utility, it can be treated as any other swap file.