# Lesson 26" Securing RHEL with RELinux
- 26.1 Understanding the Need for SELinux
- 26.2 Using SELinux Modes
- 26.3 Exploring SELinux Components
- 26.4 Using File Context Labels
- 26.5 Finding the Right Context
- 26.6 Managing SELinux Port Access
- 26.7 Using Booleans
- 26.8 Analyzing SELinux Log Messages
- 26.9 Troubleshooting SELinux

## 26.1 Understanding the Need for SELinux
### Understanding the Need for SELinux
- Linux already has the old UNIX security model, but only covers bios and pieces of what modern systems need.
- SELinux sits on top of that and locks down every part of the OS with a single, consistent policy.
- Rule of thumb: "**If it's not explicitly allowed, it's automatically denied.**"
- That means any new or unrecognized service won't run until you give it an SELinux rule.
- Well-known services (like Apache, SSH, etc.) come with policies that "just work"
## 26.2 Using SELinux Modes
### Managing SELinux States

- `getenforce` to check the current mode
- `setenforce` to switch modes on the fly
    - For example,
        ```bash
        setenforce 0
        setenforce 1
        ```
- Edit `/etc/selinux/config` and set `SELINUX=enforcing` or `=permissive`. Then reboot.
### Managing SELinux States while Booting
- SELinux state can be at boot time using a kernel parameter
    - `enforcing=0` will start in permissive mode
    - `enforcing=1` will start in enforcing mode
    - `selinux=0` disabled SELinux
    - `selinux-1` enabled SELinux
- Access thhe Grub bootloade prompt to change the settings while booting

## 26.3 Exploring SELinux Components
### Exploring SELinux Components
- SELinux eforces access by labeling everything with a "context" and only allowing actions that match its policy:
    - **Context labels** are tags in the form, which carry security information:
        ```bash
        user:role:type:level
        ```
    - **Source objects** (the active party) are usually processes, running under a particular SELinux user and role
    - **Target objects** (the passive party) are things those processes want to touch - files, directories, network ports, sockets, etc. - each with its own context label
    - **Policy rules** then say "a process with context A can (or cannot) perform action X on an object with context B"

- For example, the Apache web server process (httpd_t) might be allowed to read files labeled `httpd_content_t` but denied access to files labeled shadow_t (where the password database lives)
- In short: every process and resource gets a context label, and SELiux's rule set defines which label-combinations are permitted

### Managing SELinux
- **Assigning contexts**: you fix access denials by giving files, directories or network ports the correct SELinux label so they match an existing policy rule.
- You'll need to apply a context that matches a specific rule
- Booleans allow parts of the SELinux policy to be rewritten to allow or disallow specific functionality in an easy way


## 26.4 Using File Context Labels
### Understanding Context Labels
- Every file, process, port, or other object in SELinux gets a "context" tag in the form `user:role:type:level`
- **user** and **role** identify the SELinux user account and the role it's performing (these usually stay constant under default policies.)
- **type** is the key part you'll work with - things like httpd_t for Apache processes or `var_log_t` for logs files. SELinux policy rules match a process's type against an object's type to decide whether the action is allowed
- **level** (the MLS/MCS part) is almost always ignored on RHEL exams, so you can safely focus on type
- To see an object's full context, many commands accept a `-Z` flag. For example:
```bash
ls -Z /var/www/html/index.html
ps -Z | grep httpd
```
- Under the good, SELinux enforces "if a process's type isn'y explicitly permitted to access an object's type, it's denied", so getting that type label right is how you fix most SELinux denials

### Managing File Context Labels
1. Define the correct label for a file or directory in the SELinux policy (this does not change anything on disk)
    - `semanage fcontext -a -t <type> '<path-pattern>'` to add a new rule
    - `semanage fcontext -m -t <type> '<path-pattern>'` to modify an existing rule
2. Apply those policy rules to the actual filesystem so files gain the new context
    - `restorecon -Rv <path>` to relabel that directory tree immediately.
    - Or `touch /.autorelable` and reboot - SELinux will relabel everything at startup
3. Don't use `chcon` for permanent changes. It only alters the live context and will be undone next time you run `restorecon` (or the system relabels)
4. `semanage fcontext -l -C` to see only your custome file-context entries in the policy
5. `man semanage-fcontext` for full documentation
6. `grep AVC /var/log/audit/audit.log` to see the error logs

## 26.5 Finding the Right Context
### Findint the Right Context
- When you put a service or data in a non-standard location, you need to figure out what SELinux type it should carry so you policy will let it run. Here are the go-to methods
1. Check the default policy
`ls -Z <path>`
2. Read the docs
`dnf install selinux-policy-doc`
3. Use the trouble-shooter. It will analyze the denial and suggest the exact semanage.
`sealert -a /var/log/audit/audit.log`

- In short: look up the built-in rules, read the policy docs, or let `sealert` tell you the correct type

## 26.6 Managing SELinux Port Access
### Managing Ports
- Every TCP/UDP port in SELinux has `type` (for example, http_port_t for HTTP on port 80)
- **Default services** already have the correct ports labelled, so Apache can bind to 80 without extra steps
- If you want your service to listen on a non-standard port, you must tell SELinux about it. For example, to allow HTTP on port 8080:
```bash
semanage port -a -t http_port_t -p tcp 8080
```

- View existing port -> type mappings with:
```bash
semanage port -l
```
- `man semanage-port` for more examples and options

## 26.7 Using Booleans
- A boolean is an easy-to-use configuration switch to enable or disable specific parts of the SELinux policy
- `semanage boolean -l` or `getsebool -a`
- `setsebool -P boolean [on|off]` to set booleans
- `semanage bolean -l -C` to see all booleans that have a non-default setting

## 26.8 Analyzing SELinux Log Messages
### Using `sealert`
- SELinux records denials in the audit log (**auditd**), but those raw messages can be cryptic
- The `sealert` tool parses the audit log, applies its built-in analysis, and gives you human-readable advice
- Make sure you have the `setroubleshoot-server` (or similar) package installed so that sealert is available
- To analyze a specific denial, copy its UUID from `/var/log/audit/audit.log` (or `/var/log/messages`) and run `sealert -a /var/log/audit/audit/log` or `sealert l <the-UUID>`
- `sealert will then suggest which contexts to adjust or which Booleans to toggle so the denied operation can succeed`

## 26.9 Troubleshooting SELinux
1. Confirm SELinux is the culprit. If the problem goes away, you know SELinux was blocking it
```bash
setenforce 0
```

2. Find raw denial messages. Look for lines showing the "source" context, "target" context, and the denied action
```bash
grep AVC /var/log/audit/audit.log
```

3. Get human-readable advice
- Install the policy docs:
```bash
dnf install selinux-policy-doc
```
- Run the troubleshooter on your audit log:
```bash
sealert -a /var/log/audit/audit.log
```

- or to inspect a single event:
```bash
sealert -l <AVC-UUID>
```

4. See what sealert suggested
```bash
journalctl | grep sealert
```

5. Re-enable enforcement once fixed:
```bash
setenforce 1
```

## Lesson 26 Lab: Managing SELinux
- Configure the Apache web server to bind to port 82
- Use `mv /etc/hosts /var/www/html/` and ensure that the file gets an SELinux context that makes it readable by the Apache web server