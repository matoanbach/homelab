## 12.1. Permissions
### Task
- Configure access to the `/data/staff` directory such that it meets tbe following requirements:
    - Members of the group `staff` have full access.
    - Group members can only delete files they have created.
    - The directory contains the file `rootfile` which can be read by all group members, but not deleted by anyone.
    - Leave user and other permissions at their default setting. 

- Solution:

```bash
mkdir /data/staff
chown :staff /data/staff
chmod +t /data/staff
touch /data/staff/rootfile
chattr +i /data/staff/rootfile
lsattr /data/staff/rootfile
```

### Key Elements
- Access to directories is based on UGO.
- When finding a match, Linux looks no further.
- Special permissions can change the default behavior for deleting files.
- Attributes can be used to prevent file operations regardless of the permissions that are set.

## 12.2 Managing SELinux file context
### Task
- Install the `vsftpd` service and configure it such that anonymous uploads are permitted. Use the following guidelines:
    - `anonymous_upload` options must be enabled in `/etc/vsftpd/vsftpd.conf`.
    - Permission mode 777 must be set ont the `/var/ftp/pub` directory.
    - SELinux must be configured accordingly.
- To test anonymous file upload, install the `lftp` client, and use the following steps:
    - Open a session using `lftp localhost`
    - Use `cd pub`
    - Use `put /etc/hosts`
- Solution:
```bash
dnf install -y vsftpd
vim /etc/vsftpd/vsftpd.conf
# Edit vsftpd.conf to such:
write_enable=YES
ano_upload_enable=YES
# Exit vsftpd.conf

systemctl enable --now vsftpd

journalctl | grep sealert # to find the error related to vsftpd policies unmatching

getsebool -a | grep ftp # to find the right policies for ftp
setsebool -P [boolean] on

semanage fcontext -a -t [the right policy for /var/ftp/pub] "/var/ftp/pub(/.*)?"

# verify it working
lftp localhost
cd pub
put /etc/hosts
```

### Key Task
- On the RHCSA exam, your system must be configured with SELinux in enforcing mode.
- File context is used for access to files and directories.
- Use `man semanage-fcontext` for useful examples.
- Booleans are `on/off-switches` used to enable or disable specific functionality.
- If `sealert` is available, it can be used to print interpreted messages about SELinu denials.

## 12.3 Configuring SSH
### Task
- Configure SSH such that only users `students` and `linda` are allowed to open a session to your SSH host.
- Solution:

```bash
man sshd_config # to find the right variable to set
vim /etc/ssh/sshd_conf

# edit /etc/ssh/sshd_conf
AllowUsers student linda
# exit /etc/ssh/sshd_conf

systemctl restart sshd

ip a # to see the ip addr of the host machine
ssh student@[ip addr]
```
### Key Elements
- SSH is an essential service on Red Hat Enterprise Linux.
- On RHEL 9, password-based root login default is denied.
- To enable specific settings, use the main configuration file `/etc/ssh/sshd_config`

## 12.4 Managing SELinu port context
### Task
- Configiure the `httpd` service to listen on port 82 only.
- Solution:
```bash
man semanage-port
vim /etc/httpd/conf/httpd.conf
# edit /etc/httpd/conf/httpd.conf
Listen 82
# exit /etc/http/conf/httpd.conf

semanage port -m -t http_port_t -p tcp 82
```
### Key Elements
- When services need to be accessed on non-default port, SELinux needs to be configured to allow this.
- Use `man semanage-port` for information and examples.
- For additional information, use the logs created by `sealert`.
- Never forget to interpret messages in `/var/log/audit/audit.log` as well.