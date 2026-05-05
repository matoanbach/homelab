# Lesson 15: Working with Systemd
- 15.1 Exploring Systemd Units
- 15.2 Managing Systemd Services
- 15.3 Modifying Systemd Service Configuration
- 15.4 Managing Unit Dependencies
- 15.5 Masking Services

## 15.1 Understanding Systemd Units
- what is systemd
    - it's the very first program the Linux kernel runs when the system boots, and it oversees everything else on the system.
- What does it do
    - It starts and controls services-like SSH or a web server along with many other system tasks
- What are units
    - Any service or task that systemd starts or manages is called a "unit". This includes:
        - Services (e.g., sshd.service, httpd.service)
        - Mount points (e.g., home directories)
        - Sockets (network endpoints)
        - Timers (secheduled jobs)
        - And many more
- How do you manage these units
    - you use the `systemctl` command. For example:
        - `systemctl start sshd` starts the SSH service
        - `systemctl stop httpd` stops the web server

- How to see all types of units available?
    - run" `systemctl -t help`
    - run: `systemctl list-units -t <type of units>` 
    - run: `systemctl list-unit-files`

### Understanding systemd Unit Types
- Service units: Start and manage background processes or daemons (e.g., web server, SSH)
- Socket units: Watch for network activity on a specific port and automatically launch the related service when a connect arrives
- Timer units: Schedule services to run at regular intervals, much like a cron job
- Path units: Monitor a directory or file; when a change happens (e.g., a file is created), they trigger a service to run
- Mount units: Handle the automatic mounting of filesystems (e.g., mounting a drive at boot)
- Other unit types: swap, device, target

## 15.2 Managing Systemd Services
### Systemd Unit Management Tasks
- `systemctl status` shows the current status of any unit
- `systemctl start` will start a unit that is not currentlt active
- `systemctl stop` will stop the unit
- `systemctl enable [--now]` is used to flag the unit for automatic starting upon system start
- `systemctl disable [--now]` is used to flat the unit to be no longer automatically started
- `systemctl reload` will reload the unit configuration without restarting the unit
- `systemctl restart` will restart the unit after which the process it manages gets a new PID

## 15.3 Modifying Systemd Unit Configuration
- Default system-provided system unit files are in `/usr/lib/systemd/system`
- Custom unit files are in `/etc/systemd/system`
- Run-time automatically-generated unit files are in `/run/systemd`
- While modifying a unit file, do NOT edit the file in `/usr/lib/systemd/system` but create a custom file in `/etc/systemd/system` that is used as an overlay file
- Better: use `systemctl edit unit.service` to edit unit files
- Use `systemctl show` to show available parameters
- Using `systemctl reload` may be required

## 15.4 Managing Unit Dependencies
- Systemd units normally depend on other units
- Use `systemctl list-dependencies` for a complete overview of all currently loaded units and their dependencies
- Use `systemctl list-dependencies <UNIT>` to see dependencies for any unit

## 15.5 Masking Services
- Some units cannot work simultaneously on the same system
- To prevent administrators from accidentally starting these units, use `systemctl mask`
- `systemctl mask <UNIT>` links a unit to the /dev/null device, which ensures that it cannot be started
- `systemctl unmask <UNIT>` removes the unit mask

## Lesson 15 Lab: Working with systemd
- Make sure the httpd service is automatically started
```bash
systemctl enable --now httpd
```
- Edit its configuration such that on failure, it will continue after 1 minute
```bash
systemctl edit httpd.service
```