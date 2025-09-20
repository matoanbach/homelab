# Lesson 20: Managing Stratis
- 20.1 Understanding the Storagae Stack
- 20.2 Creating Stratis Volumes
- 20.3 Using Stratis Snapshots

## 20.1 Understanding the Storage Stack
### Storage Stack
- The Linux kernel's block device layer lets RHEL support many types of storage drives (SATA, NVMe, iSCSI, etc.) by loading the correct driver.
- `Multipath` is an optional feature for SAN/NAS setups: If a storage array can be reached through multiple cables or network paths, Multipath combines those paths into one device and provides failover if one path breaks
- `Partitions` divide a single physical disk into separate sections so you can dedicate each section to a different purpose (eg, one partition for /boot, another for /home)
- `RAID` (Redundant Array of Inpendent Disks) takes multiple physical disks and combines them into a single volume that can survive a disk failure (for example, RAID 1 mirrors data or RAID 5 strips with parity)
- `LVM` (Logical Volume Manager) sits on top of one or more disks (or partitions) and creates a flexible "pool" of storage. From that pool, you carve out logical volumes that can be resized, moved, or snapshooted without touching the underlying disks direclt.
- Once you have a storage volume (whether it's a simple partition, a RAID array, or an LVM volume), you can use it for any of several tasks:
    - Hosting a `filesystem` (for example, XFS or Ext4)
    - Storing a `database` (running MySQL, PostgreSQL, etc.)
    - Acting as a `Ceph OSD` (in a Cepth storage cluster, each OSD daemon uses a block device to store object data)

### Understanding LVM Usage Options
- `LVM + LUKS Encryption` - You can put an encrypted container (via LUKS) inside an LVM logical volume. This lets you encrypt the entire block device before you create filesystems on it
- `LVM + VDO (Deduplication & Compression)` - When you create an LVM volum, you can enable VDO underneath it. VDO automatically deduplicates and compresses data at the block level, saving disk space without any changes to your filesystem
- `Using LUKS or VDO on Their Own` - You don't have to use LVM to get encryption or dedupe. You can set up a LUKS-encrypted device or a VDO volume directly on a raw partition or disk without involving LVM

## 20.2 Creating Stratis Volumes
### Understanding Stratis
- Stratis always formats its volumes using the XFS system
- Volumes created by Stratis are thin-provisioned by default, meaning the only consume physical space as you write data.
- When you create a Stratis volume, its storage comes from a central "Stratis pool" instead of individual disks or partitions.
- Each Stratis volume must be at least 4 GiB in size, so you cannot create smaller volumes
- Because volumes share the thin-provisioned pool, you must use Stratis's own tools (like `stratis pool list` and `stratis filesystem list`) to track how much free space remains before creating or growing volumes

### Managing Stratis
- To use Stratis, install two packages
    1. stratisd (the background daemon)
    2. stratis-cli (the command-line tool)
- Use the `stratis` command to do everything:
    - Create a storage pool from one or more block devices
    - Create and manage filesystem inside that pool
    - Check pool health, snapshots, and usage
- Stratis's CLI has built-in tab completion, so typing stratis <Tab> <Tab> show your available commands and options.
- `stratis pool list` to keep an eye on free space in your pool by running. If the pool is nearly full, you'll need to add more devices before creating or expaning volumes.
- `x-systemd.requires=stratisd.service` is required in `/etc/fstab`. It says "only try to mount this after the Stratis deamon is running". Otherwise, your boot might stall because the pool isn't ready yet.

### Demo: Managing Stratis Volumes
```bash
dnf install stratis-cli stratisd
systemctl enable --now stratisd
stratis pool create pool mypool /dev/sdb
stratis pool list
stratis pool add-data mypool /dev/sdc
stratis blockdev list
stratis fs create mypool myfs
mkdir /myfs
lsblk --output=UUID /dev/stratis/mypool/myfs >> /etc/fstab
# Edit /etc/fstab to include:
UUID=d8sff... /myfs xfs x-systemd.requires=stratisd.service 0 0
```

## 20.3 Using Stratis Snapshots
### Understanding Stratis Snapshots
- A stratis snapshot is a metadata copy that allows you to access the state of the snapshot at any time
- A snapshot is NOT a backup, but can be helpful in acessing deleted files
- A snapshot is mounted by its device name, not by UUID

### Demo: Using Stratis Snapshots
```bash
dd if=/dev/zero of=/myfs/bigfile bs=1M count=2000
stratis pool list
stratis fs list
stratis fs snapshot mypool myfs myfs-snap
stratis fs list
rm /myfs/bigfile
mkdir /myfs-snap
mount /dev/stratis/mypool/myfs-snap /myfs-snap
ls -l /myfs-snap
stratis fs destroy mypool myfs-snap
```

## Lesson 20 Lab: Managing Stratis
- Create a stratis pool with a size of 10G, with the name stratispool, containing 2 filesystems: myfiles and myprograms
- Mount these volumes persistently on /myfiles and /myprograms
- Copy all files from /etc/ that have a name starting with an a, c or f to /myfiles
- Create a snapshot of the `myfiles` filesystem
- Delete all files from `/myfiles` that have a name starting with an a
- Verify that you can still access these files from the snapshot