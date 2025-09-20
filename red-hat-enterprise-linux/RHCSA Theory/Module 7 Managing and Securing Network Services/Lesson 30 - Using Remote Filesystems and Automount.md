# Lesson 30: Using Remote Filesystems and Automount
- 30.1 Configuring a Base NFS Server
- 30.2 Mounting NFS Shares
- 30.3 Understanding Automount
- 30.4 Configuring Automount
- 30.5 Setting up Automount for Home Directories

## 30.1 Configuring a Base NFS Server
### Demo: Configuring a Base NFS Server
```bash
dnf install nfs-utils
mkdir -p /nfsdata /home/ldap/ldapuser{1..9}
echo "/nfsdata *(rw,no_root_squash)" >> /etc/exports
echo "/home/ldap *(rw,no_root_squash)" >> /etc/exports
systemctl enable --now nfs-server
for i in nfs mountd rpc-bind; do firewall-cmd --add-service $i --permanent; done
firewall-cmd --reload
```
## 30.2 Mounting NFS Shares
- Make sure **nfs-utils** is installed
- Use `showmount -e nfsserver` to show exports
- Use `mount nfsserver:/share /mnt` to mount

## 30.3 Understanding Automount
1. Define the mount point
- In **/etc/auto.master**, tell autofs what directory to manage and which map file to use
```bash
/nfsdata /etc/auto.nfsdata
```

2. List your mounts
- In **/etc/auto.nfsdata**, map a name under /nfsdata to the real export. For example:
```bash
files -rw nfsserver:/nfsdata
```
- This makes /data/files automatically mount the NFS share

3. Enable the service
```bash
systemctl enable --now autofs
```

- Tip: Look at /etc/auto.misc for more syntax examples

## 30.5 Setting up Automount for Home Directories
- Often you want each user's home directory to mount automatically on login
- In your autofs map files (e.g `/etc/auto.home`), use `*` as a placeholder: `*     -rw     nfsserver:/home/ldap/&`
- Here, `*` matches any directory name under the mount point (e.g `/home/alice`, `/home/bob`), and `&` insert that name into the NFS export path
- When a user accesses `/home/username`, autofs mounts `nfsserver:/home/ldap/username` on demand