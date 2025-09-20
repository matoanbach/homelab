# Lesson 16: Task Scheduling
- 16.1 Exploring RHEL Scheduling Options
- 16.2 Scheduling Tasks with Systemd Timers
- 16.3 Scheduling Tasks with `cron`
- 16.4 Understanding `anacron`
- 16.5 Using `at`
- 16.6 Managing Temporary Files

## 16.1 Exploring RHEL Scheduling Options
- `systemd` timers are the primary solution for scheduling recurring jobs on RHEL 9
- `crond` is an older scheduling solution which is still supported and a bit easier to schedule custom tasks
- `at` is available to schedule non-recurring user tasks

## 16.2 Scheduling Tasks with Systemd Timers

### Understanding systemd Timers
- systemd provides `unit.timer` files that go together with `unit.service` files to schedule the service file
- when using `systemd` timers, the timer should be enabled / started, and NOT the service unit
- `systemd` timers are often installed from RPM packages
- In the timer unit file, the `OnCalendar` option specifies when the service should be started

### Demo: analyzing systemd timers
```bash
systemctl list-units -t timer
systemctl list-unit-files logrotate.*
systemctl status logrotate.service
systemctl status logrotate.timer
dnf install -y sysstat
systemctl list-unit-files sysstat*
systemctl cat sysstat-collect.timer
```
### Understanding Timer Activation
- The `systemd` timer `OnCalendar` option uses a right language to express when the timer should activate
    - `OnCalendar=*:00/10` runs every 10 minutes
    - `OnCalendar=2023-*-*9:9,19,29:30` runs the service every day in 2023 at 9:09:30, 9:09:30, 9:19:30 and 9:29:30
- Use `OnUnitActivateSec` to start the unit a specified time after the unit was lasat activated
- Use `OnBootSec` or `OnStartupSec` to start the unit a specific time after booting
- Read `man 7 systemd-time` for specification of the time format to be used

### Demo: Managing systemd Timers
- `cat >> /etc/systemd/system/touchfile.service << EOF`
```yaml
[Unit]
Description=demo unit

[Service]
Type=oneshot
ExecStart=/usr/bin/touch /tmp/myfile.text
EOF
```
- `cat >> /etc/systemd/system/touchfile.timer << EOF`
```yaml
[Unit]
Description=demo timer

[Timer]
OnCalendar=*:00/01
EOF
```

```bash
systemctl daemon-reload
systemctl start touchfile.timer
systemctl status touchfile.service
watch ls -l /tmp/myfile.txt
systemctl stop touchfile.timer
```

## 16.3 Scheduling Tasks with cron

### Understanding cron
- `cron` is an old UNIX scheduling option
- It uses `crond`, a daemon that checks its configuration to run cron jobs periodically
- Still on RHEL 9, `crond` is enabled as a systemd service by default
- Most services that need scheduling are scheduled through `systemd` timers


### Using `cron`
- The `cron` service checks its configuration every minute
- `/etc/crontab` is the main (managed) configuration file
- `/etc/cron.d` is used for drop-in files
- `/etc/cron.{hourly,daily,weekly,monthly}` is used as a drop-in for scripts that need to be scheduled on a regular basis
    - make sure these scripts have the execute bit set
- User specific cron jobs can be created using `crontab -e`

### Understanding Cron Time Specification
- Cron time specifications are specified as minute, hour, day of month, month, day of week
- `0 * * dec 1-5` will run a cron job every monday through friday on minute zero in December
- The /etc/crobtab file has a nice syntax example
- Do NOT edit /etc/crontab, put drop-in files in `/etc/cron.d` instead

## 16.4 Understanding `anacron`
- `anacron` is a service behind `cron` that ensures that jobs are executed on a regular basic, but not at a specific time
- It takes care of the jobs in `/etc/cron.{hourly,daily,weekly,monthly}`
- Configuration is in `/etc/anacrontab`
- Don't change anything in `/etc/anacrontab`, use `systemd` timers instead

## 16.5 Using `at`
- The `atd` service must be running to run once-only jobs using at
- Use `at <time>` to schedule a job
    - Type one or more job specifications in the at interactive shell
    - Use Ctrl-D to close this shell
- Use `atq` for a list of jobs currently scheduled
- Use `atrm` to remove jobs from the list

## 16.6 Managing Temporary Files
### Understanding Temporary Files
- In the past, temporary files were created in the /tmp directory
- Without management, these file could stay around for a long time
- As a solution, the /tmp directory could be created on a RAM drive
- Nowadays, systemd-tmpfiles is started while booting, and manages temporary files and directories
- It will create and delete tmp files automatically, according to the configuration files tine the following locations:
    - `/usr/lib/tmpfiles.d`
    - `/etc/tmpfiles.d`
    - `/run/tmpfiles.d`

### Understanding systemd-tmpfiles
- `systemd-tmpfiles` works with related services to manage temporary files
- `systemd-tmpfiles-setup.service` creates and removes temporary files according to the configuration
- `systemd-tmpfiles-clean.timer` calls the `systemd-tmpfiles-clean.service` to remove temporary files
    - By default 15 minutes after booting
    - And also on a daily basic

### Managing Temporary Files
- In the configuration files, specify what to do with temporary files
    - `d /run/myfiles 0750 root root` - will create the directory `/run/myfiles` if necessary. No action if it already exists
    - `D /run/myfiles 0750 root root 1d` - will create the directory if necessary, and wipe its contents if it already exists. Files older than 1 day are eligible for automatic removal
- `man tmpfiles.d` provides detailed information and examples

### Demo: Managing Temporary Files
- `echo "q /tmp 1777 root root 7d" > /etc/tmpfiles.d/tmp.conf` will create a configuration that creates the /tmp directory and removes all unused files after 7 days
- `systemd-tmpfiles --clean /etc/tmpfiles.d/tmp.conf` check syntax
- `echo "d /tmp/myfiles 0770 root root 30s" > /etc/tmpfiles.d/myfiles.conf`
- `ls -ld /tmp/myfiles`
- `systemd-tmpfiles --create /etc/tmpfiles.d/myfiles.conf`
- `ls -ld /tmp/myfiles`
- `touch /tmp/myfiles/test`
- `ls -ld /tmp/myfiles/test`
- `sleep 30`
- `ls -ld /tmp/myfiles/test`
- `systemd-tmpfiles --clean /etc/tmpfiles.d/myfiles.conf`

## Lesson 16 Lab: Running Scheduled Jobs
- Ensure the systemd timer that cleans up tmp files is enabled
- Run a cron job that will issue the command `touch /tmp/cronfile` 5 minutes from now
- Use `at` to schedule a job to power off your system at a convenient time later today
