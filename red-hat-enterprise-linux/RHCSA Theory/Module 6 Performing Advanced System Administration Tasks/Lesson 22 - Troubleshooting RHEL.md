# Lesson 22: Troubeshooting RHEL
- 22.1 Using Troubleshooting Modes
- 22.2 Changing the Root Password
- 22.3 Using the Boot Debug Shell
- 22.4 Troubleshooting Filesystem Issues
- 22.5 Fixing Network Issues
- 22.6 Managing Performance Issues
- 22.7 Troubleshooting Software Issues
- 22.8 Fixing Memory Shortage
- 22.9 Consulting Red Had Websites for Tips

## 22.1 Using Troubleshooting Modes

## 22.2 Changing the Root Password
- Enter Grub menu while booting
- While the line that loads the Linux kernel and add `init=/bin/bash`
- `mount -o remount,rw /`
- `passwd root`
- `touch /.autorelabel`
- `exec /usr/lib/systemd/systemd`

## 22.3 Using the Boot Debug Shell
- Purpose: If the system fails very early during startup, a special "debug shell" lets you drop into a root prompt before most services have started
- How it works: Enabling `debug-shell.service` will launch a root shell on the virtual console TTY9 (you don't need a password)
- When to use it: Turn it on only when you need to investigate why the machine won't finish booting. It gives you direct access to fix configuration or driver issues
- Security note: Because it gives password-free root access, disable or remove debug-shell.service as soon as you're done troubleshooting.

### Demo: Using the Eearly Boot Debug Shell

- `systemctl enable --now debug-shell.service` to enable the debug shell right now. This tells systemd to start a root shell on virtual console TTY9 at every boot (and starts it immediately if you're already running)
- Reboot or watch the next boot:
    - when the machine is startin up, press `Ctrl + Alt + F9` (on a Mac: cmd + option + fn + F9) to switch to TTY9
    - You will see a root prompt without being asked for a password. This is your emergency debug shell
-  `systemctl disable --now debug-shell.service` turn the debug shell off, once you're done troubleshooting. This removes the password-free root shell from TTY9 so it won't run again on future boots

## 22.4 Troubleshooting Filesystem Issues
### Troubleshooting Filesytem Issues
- Real on-disk corruption is rare and most filesystems fix themselves automatically
- The most common problem is a typo or wrong entry in `/etc/fstab`, which can drop you into an emergency shell at boot
    - To fix this, remount the root filesystem read-write (`mount -o remount.rw /`), open `/etc/fstab`, correct the mistake, save and reboot
- Over time, files on XFS or Ext4 can become fragmented (scattered around the disk), which can slow things down
    - For XFS, use `xfs_fsr` to automatically reorganize and defragment files
    - For Ext4, use `e4defrag` to defragment individuals files or entires directories

### Preventing /etc/fstab Related issues
- Issues often occur after modifying /etc/fstab
- To prevent having issues, do the following after making modifications
    - `mount -a` to mount all filesystems in /etc/fstab that haven't been mounted yet
    - `findmnt --verify` to verify syntax
    - `reboot` to verify all works well

## 22.5 Fixing Network Issues
### Understanding Common Network Issues
- `Wrong subnet mask`: all nodes in the same network should be in the same subnet
- `Wrong router`: the router must always be in the local network
- `DNS not working`: verify /etc/resolv.conf contents

### Demo: Verifying Network Configuration
- `ip addr show`
- `ip route show`
- `ping 8.8.8.8`
- `cat /etc/resolv.conf`
- `ping google.com`
- `dig google.com`

## 22.6 Managing Performance Issues
- Troubleshooting performance is an art on its own
- Focus on the four key areas of performance
    - memory
    - CPU load
    - disk load
    - network
- Use `top` to get a generic image, and more specialize tools only if you have a strong indication of what is wrong.

## 22.7 Troubleshooting Software Issues
- Dependency problems in RPM's
    - Should not occur when using repositories
- Library problems
    - Run `ldconfi` to update the library cache
- Use containers to avoid software dependency version issues

## 22.8 Fixing Memory Shortage
- Memory issues appear if available memory as shown by `free` is low
    - The definition of low depends on server workload
- As a first help to fix memory issues, swap space can be used
- `vmstat 2 25` to make sure that adding swap space doesn't lead to too much I/O traffic

## Lesson 22 Lab: Troubleshooting the Root Password
