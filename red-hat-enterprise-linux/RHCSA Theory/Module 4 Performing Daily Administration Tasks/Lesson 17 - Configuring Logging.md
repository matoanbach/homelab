# Lesson 17: Configuring Logging
- 17.1 Exploring RHEL Logging Options
- 17.2 Using `systemd-journald`
- 17.3 Preserving the Systemd Journal
- 17.4 Configuring `rsyslogd`
- 17.5 Using `logrotate`

## 17.1 Exploring RHEL Logging Options
- `systemd-journald` is receiving log messages from different locations
    - The kernel
    - Early boot procedure
    - Syslog events
    - Standard output and error from daemons
- The systemd journal is non-persistent by default
- The `rsyslog` service reads syslog messages and writes them to different locations
    - Files in `/var/log`
    - According to output modules
- Service may also write to /var/log

## 17.2 Using systemd-journald
### Viewing Systemd Journal Messages
- `systemd status name.unit` provides easy access the last messages that have been logged for a specific service
- `journalctl` prints the entire journal. Important messages are red in color
- `journalctl -p err` shows only messages with a priority error and higher
- `journalctl -f` shows the last 10 lines, and adds new messages while they are added
- `journalctl -u sshd.service` shows messages for sshd.service only
- `journalctl --since "-1 hour"; journalctl --since today` allows time specification
- `journalctl -o verbose` adds verbose messages

### Viewing Boot Logs
- `journalctl -b` shows the current boot log
- `journalctl -xb` adds explanation texts to the boot log messages
- `journalctl --list-boots` shows all boots that have been logged (on persistent journal only)
- `journalctl -b 3` shows messages from the third boot log only

## 17.3 Preserving the Systemd Journal
### The Need for Persistency
- The systemd journal is non-persistent
- Persistency is taken care of by the rsyslog service
- Rsyslog offers all the filtering you need to fine-tune log persistency

### Making the Journal Persistent
- Systemd journal settings are in /etc/systemd/journal.conf
- The setting `Storage=auto` ensures that persistent storage is happening automatically after creating the directory /var/log/journal
- Other options are:
    - `persistent`: stores journals in /var/log/journal
    - `volatile`: stores journals in the temporary /run/log/journal directory
    - `none`: doesn't use any storage for the journal at all

### Managing Persistent Journal Size
- In journal.conf, default settings apply to ensure that the journal can't grow in an unlimited way
    - Log rotation triggers monthly
    - No more than 10% of the file system size can be used
    - No more than 15% of the file system free size can be used
- Use `journalctl | grep -E 'Runtime Journal | System Journal'` to check current settings

### Demo: Making the Journal Persistent
- `grep 'Storage=' /etc/systemd/journald.conf`
- `mkdir /var/log/journal`
- `systemctl restart systemd-journald`
- `ls /var/log/journal`

## 17.4 Configuring Rsyslog
### Understanding Rsyslog
- Rsyslog needs the `rsyslogd` service to be running
- The main configuration file is /etc/rsyslog.conf
- Snap-in files can be placed in /etc/rsyslog.d
- Each logger line contains three items
    - `facility`: the specific facility that the log is created for
    - `severity`: the severity from which should be logged
    - `destination`: the file or other destination the log should be written to
- Log files normally are in /var/log
- Use the `logger` command to write messages to rsyslog

### Understanding Facilities
- `rsyslog` is and must be backwards compatible with the ancient syslog service
- In syslog, a fixed number of facilities was defined, like kern, authpriv, cron and more
- To work with services that don't have their own facility local{..} can be used
- Because of the lack of facilities, some services take care of their own logging and don't use rsyslog

## 17.5 Using logrotate
- The `logrotate` command is started by a systemd timer to prevent them from growing too big
- After rotation, the file is renamed to a file with the rotation date as extension
- When too many files are rotated, according to the settings, the oldest file will be discarded
- Log rotation configured in files /etc/logrotate.conf and /etc/logrotate.d

## Lesson 17 Lab: Configure Logging
- Make sure the systemd journal is logged persistently
- Create an entry in rsyslog that writes all messages with a severity of error or higher to /var/log/error
- Ensure that /var/log/error is rotated on a monthly basis, and the last 12 logs are kept before they are rotated out