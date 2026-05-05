# Lesson 18: Working with Partitions and Mounts
- 18.1 Understanding Disk Layout
- 18.2 Exploring Linux Storage Options
- 18.3 Understanding GPT and MBR Partitions
- 18.4 Creating Partitions with `fdisk`
- 18.5 Creating and Mounting File Systems
- 18.6 Mounting Partitions through /etc/fstab
- 18.7 Using UUID and Labels
- 18.8 Defining Systemd Mounts
- 18.9 Creating a Swap Partition

## 18.2 Exploring Linux Storage Options
### Linux Storage Options
- Partitions: Think of it like carving a hard drive into separate "chunks". Each chunk is dedicated to a specific purpose (for example, one chunk for the operating system and another for your personal files).
- LVM Logical Volums: LVM (Logical Volume Manager) sits on top of partitions and lets you combine multiple disk chunks in a "pool". From that pool, you create volumes that can easily resize or snapshot (take point-in-time copies) without worrying about fixed partition boundaries.
- Stratis: Stratis is a newer, user-space tool that makes storage management simpler. Because it runs in user space, other programs can talk to it via an API to do things like thin provisioning (only using space as data is written) and automated snapshots.

### Linux Block Devices
- What are block devices: They are interfaces for storage drives (hard drives, SSDs, USB drives, etc.), and each one is named based on the driver and type of hardware
- Common names you'll see:
    - `/dev/sd[x]` - Used for SCSI or SATA disks (e.g., `/dev/sda`, `/dev/sdb`) 
    - `/dev/vd[x]` - Used for virtual disks in KVM/QEMU virtual machines (e.g., `/dev/vda`)
    - `/dev/nvmeXnY` - Used for NVMe SSDs, where `X` is the controller number and `Y` is the namespace (e.g., `/dev/nvme0n1`)
- How to list what you have:
    - Run `lsblk` to see all detected block devices and their mount points at a glance

### Understanding Partition Numbering 
- SCSI/DATA and Virtio Disks (sdX or vdX):
    - Paritions get simple numbers after the device name.
    - Example: `/dev/sda2` is the second parition on the first disk (`sda`)
    - Example: `/dev/sda1` is the first partition on the second disk (`sdb`)
- NVMe Disks (nvmeXnY):
    - Because the base device name already has numbers, partition add a "p" before the partition number.
    - Example: `/dev/nvme0n1p1` is the first partition on the first NVMe disk
    - Example: `/dev/nvme0n3p2` is the second partition on the third NVMe disk

### Understanding GPT and MBR partition
- MBR (Master Boot Record):
    - An older partition format from 1981
    - Only 512 bytes total for boot code and partition info
    - Can hold up to 4 partitions max, and drive bigger than 2 TiB won't work without tricks
    - To use more than 4 partitions, you must create extended/logical partitions inside on of those 4 slots.

- GPT (GUID Partition Table):
    - A new format (introduced around 2010)
    - Uses a protective MBR plus larger tables to store up to 128 partitions by default
    - Supports disks bigger than 2 TiB without any extra work
    - Overcomes MBR's size and parition-count limits

## 18.4 Creating Partitions with fdisk
### Partitioning Tools
- `fdisk` 
    - The classic tool that's been around for ages
    - Works with both MBR and GPT
    - On a new disk, pressing "g" inside fdisk creates a GPT table
- `gdisk`
    - A newer tool designed specifically for GPT disks
    - Automatically sets up GPT when you run it (no extra steps needed)
- `parted`
    - Designed to be easier and scriptable
    - Good for simple tasks, but some advanced options are hidden under menus

### Understanding Partition Types
- A partition type is a small code that tells the system what the partition is for (e.g., Linux filesystem, swap space, UEFI boot area, or LVM)
- In the past, having the correct type was critical. Nowadays, even if the wrong type is set, the partition often still works.
- To change a partition's type in fdisk, press `t` and then choose from a list of "aliases" (friendly names) instead of remembering numeric codes.
    - `linux`: standard Linux filesystem
    - `swap`: swap space for virtual memory
    - `uefi`: EFI system partition used for booting
    - `lvm`: A physical Volume for LVM (Logical Volume Manager)
- If you want to see all available types and aliases, press `l` inside fdisk and read the list

## 18.5 Creating and Mounting File Systems
### Creating Filesystems
- XFS (default on RHEL):
    - Designed for high performance and large storage
    - Uses "copy-on-write" (CoW) to keep data safe.
    - You can grow (increase) an XFS filesystem while it's mounted, but you cannot shrink it
- Ext4 (used in older RHEL versions)
    - Backward compatible with Ext2, so older tools still work
    - Uses journaling to protect data against crashes
    - You can both grow and shrink an Ext4 filesystem as needed
- vfat (FAT32)
    - A generic filesystem that works on Linux, Windows, and macOS.
    - Commonly used on USB sticks or SD cards for sharing files between different operating systems.
- Btrfs (newer filesystem)
    - Offers advanced features like built-in snapshots and checksums
    - Not installed by default on RHEL, but available if you need those next-generation capabilities

### Creating Filesystems
- `mkfs.xfs` to create an XFS filesystem
- `mkfs.ext4` to create an Ext4 filesystem
- `mkfs.vfat` to create a vfat filesystem
- Use `mkfs.[TAB][TAB]` to show a list of available filesystems
- Do NOT use `mkfs` as it will create an Ext2 filesystem

### Mounting Filesystems
- To attach a filesystem: Use the `mount` command with the device (partition) and a directory as its "mount point". For example `mount /dev/vdb1 /mnt`
- Before removing or unplugging a device: 
    - You must unmount it so the system stops writing to it. Use `umount /mnt`
    - If you get an error saying files are still open, run `lsof /mnt`. That tells you which processes are keeping files open in `/mnt` so you can close them first.
- `mount` to see what's currently mounted. It will list every mounted filesystem (including special kernel mounts like `proc` and `sysfs`)
- `findmnt` to find out exactly where a filesystem lives in your directory tree. This shows each device or image and the path where it's mounted, in a neat, readable format.

## 18.6 Mounting Partition through /etc/fstab
### Understaning /etc/fstab
- `/etc/fstab` is the file where you list filesystems you want to mount automatically at boot.
    - Example: `/dev/sdb1 /data ext4 default 0 0`. It means:
        - Take the partition `/dev/sdb1`
        - Mount it under the directory `/data`
        - Use the `ext4` filesystem format
        - Apply the `defaults` mount options (standard settings)
        - The two zeros at the end tell the system not to run dump or fsck on this partition automatically
- How systemd uses it: When the machine starts, the `systemd-fstab-generator` reads `/etc/fstab` and creates its own "mount units" so that these filesystems get mounted before you log in.
- After editing `/etc/fstab`, If you change or add a line, run `systemctl daemon-reload`. This tells systemd to re-read `/etc/fstab` and updates its mount instructions without needing to reboot

### Avoiding Boot-Time Mount Issues
- If there's a mistake in `/etc/fstab`, the system will pause at boot and drop you into a recovery shell.
- After you add or change entries in `/etc/fstab`, run `mount -a` to immediately try mounting everything and catch errors early.
- `findmnt -verify` to check your fstab syntax without mounting by running. It tells you if any lines are invalid before you reboot

## 18.7 Using UUID and Labels
- Why it matters: In data centers or virtual environments, the kernel's device name (like `/dev/sda` or `/dev/vdb`) can change on reboot. To make mounts reliable, we use UUIDs or filesystem labels instaeld of raw device names

- UUID (Universally Unique Identifier)
    - Every filesystem gets a unique ID when it's created
    - You can find it with `blkid` or `lsblk -f`
    - In `/etc/fstab`, you can mount using `UUID=xxxxxxxxxx-xxxxxx-xxxxx-xxxxxxxx` so that even if the device node changes, the right filesystem is always mounted.
- Label:
    - When making a filesystem (for example with `mkfs.ext4`), you can assign a human-readable name by using the `-L` option (e.g `mkfs.ext4 -L mydata /dev/vdb1`)
    - Labels are easier to remember than UUIDs, but UUIDs are guaranteed to be unique
- Where to find them:
    - use `lsblk -f` or `blkid` to see both labels and UUIDs
    - you'll also see symlinks under `/dev/disk/by-uuid/` and `/dev/disk/by-label/` pointing to the correct device node

### Managing Persistent Naming Attributes
- `blkid` to show all block devices along with their UUIDs and labels
- `tune2fs -L` to set or change the label on an existing Ext* filesystem
- `xfs_admin -L` to set or change the label on an existing XFS filesystem
- `mkfs.* -L` to assign a label immediately

### XFS UUID on Cloned Devices
- UUIDs are supposed to be unique
- If an XFS filesystem is cloned, the UUID is cloned as well
- Use `xfs_admin -U generate /dev/sdb1` to generate a new UUID

## 18.8 Defining Systemd Mounts
- Lines in /etc/fstab are converted to systemd mounts
    - Check /run/systemd/generator for the automatically generated files
- Mounts can be created using systemd .mount files
- Using .mount files allows you to be more specific in defining dependencies
- Use `systemctl cat tmp.mount` for an example

## 18.9 Creating a Swap Partition
### Managing Swap
- Swap is space on a disk used like extra RAM when physical memory fills up
- Why you need it: every Linux system should have some swap. The amount depends on how you plan to use the server (e.g., heavy memory workloads migh need more swap)
- Where to put swap: You can create swap on a dedicated partition or as a swap file anywhere on a block device
- Setting up a swap partition:
1. Create a partition and set its type to linux-swap (using fdisk, gdisk, or parted)
2. `mkswap /dev/sdXn` to format the partition for swap. Replace `/dev/sdXn` with your actual swap partition.

- `swapon /dev/sdXn` to activate swap. This tell the kernel to start using that partition as swap space
- `/dev/sdXn none swap defaults 0 0` put in /etc/fstab for your swap partition

## Lesson 18 Lab: Managing Partitions
- To work on this lab, you'll need to creat a 10GiB additional hard disk on your virtual machine. This disk needs to be completely available
    - Create a primary partition with a size of 1GiB. Format it with Ext4, and mount it persistently on /mounts/files, using its UUID
    - Create an extended partition that includes all remaining disk space. In this partition, create 500 MiB XFS partition and mount it persistently on /mounts/xfs, using the label myxfs
    - Create a 500MiB swap partition and mount it persistently