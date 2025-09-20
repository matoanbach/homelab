# Lesson 14: Managing Processes
- 14.1 Using Signals to Manage Process State
- 14.2 Managing Process Priority
- 14.3 Using `tuned` Profiles
- 14.4 Managing User Sessions and Processes

# 14.1 Using Signals to Manage Process State
- A signal allows the operating system to interrupt a process from software and ask it to do something
- Interrupts are comparable to signals, but are generated from hardware
- A limited amount of signals can be used and is documented in `man 7 signals`
- Not all signals work in all cases
- The `kill` command is used to send signals to PID's
- You can also use `k` from top
- Different kill-like commands exist, like `pkill` and `killall`

### Demo: Killing a Zombie
- Run a `zombie` process
- Use `ps aux | grep zombie` and note the PID of the child as well as the parent
- Use `kill <childpid>`; it will fail
- Use `kill -SIGCHLD <parentpid>`; it will be ignored
- Use `kill <parentpid>`; the Zombie will get adopted and init will reap it after a few seconds

## 14.2 Managing Process Priority

### Understanding Priority Management
- Linux Cgroups provide a framework to apply resource restrictions to Linux systems
- Cgroups can limit the amount of CPU cycles, available memory, and more
- If processes are equal from a perspective of Cgroups, the Linux `nice` and `renice` commands can be used to manage priority 

### Understanding Cgroups
- **Cgroups organize processes into three groups (slices):**
  1. **System slice:** contains all systemd services and daemons.
  2. **User slice:** contains applications and processes started by regular users.
  3. **Machine slice:** contains virtual machines and containers.

- **Each slice is treated equally when sharing the CPU.**
  - If one slice’s processes try to use 100% of the CPU, the kernel still gives each slice the same share.
  - For example, even if there are 20 systemd services all wanting CPU time, they together only get as much CPU as a single user process that is using all of its share.

- **You can adjust a slice’s priority in systemd using `CPUWeight`.**
  - This setting lets you give more or fewer CPU “shares” to any systemd service (unit) within a slice.
 
### Managing `nice` and `renice`

- What they do:
    -  If you aren't using Cgroups to control CPU time, you can use `nice` and `renice` to set how much CPU time a process should get
- When to use them:
    - Use `nice` when you start a process to give it a lower or higher priority
    - A **positive** nice value makes a process get more CPU time
    - A **negativer** nice value makes a process get less CPI time
- When can do what:
    - Any user can set a process to run a **lower priority** 
    - To give a process **lower priority**, you need **root** privileges
- Example

```bash
nice -n 19 dd if=/dev/zero of=/dev/null
```


## 14.3 Using tuned Profiles
### Understanding System Tuning
- The Linux kernel exposes tunable settings under the special /proc/sys directory
- Each file inside /proc/sys holds the current value for one kernel parameter
- If you want to see the current setting, you can read the file. For example:
```bash
cat /proc/sys/vm/swappiness
```
- To change a setting immediately (only until the next reboot), you write a new value into the same file. For example:
```bash
echo 40 >/proc/sys/vm/swappiness
```

- Because these changes disappear after a restart, you make them permanent by creating a configuration fileunder /etc/sysctl.d/. For instance, you can put this line into /etc/sysctl.d/swappiness.conf:

```bash
vm.swappiness = 40
```
- After that, whenever the system boots (or run `sysctl --system`), the kernel automatically applies vm.swappiness = 40.

### Understanding `tuned`
- What is tuned:
    - A systemd service that makes it easy to apply a set of performance or power-saving settings all at once
- How does it work:
    - tuned uses "profiles", each of which contains a tuned.conf file with various tuning parameters (CPU governor, disk I/O, power management, etc.).
- See available profiles:
    - Run below to show which profiles are installed and which one is currently active
```bash
tuned-adm list
```
- See available properties such as swappiness:
```bash
tuned-adm -a | grep swappiness
```
- Switching profiles:
    - To change to a different profile (for example, "virtual-guest"), run:

```bash
tuned-adm profile virtual-guest
```

- Dealing with sysctl conflicts:
    - If you set a kernel parameter manually with sysctl and a tuned profile tries to override, you can force tuned to respect your manual setting by putting this line into `/etc/tuned/tuned-main.conf`:

```yml
reapply_sysctl = 1
```

### Creating Custom tuned Profiles
- Where to put your custom profile: Create a new folder under `/etc/tuned` with your profile's name
- What to put inside: Inside that folder, place a file named `tuned.conf` containing the specific performance or power settings you want
- How it gets used: Once you've create the directory and added `tuned.conf`, tuned will automatically detect and list your custom profile. You can then activate it with `tuned-adm profile <your-profile-name>`

### Demo: using `tuned`
```bash
sudo dnf install -y tuned
systemctl enable --now tuned
echo vm.swappiness = 33 > /etc/sysctl.d/swappiness.conf
sysctl -p /etc/sysctl.d/swappiness.conf
sysctl -a | grep swappiness
mkdir /etc/tuned/myprofile
cat >> /etc/tuned/myprofile/tuned.conf << EOF
> [sysctl]
> vm.swappiness = 66
> EOF

tuned-adm profile myprofile
tuned-adm profile
sysctl -a | grep swappiness
cat /etc/tuned/tuned-main.conf

# remember to change reapply_sysctl to 0 in /etc/tuned/tuned_main.conf
```

## 14.4 Managing User Sessions and Processes

### Common Utilities

- `ps -u username` to show processes owned by a specific user
- `pkill -u username` to remove processes owned by a specific user

### Using loginctl
- What is loginctl:
    - A tool in the systemd suite that keeps track of users and their active sessions
- Why it matters
    - A single user can have multiple logic sessions (for example, one via SSH and another one the local console)
- Key commands:
    - `loginctl list-users` - Lists all users who currently have at least one session open
    - `loginctl list-sessions`- Shows every active sessions
    - `loginctl user-status <UID>` - Displays a tree of all processes running uder the specified user's ID
    - `loginctl terminate-session <SESSION_ID>` - Ends a specific session
    - `loginctl terminate-user <UID>` - Kills every session and process for the specified user
- Used when needed to see who is logged in, monitor their processes, or forcible log out a session or user
ll
## Lesson 14 Lab: Managing Processes
- Create a user linda and open a shell as this user
- As linda, run two background processes `sleep 600`, one of them with the highest possible priority, the other with the lowest possible priority
- Use the most efficient way to terminate all current sessions for user linda