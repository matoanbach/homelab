# Lesson 11: Managin Network COnfiguration
- 11.1 Understanding IPv4 Networking
- 11.2 Exploring IPv6 Networking
- 11.3 Understanding NIC Naming
- 11.4 Defining Host Names and Host Name Resolution
- 11.5 Analyzing Network Configuration
- 11.6 Understanding NetworkManager
- 11.7 Managing Persistent Network Configuration with `nmcli`
- 11.8 Managing Persistent Network Configuration with `nmtui`

## IPv4 Networking
- In IPv4, each node needs its own IP address, written in dotted decimal notation (192.168.4.200/24)
- Each IP address must be indicated with the subnet mask behind it
- The default router or gateway specifies which server to forward packets to that have an external destination
- The DNS nameserver is the IP address of a server that helps to resolve names to IP addresses and the other way around
- IPv4 is still the most common IP version, but IPv6 addresses can be used as well
- IPv6 addresses are written in hexadecimal notation 
(fd01::8eba:210)
- IPv4 and IPv6 can co-exist on the same network interface

## IPv6 Networking
- IPv6 was introduced in the 1990's to overcome the shortage of world-wide unique IPv4 addresses
- IPv6 is used extensively by Internet Service Providers to address the core internet infrastructure
- End-users and companies mostly use IPv4 behind a NAT router
- Red Hat Enterprise Linux offers dual stack IPv4 and IPv6

### IPv6 Addresses
- IPv6 addresses are 128-bit numbers, which are normally expressed as 8 colon-separated groups of four hexadecimal numbers
- In these numbers, leading zero's are omitted
    - `2001:db:7891:123:1010:6bbd:cbcb:210`
- Long strings of zeros can be replaced by one block of two colon characters
    - `::210`
- When combining an IPv6 address with a port number, enclose the IPv6 address in square brackets

### IPv6 Subnets
- IPv6 addresses have a standard subnet of 64 bits
- Typically, network providers hand out a /48 prefixed address, which leaves 16 bits to the customer to address subnets

### IPv6 Address Types

| Purpose       | Example     | Description                                     |
|---------------|-------------|-------------------------------------------------|
| localhost     | ::1/128     | Localhost address, used on loopback interface   |
| unspecified   | ::          | Used to refer to all IP addresses               |
| default route | ::/0        | Used in default router specification            |
| global unicast| 2000::/3    | IPv6 addresses currently being allocated        |
| unique local  | fd00::/8    | Addresses for internal use like 192.168.0.0     |
| link local    | fe80::/10   | Non-routable auto assigned for internal use     |
| multicast     | ff00::/8    | Multicast addresses                             |

### IPv6 Address Assignment
- Apart from manual allocation and DHCP, IPv6 supports Stateless Address Autoconfiguration (SLAAC)
- In SLAAC, a host sends a router solicitation to the ff02::2 multicast group to access all routers
- A router answers that request, sending all relevant information
- The host adds an automatically geenerated host ID to the network prefix to obtain a unique address in this way
- To enable RHEL 9 for SLAAC support, install the `radvd` package

## 11.3 Understanding NIC Naming
- IP address configuration needs to be connected to a specific network device
- Use `ip link show` to see current devices, and `ip addr show` to check their configuration
- Every system has an `lo` device, which is for internal networking
- Apart from that, you'll see the name of the real network device, which is presented as BIOS name

### BIOS Device Names
- Classical naming is using device names like eth0, eth1, and so on
    - These device names don't reveal any information about physical device location
- BIOS naming is based on hardware properties to give me specific information in the device name
    - em[1-N] for embedded NICs
    - eno[nn] for embedded NICs
    - p<slot>p<port> for NICs on the PCI bus
- If the device doesn't reveal network device properties, classic naming is used

## 11.4 Defining Host Names and Host Name Resolution
### Host Name Resolution
- `hostnamectl set-hostname` is used to manage hostnames
- The hostname is written to /etc/hostname
- To resolve hostnames /etc/hosts is used
    - `10.0.0.11 server2.example.com server2`
- /etc/resolv.conf contains DNS client configuration
- The order of host name resolution is determined through /etc/nsswitch.conf

## 11.5 Analyzing Network Configuration
- `ip` is the modern tool for all IP-layer tasks (supersedes `ifconfig`/`ipconfig`).
- Address:
    - `ip addr show` to list addresses 
    - `ip addr add 10.0.0.10/24 dev ens3p3` to add an IPv4 address
- Links:
    - `ip link show` to show interface status
    - `ip -s link show` to show interface status with counters/statistics
- Routes:
    - `ip route show` to view the routing table
    - `ip route add default via 10.0.0.1` to set the default gateway

## 11.6 understanding NetworkManager
- NetworkManager is the systemd service that manages network configuration
- Configuration is stored in files in /etc/NetworkManager/system-connections
    - Legacy files in /etc/sysconfig/network-scripts are still supported but deprecated
- Different applications are available to interface with NetworkManager
    - `nmcli` is a powerful command line utility
        - `nmcli general`
    - `nmtui` offers a convenient text user interface
    - GNOME offers graphical tools also

### Connections and Devices
- In NetworkManager, devices are network interfaces
- Connections are collections of configuration settings for a device, stored in the configuration file in /etc/NetworkManager/system-connections
- Only one connection can be active for a device

### NetworkManager Permissions
- Permissions to modify settings in NetworkManager are applied through `dbus`
- Non-privileged users that are logged in on the console can change network settings
- Non-privileged users that are logged in through `ssh` cannot
- Use `nmcli general permissions` for an overview of current permissions that apply
- `systemctl status NetworkManager` to show the network manager

## 11.7 Managing Persisten Network Configuration with nmcli
- `nmcli` has awesome tab completion
- `nmcli con show` shows current connections
- `nmcli dev status` shows current network devices
- `nmcli con add con-name mynewconnection ifname ens33 ipv4.addresses 10.0.0.10/24 ipv4.gateway 10.0.0.1 ipv4.method manual type ethernet` will add a new connection
- `nmcli con up mynewconnection`

### `nmcli con`
- `nmcli con show mynewconnection` shows all connection settings
- `nmcli con mod` will modify connection settings: use tab completion!
- `nmcli con reload` will reload the modified connection

### `ipv4.mothod`
- use `ipv4.method manual` on connections that don't use DHCP
- without this setting, a DHCP server will be contacted, even if static configuration has been set

## 11.8 Managing Persisten Configuration with nmtui
## 11.9 Troubleshooting Networking
### Verify Connectivity
- Use `ping` to verify connectivity
    - `ping -c 4 myserver` sends 4 packets and then stops
    - `ping6 2001::210` uses ping6
- When using `ping6` on link-local addresses, you must include the NIC name in the command
    - `ping6 ff02::1%ens33`

### Troubleshooting Routing
- `ip route` prints the routing table
- `ip -6 route` shows the IPv6 routing table
- `tracepath example.com` shows the entire networking path
- `tracepath6 example.com` does the same for an IPv6 (if existing)
- `ss` is used to analyze socket statistics
    - `ss -tu` - show TCP and UPD connection (basic info)
    - `ss -tuna` - show all TCP and UDP sockets with IPs and ports
    - `ss -tunap` - show everything above + which program opened the connection

## Lesson 11 Lab: Managing Network Configuration
- Set the hostname for your server to rhcsaserver.example.com

```bash
rhcsaserver.example.com
```
- Set your server to a fixed IP address that matches your current network configuration
- Also get a second IP address 10.0.0.10/24 on the same network interface
- Enable host name resolution for your local server hostname
- Reboot and verify your network is still working with the new settings