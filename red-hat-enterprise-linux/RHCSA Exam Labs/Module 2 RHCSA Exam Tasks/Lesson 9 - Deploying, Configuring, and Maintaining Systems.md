## 9.1 Scheduling tasks
### Task
- Create a scheduleed task that runs as user `linda` on weekdays at 2:00 AM. The task should write `greetings from linda` to the actual system logging service.
- Solution
```bash
vim /etc/crontab # copy the sample crontab syntax
crontab -u linda -l 
# write the below to the editor
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
0 2 * * 1-5 linda logger "greetings from linda"
```

### Key Elements
- Currently, the crond service as well ass systemd timers can be used to create scheduled tasks.
- Although it's possible to create a systemd timer that runs as a specific user using systemd user timers, to run a task as a specific user it's recommended to create a cron job.
- To write messages to the standard systemd logging service, the `logger` command can be used.

## 9.2 Configuring time services
### Task
- Configure your server to fetch time from pool.ntp.org.
- Set the timezoen on your server to Africa/Lusaka.
- Solution:

```bash
vim /etc/chrony.conf
# edit the first line to:
pool pool.ntp.org ibust
timedatectl set-timezone Africa/Lusaka
systemctl restart chronyd
```
### Key Elements
- While booting, Linux obtains its time from the hardware clock, and sets the system clock accordingly.
- To ensure continued time synchronization, Internet time is fetched using the `chronyd` service.
- Don't configure `systemctl-timesyncd` or `ntpd`, both are not supported on Red Hat Enterprise Linux.
