## 11.1 Managing user accounts and groups
### Task
- Create users `sarah` and `zeina`, and make them members of the group `staff` as a secondary group.
- Create users `bilal` and `bob`, and make them members of the group `visitors` as a secondary group.
- Set password expiration for these users only to 90 days. Do NOT change the standard password expirartion.
- Solution:

```bash
groupadd staff
groupadd visitors
useradd sarah -G staff
useradd zeina -G staff
useradd bilal -G visitors
useradd bob -G visitors
```
### Key Elements
- While creating a Linyx user, a group is created with the same name as the user.
- To privide access to additional resources, secondary group membership can be configured.
- Default settings fro creating users are in the `/etc/login.defs` file.

## 11.2 Managing passwords
### Task
- Disable login for user `sarah` without deleting the user account.
- Set user account `bob` to expire on Jan. 1st 2032.
- Ensure that the default password hashing algorithm for new users is set to `SHA256` (no need to change exisitng users).
- Enfoce a maximum password policy validity of 120 days for new users (no need to change existing users).
- Solution:

```bash
usermod -L sarah
usermod -e 2032-01-01 bob
vim /etc/login.defs
# edit the PASS_MAX_DAYS to:
PASS_MAX_DAYS 120
# edit the ENCRYPT_METHOD to:
ENCRYPT_METHOD SHA256
```

## 11.3 Configuring superuser access
### Task
- Configure user `sarah` such that she can perform any tasks using elevated `sudo` privileges.
- Configure user `zeina` such that she can manage user passwords, but not for user root.
- Solution:
```bash
usermod -aG wheel sarah # or add "sarah ALL=(ALL) ALL" to /etc/login.defs
vim /etc/login.defs
# add the line below:
zeina   ALL=/usr/bin/passwd,!/usr/bin/passwd root
```

### Key Elements
- To provide elevated privileges to perform system administration tasks, use `sudo`
- To easily modify current `sudo` privileges, use the `visudo` command.
- The `visudo` command opens the `/etc/sudoers` file, which has great examples.