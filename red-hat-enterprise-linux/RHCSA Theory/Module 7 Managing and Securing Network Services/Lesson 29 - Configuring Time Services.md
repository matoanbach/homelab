# Lesson 29: Configuring Time Services
- 29.1 Explorig Linux Tine
- 29.2 Setting Time with **timedatectl**
- 29.3 Managing an NTP Client

## 29.1 Explorig Linux Tine
### Exploring Linux Time
- While booting, the system gets its time from the hardware clock
- System time is set next, according to the hardware clock
- Internet time can be used to synchronize time

### Managing Linux Time
- `hwclock` is used to set hardware time
- Also use it to synchronize time
    - `hwclock --systohc`
    - `hwclock --hctosys`
- `date` is used to show and set time
- `timedatectl` is used to manage time and time zone configuration

## 29.2 Setting Time with timedatectl
### Using `timedatectl`
- `timedatectl status` to view current settings. It shows your system clock, local time vs. UTC, time zone, and NTP sync status
- `timedatectl set-time '2025-06-08 18:30:00'` to set the clock manually
- `timedatectl set-timezone America/New_York` to change the time zone
- To enable or disable automatic NTP sync, do:
```bash
# Turn on NTP (chronyd is used under the hood)
timedatectl set-ntp true

# Turn it off
timedatectl set-ntp false
```

- **Note**: Under RHEL 9, **chronyd** handles the actual NTP protocol; timedatectl simply flips its on/off switch and displays status for you

## 29.3 Managing an NTP Client
### Managing an NTP Client
1. **Service & Config File**
- RHEL 9 uses **chronyd** for NTP
- Its main config is `/etc/chrony.conf`

2. **Defining Time Sources**
- `pool 2.rhel.pool.ntp.org ibust` To point at a pool of public servers
- `server myserver.example.com ibust` to use a single, private server
- The iburst option makes the initial synchronization happen quickly on startup

3. **Apply Changes**
```bash
systemctl restart chronyd
```

4. **Verify Sync Status**
```bash
chronyc sources
```

## Lesson 29 Lab: Configuring Time Services
- Configure your system to synchronize time with the servers in pool.ntp.org