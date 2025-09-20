# Lesson 19: Using Logical Volume Manager
- 19.1 Understanding Advanced Storage Solutions
- 19.2 Exploring LVM setup
- 19.3 Creating an LVM Logical Volume
- 19.4 Understanding Device Mapper and LVM Device Names
- 19.5 Resizing LVM Logical Volumes
- 19.6 Reducing Volume Groups

## 19.1 Understanding Advanced Volume Manager
### RHEL Advanced Storage Solutions
- LVM Logical Volumes
    - Used by default in RHEL installs
    - Lets you combine disks or partitions into a "pool", then create volumes you can reszie or snapshot without repartitioning
- Stratis
    - A newer, user-space storage manager that automatically creates thin-provisioned pools
    - Because it runs in user space, other programs can interact with it via an API
- Virtual Data Optimizer (VDO)
    - Optimizes disk usage by deduplicating and compressing data
    - Now built into LVM so you can enable dedupe/compression on logical volumes directly

## 19.3 Creating an LVM Logical Volume
### LVM Creation Steps
1. Partition the disk for LVM
    - Use your perferred tool (e.g., `fdisk` or `gdisk`) to create a new partition
    - Set that partition's type to `Linux LVM` so the system knows it will be used for LVM
2. Turn the partitipn into a Physical Volume (PV)
    - `pvcreate /dev/sdb1` to tell LVM treat this /dev/sdb1 as a block of storage that i can manage
3. Create a Volume Group (VG)
    - `vgcreate vgdata /dev/sdb1` to combine the PV (/dev/sdb1) into a group called vgdata. Thik of a VG as a storage pool
4. Create a Logical Volume (LV)
    - `lvcreate -n lvdata -L 1G vgdata` to carve out a 12GiB volume called lvdata from the vgdata pool
5. Format the LV with a filesystem
    - `mkfs.xfs /dev/vgdata/lvdata` to make /dev/vgdata/lvdata an XFS filesystem (you could choose another fs type if needed)
6. Mount the new filesystem and make it persistent
    1. `mkdir /mnt/lvdata` to create a mount point
    2. `/dev/vgdata/lvdata /mnt/lvdata xfs defaults 0 0` in /etc/fstab
    3. `mount -a` and `lsblk`

### Understanding Extents
- What are extents: They're the basic allocation units that LVM uses to carve out space. Think of them like equal-sized "chunked" in your storage pool
- Setting the extent size:
    - `vgcreate -s 8M vgdata /dev/sdb1` to make every extent in the `vgdata` pool exactly 9 MiB
- Why it matters: All logical volumes you create inside `vgdata` will use these 9MiB chunks. If you later grow or shrink a logical volume, it does so in multiples of 8 MiB
- `vgdisplay vgdata` to check your extent size. Among the displayed properties, you'll see the "PE Size", which is the extent size (e.g., 8.00 MiB)
- `vgs` to display information about volume groups

## 19.4 Understanding Device Mapper and LVM Device Names
### Understanding Device Mapper Names
- What is the Device Mapper? - It's the kernel subsystem that provides a uniform way to manage and present block devices. It's used by LVM, Stratis, Multipath, and other storage layers.
- Kernel-assigned names: When you create a device-named volume, the kernel gives it a temporary name like `/dev/dm-0` or `/dev/dm-1`. These aren't guaranteed to stay the same after a reboot.
- Persistent names via symbolic links:
    - To get stable names, the system creates links under `/dev/mapper`. For example, if you have a logical volume called `lvdata` in volume group `vgdata`, you'll see: `/dev/,apper/vgdata-lvdata`
    - You can also use the equivalent LVM shortcut like `/dev/vgdata/lvdata`
    - Both point to the same block device, but they remain consistent across reboots.
- Why this matters: Always use the `/dev/mapper/...` or `/dev/<vg>/<lv>` path in scripts and `/etc/fstab`. That way, your configuration won't break if the kernel's `/dev/dm-*` numbers change.

## 19.5 Resizing LVM Logical Volumes
### Resizing Logical Volumes
- `vgs` to see how muchh unassigned space your VG (volume group) has.
- `vgextend` to add one or more physical volumes (PVs) to that VG like `vgextend <VGName> /dev/sdXn`
- `lvextend -r -L +1G /dev/`
- `-r` (resize) to automatically frow the underlying filesystem at the same time.
    - For `ext4`, it uses `resize2fs` under the hood
    - For `xfs`. it uses `xfs_growfs`
- Shrinking an LV is only supported on Ext4 (not XFS)

### Demo: Resizing a Logical Volume
1. Create 2 partitions with a size of 1 GiB each and set the `lvm` partition type
2. `vgcreate vgfiles /dev/sde1` to create a volume group on the first partition. This makes a storage pool named `vgfiles` using the first 1 GiB
3. `lvcreate -l 255 -n lvfiles vgfiles` to create a 1GiB Logical Volume inside that group
    - `-l 255` uses all available extents (1 GiB) in `vgfiles`
    - The new LV is called `lvfiles` (so its path is `/dev/vgfiles/lvfiles`)
4. 
```bash
mkfs.ext4 /dev/vgfiles/lvfiles
mkdir /mnt/lvfiles
mount /dev/vgfiles/lvfiles /mnt/lvfiles
df -h /mnt/lvfiles
```
5. `vgs vgfiles` to check free space in the Volume Group
6. `vgextend vgfiles /dev/sde2` to add the second 1GiB partition to the Volume Group
7. `lvextend -r -l +50%FREE /dev/vgfiles/lvfiles` to grow the Logical Volume by half of the newly free space
8. `df -h /mnt/lvfiles` to verify the new size

## 19.6 Reducing Volume Groups
- When you have multiple Physical Volumes (PVs) in one Volume Group (VG), you can remove a PV only if all the data on that PV is moved elsewhere
- You cannot remove a PV if the other PV's don't have enough free space to take over its "extents"
- Step 1: Move data off the PV you want to remove
    - Use `pvmove /dev/sdXn` to relocate all the logical-volume extents from that specific PV onto the remaining PV(s) in the VG.
- Step 2: Remove the empty PV from the VG
    - use `vgreduce vgname /dev/sdXn` to delete that now-empty PV from the volume group

### Demo: Removing a PV from a VG
```bash
fdisk       # to create 2 partitions with a size of 2GB each and set the type of lvm
vgcreate vgdemo /dev/sdf1
lvcreate -L 1G -n lvdemo /dev/vgdemo
vgextend vgdemo /dev/sdf2
pvs         # to show all extents as available on /dev/sdf2
lvextend -L +500M /dev/vgdemo/lvdemo /dev/sdf2 # ensure that free extents are used on sdf2 by adding the device name
pvs         # shows used extents on /dev/sdf2
mkfs.ext4 /dev/vgdemo/lvdemo
mount /dev/vfdemo/lvdemo /mnt
df -h
dd if=/dev/zero of=/mnt/bigfiles bs=1M count=1100 # ensures that data is on PVs
pvmove -v /dev/sdf2 /dev/sdf1                     # moves all used extents from sdf2 to sdf1 (can take a while) 
pvs                                               # will show that /dev/sdf2 is now unused
vgreduce vgdemo /dev/sdf2   #is now allowed
```

## Lesson 19 Lab: Managing Logical Volumes
- To perform the tasks in this lab, add a new 10GiB disk to your virtual machine
    - Create an LVM logical volume with the name lvdb and a size of 1GiB. Also create the VG and PV that are required for this LV
    - Format this LV with XFS filesystem and mount it persistently on /mounts/lvdb