# lab 4

<img src="https://github.com/matoanbach/networking/blob/main/pics/lab4.1.png"/>

## Part 1 – Addressing (no commands)

We’re using:

- Subnet A (VLAN 100, R1) – 58 hosts → /26
  - Network: 192.168.1.0/26
  - R1 G0/0/1.100: 192.168.1.1/26

- Subnet B (VLAN 200, R1 management) – 28 hosts → /27
  - Network: 192.168.1.64/27
  - R1 G0/0/1.200: 192.168.1.65/27
  - S1 VLAN 200 SVI: 192.168.1.66/27

- Subnet C (clients at R2/S2) – 12 hosts → /28
  - Network: 192.168.1.96/28
  - R2 G0/0/1: 192.168.1.97/28
  - S2 VLAN 1 SVI: 192.168.1.98/28

- R1–R2 link: 10.0.0.0/30
  - R1 G0/0/0: 10.0.0.1/30
  - R2 G0/0/0: 10.0.0.2/30

---

## Part 2 – Basic settings on routers

### R1 – Step 2
```bash
enable
configure terminal
 hostname R1
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
 exit

 line vty 0 4
  password cisco
  login
 exit

 service password-encryption
 banner motd #Unauthorized access is prohibited#
end
copy running-config startup-config
```

## R2 – Step 2
```bash
enable
configure terminal
 hostname R2
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
 exit

 line vty 0 4
  password cisco
  login
 exit

 service password-encryption
 banner motd #Unauthorized access is prohibited#
end
copy running-config startup-config
```

## Part 3 – Basic settings on switches

### S1 – Step 3
```bash
enable
configure terminal
 hostname S1
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
 exit

 line vty 0 4
  password cisco
  login
 exit

 service password-encryption
 banner motd #Unauthorized access is prohibited#
end
copy running-config startup-config
```
## S2 – Step 3

```bash
enable
configure terminal
 hostname S2
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
 exit

 line vty 0 4
  password cisco
  login
 exit

 service password-encryption
 banner motd #Unauthorized access is prohibited#
end
copy running-config startup-config
```

## Part 4 – Interfaces, VLANs, SVIs, trunks

### 4.1 – R1 interfaces (router-on-a-stick + R2 link)
```bash
configure terminal
 ! Link to R2
 interface gigabitEthernet0/0/0
  ip address 10.0.0.1 255.255.255.252
  no shutdown
 exit

 ! Physical toward S1
 interface gigabitEthernet0/0/1
  no shutdown
 exit

 ! VLAN 100 – Subnet A clients
 interface gigabitEthernet0/0/1.100
  encapsulation dot1Q 100
  description VLAN 100 Clients
  ip address 192.168.1.1 255.255.255.192
 exit

 ! VLAN 200 – management
 interface gigabitEthernet0/0/1.200
  encapsulation dot1Q 200
  description VLAN 200 Management
  ip address 192.168.1.65 255.255.255.224
 exit

 ! VLAN 1000 – native, no IP
 interface gigabitEthernet0/0/1.1000
  encapsulation dot1Q 1000 native
  description Native VLAN
  no ip address
 exit
end
```
### 4.2 – R2 interfaces (R1 link + Subnet C)
```bash
configure terminal
 interface gigabitEthernet0/0/0
  ip address 10.0.0.2 255.255.255.252
  no shutdown
 exit

 interface gigabitEthernet0/0/1
  ip address 192.168.1.97 255.255.255.240
  no shutdown
 exit
end
```

### 4.3 – S1 VLANs, SVI, access, parking lot, trunks

```bash
configure terminal
 ! VLANs
 vlan 100
  name Clients
 vlan 200
  name Management
 vlan 999
  name ParkingLot
 vlan 1000
  name Native
 exit

 ! Management SVI for S1
 interface vlan 200
  ip address 192.168.1.66 255.255.255.224
  no shutdown
 exit
 ip default-gateway 192.168.1.65

 ! PC-A access port (example: F0/6)
 interface fastEthernet0/6
  switchport mode access
  switchport access vlan 100
 exit

 ! Parking-lot all unused ports
 interface range fastEthernet0/2 - 4 , fastEthernet0/7 - 24 , gigabitEthernet0/1 - 2
  switchport mode access
  switchport access vlan 999
 exit

 ! Trunk to S2 (F0/1)
 interface fastEthernet0/1
  switchport trunk encapsulation dot1q
  switchport mode trunk
  switchport trunk native vlan 1000
  switchport trunk allowed vlan 100,200,1000
 exit

 ! Trunk to R1 (F0/5)
 interface fastEthernet0/5
  switchport trunk encapsulation dot1q
  switchport mode trunk
  switchport trunk native vlan 1000
  switchport trunk allowed vlan 100,200,1000
 exit
end
```
### 4.4 – S2 VLANs, SVI, access, parking lot, trunks

```bash
configure terminal
 vlan 999
  name ParkingLot
 vlan 1000
  name Native
 exit

 ! Management SVI on VLAN 1 (for Subnet C)
 interface vlan 1
  ip address 192.168.1.98 255.255.255.240
  no shutdown
 exit
 ip default-gateway 192.168.1.97

 ! PC-B access port (example: F0/18)
 interface fastEthernet0/18
  switchport mode access
  switchport access vlan 1
 exit

 ! Parking-lot all unused ports
 interface range fastEthernet0/2 - 4 , fastEthernet0/6 - 17 , fastEthernet0/19 - 24 , gigabitEthernet0/1 - 2
  switchport mode access
  switchport access vlan 999
 exit

 ! Trunk to S1 (F0/1)
 interface fastEthernet0/1
  switchport trunk encapsulation dot1q
  switchport mode trunk
  switchport trunk native vlan 1000
  switchport trunk allowed vlan 100,200,1000
 exit

 ! Access link to R2 LAN (F0/5) – single VLAN
 interface fastEthernet0/5
  switchport mode access
  switchport access vlan 1
 exit
end
```

## Part 5 – Configure DHCPv4 on R1

We’ll assume:
- Subnet A (VLAN 100) and Subnet C (behind R2) use DHCP.
- Management (Subnet B) is static.

```bash
configure terminal
 ! Exclude gateway and a few static addresses
 ip dhcp excluded-address 192.168.1.1 192.168.1.5
 ip dhcp excluded-address 192.168.1.65 192.168.1.69
 ip dhcp excluded-address 192.168.1.97 192.168.1.101

 ! Pool for Subnet A – VLAN 100 (clients near R1)
 ip dhcp pool LAN_A
  network 192.168.1.0 255.255.255.192
  default-router 192.168.1.1
  dns-server 209.165.201.14
  domain-name ccna-lab.com
 exit

 ! Pool for Subnet C – clients behind R2
 ip dhcp pool LAN_C
  network 192.168.1.96 255.255.255.240
  default-router 192.168.1.97
  dns-server 209.165.201.14
  domain-name ccna-lab.com
 exit
end
```

## Part 6 – Configure DHCP relay (helper) on R2

### R2 forwards DHCP broadcasts from its LAN to R1’s DHCP server (10.0.0.1):
```bash
configure terminal
 interface gigabitEthernet0/0/1
  ip helper-address 10.0.0.1
 exit
end
```

## Part 7 – Verification


### On R1 / R2
```bash
show ip interface brief
show ip dhcp pool
show ip dhcp binding
show ip dhcp server statistics
show ip route
```
### On S1 / S2

```bash
show vlan brief
show interfaces trunk
show ip interface brief
```


### On PCs (Packet Tracer)

- Set NICs to DHCP.
- Then run from the command prompt:

```bash
ipconfig /all
ping 192.168.1.1
ping 192.168.1.97
ping 10.0.0.1
ping 10.0.0.2
```

And test:
- PC-A ↔ PC-B
- PC ↔ default gateway(s)
- PC ↔ remote subnets.