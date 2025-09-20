# Lesson 27: Applying Network Security
- 27.1 Analyzing Service Configuration with `ss`
- 27.2 Managing RHEL Firewalling
- 27.3 Exploring Firewalld Components
- 27.4 Configuring a Firewall with `firewall-cmd`

## 27.1 Analyzing Service Configuration with `ss`
### Monitoring Network Sockets with `ss`
- A **socket** is just an IP address + port (or a UNIX-domain endpoint) that programs use to communicate
- `ss` is the go-to tool to list those sockets on Linux
- Common **ss flags**:
    - `ss` will show all connections
    - `ss -t` to show only **TCP** sockets
    - `ss -u` to show only **UDP** socketsu 
    - `ss -tu` to show both TCP and UDP (connected) sockets
    - `ss -a` to include all sockets - both connected and listening
    - `ss -tuna` to show TCP + UDP, all states (connected + listening), no anme resolution
    - `ss -l` to show only **listening** sockets (servers waiting for connections)
    - `ss -ln` to show listening sockets, numeric ports/IPs (skip DNS)
    - `ss -lp` to show listening sockets and the onwing process/PID
    - `ss -tulpn` to show "who is listening where" view: TCP,UDP, listening only, show PID/program, numeric

## 27.2 Managing RHEL Firewalling
### Understanding RHEL Firewalling
- This `linux kernel` includes netfilter, which does the heavy lifting for:
    - Packet filtering (allowing or blocking traffic)
    - Network Address Translation (NAT)
    - Port forwarding
- `nftables` is the modern in-kernel framework where you write those firewall rules (it replaces the older iptables)
- `firewalld` is the user-friendly daemon (managed by systemd) on RHEL that dynamically applies and manages your nftables rules.
    - You talk to `firewalld` (via the firewall-cmd CLI or GUI), and it keeps the underlying nftables configuration up to date

## 27.3 Exploring Firewalld Components
1. **Service**
- A named bundle of ports (and optional helper modules) that you can allow or deny as one unit
- e.g. the "http" service opens port 80/tcp and loads any needed NAT helper
2. **Zone**
- A preset policy applied to one or more network interfaces
- Each zone (like `public`, `internal`, `trusted`) has its own set of allowed services, ports, and rules
- You assign interfaces to zones so devices on those networks follow the right firewall profile
3. **Port**
- An individual TCP or UDP port you can open or close
- Use this when you need a custom port that isn't covered by a built-in service

- commands:
```bash
firewall-cmd --list-all
```

## 27.4 Configuring a Firewall with firewall-cmd
### Using `firewall-cmd`
- `firewall-cmd` is the main CLI for talking to firewalld
- By default, any command you run without `--permanent` only affects the `runtime` configuration (it takes effect immediately but is lost on reload or reboot)
- Adding `--permanent` writes the change to the `persistent` config files under `/etc/firewalld` (so it survives restarts), but you still need to run: `firewall-cmd --reload`

### Demo: Allowing Incolimg HTTP traffic
```bash
systemctl status firewalld
firewall-cmd --list-all
firewall-cmd --get-services
firewall-cmd --add-service http
firewall-cmd --add-service http --permanent
```