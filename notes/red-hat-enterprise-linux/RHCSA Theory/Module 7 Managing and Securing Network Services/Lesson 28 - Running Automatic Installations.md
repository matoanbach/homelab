# Lesson 28: Running Automatic Installations
- 28.1 Exploring Solutions for Automatic Installations
- 28.2 Creating a Kickstart File
- 28.3 Using a Kickstart File for Automatic Installations
- 28.4 Installing Virtual Machines


## 28.1 Exploring Solutions for Automatic Installations
### Understanding Automatic Installations

- **Kickstart**: A simple text file driving a fully unattended RHEL install (partitioning, packages, post-install scripts). You can boot via PXE or local media and point to your kickstsart file - RHEL installs itself exactly the same way every time
- **Vagrant**: A wrapper around virtualization tools (VirtualBox, libvirt, VMWare) that lets you spin up reproducible VMs with a simple *Vagrantfile*, ideal for development or testing labs
- **Cloud-init**: The de-facto standard for cloud images: metad drives hostname, SSH keys, package installs, and service configuration on first boot - perfect for AWS, OpenStack, Azure, etc.
- In short, use **Kickstart** when you need to automate bare-metal or VM installs from scratch, **Vagrant** for local dev/test VMs, and **cloud-init** for provisioning in the cloud

## 28.2 Creating a Kickstart File
### Creating a Kickstart File
1. **Grab the sample Kickstart**
- After you finish a normal, interactive install, Anaconda automatically saves what it did to
```bash
/root/anaconda-ks.cfg

```
2. **Customize it**
- Open `/root/anaconda-ks.cfg` in your editor and teak any settings you need - parition layout, packages, network, post-install scripts, etc.

3. **Check your syntax**
- Before relying on it, run:
```bash
ksvalidator /root/anaconda-ks.cfg
```

### Using Common Kickstart File Options
- `url --url="http://myserver/..."` specifies which URL to access for the installation media
- `repo --name="myrepo" --baseurl=...` how to access repositories
- `text` to force text mode installation
- `vnc --password=password` to enable the VNC viewer for remote access to the installation
- `clearpart --all --drive=sda,sdb` to remove all partitions
- `part /home --fstype=ext4 --label=home --size=2048 --maxsize=4096 --grow` to create and mount a partition
- `autopart` to automatically create root, swap and boot partition
- `network --device=ens33 --bootproto=dhcp` configures the primary network interface
- `firewall --enabled --service=ssh,http` to open the firewall
- `timesource --ntp-server pool.ntp.org` to set up NTP
- `rootpw --plaintext secret` to configre plain text root password
- `selinux --enforcing` to activate SELinux

## 28.4 Installing Virtual Machines
### Understanding RHEL-based Virtualization
- What KVM is: The Linux kernel's built-in hypervisor ("Kernel-based Virtual Machine") that lets your RHEL server run multiple full guest operating systems side-by-side
- Host vs .guest:
    - As a `host`, RHEL uses KVM to create and manage virtual machines
    - A a `guest`, RHEL can itself run inside another KVM host
- Why use it: 
    - Isolate workloads by running different OS instances on the same physical hardware
    - Easily spin up, snapshot, migrate, and manage VMs for testing, development, or production services - all with native Linux performance and toolling

### Configuring RHEL as Virtualization Host
1. Check hardware support
```bash
grep -E 'svm|vmx' /proc/cpuinfo
```
- You should see vmx (intel) or svm (amd) flags - without them, KVM won't run

2. Install the host tools
```bash
dnf group install "Virtualization Host"
```
- This pulls in QEMU, libvirt, virt-managaer, and related packages

3. Validate your setup
```bash
virt-host-validate
```
- It'll confirm CPU extensions, kernel modules, user permissions, and networking are all ready for hosting VMs

### Installing Virtual Machines
1. `dnf install virt-install` to install the VM tool
2. Create a new VM
```bash
sudo virt-install \
  --name testvm \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20 \
  --os-type linux \
  --cdrom /rhel9.iso
```
- This spints up a VM named "testvm" with 2GB RAM, 2 CPUs, a 20GiB disk, and installs from your ISO
2. Web-Based (Cockpit)
- `dnf install cockpit-machines` to install the cockpit-machines plugin
- `systemctl enable --now cockpit.socket` to enable and start Cockpit
- Go to `https://localhost:9090` to create VM

- **Noted**: Modern macOS hosts often don't support nested KVM, so you may see errors if you try to run a VM inside Parallels or VMware on Mac.

## Lesson 28 Lab: Configuring a Kickstart File
- Create a Kickstart file with the name my-ks.cfg and make sure it can be used for an automated installation, and meets the following requirements:
    - The installer prompts for a password
    - Network connectivity will be enabled on boot
    - The local machine name is et to server10.example.com


```bash
cd /usr/share/doc
ls *kickstart
```