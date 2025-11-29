# Lab 4
<img src="https://github.com/matoanbach/networking/blob/main/pics/lab4.1.png"/>

## Addressing recap (for reference)
- Subnet A (VLAN 100 clients at R1)
- Network: 192.168.1.0/26 (mask 255.255.255.192)
- R1 G0/0/1.100: 192.168.1.1/26  (default-gw for PC-A LAN)
- Subnet B (VLAN 200 mgmt at R1/S1)
- Network: 192.168.1.64/27 (mask 255.255.255.224)
- R1 G0/0/1.200: 192.168.1.65/27
- S1 VLAN 200: 192.168.1.66/27 (S1 default-gw 192.168.1.65)
- Subnet C (R2/S2/PC-B LAN)
- Network: 192.168.1.96/28 (mask 255.255.255.240)
- R2 G0/0/1: 192.168.1.97/28 (default-gw for PC-B LAN)
- S2 VLAN 1: 192.168.1.98/28 (S2 default-gw 192.168.1.97)
- R1–R2 link
- G0/0/0 R1: 10.0.0.1/30
- G0/0/0 R2: 10.0.0.2/30

⸻

## Part 1 – Build the network & basic device settings

### 1.1  Basic router config (R1 & R2)

#### R1
```bash
enable
conf t
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
copy run start
```
#### R2

```bash
enable
conf t
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
copy run start
```

### 1.2  Configure router interfaces + static routing

#### R1 – interfaces + router-on-a-stick
```bash
conf t
! R1–R2 link
interface g0/0/0
 ip address 10.0.0.1 255.255.255.252
 no shutdown
exit

! Physical towards S1
interface g0/0/1
 no shutdown
exit

! VLAN 100 – Subnet A
interface g0/0/1.100
 encapsulation dot1Q 100
 ip address 192.168.1.1 255.255.255.192
exit

! VLAN 200 – Subnet B
interface g0/0/1.200
 encapsulation dot1Q 200
 ip address 192.168.1.65 255.255.255.224
exit

! Native VLAN 1000 (no IP)
interface g0/0/1.1000
 encapsulation dot1Q 1000 native
 no ip address
exit

! Default route toward R2
ip route 0.0.0.0 0.0.0.0 10.0.0.2
end
copy run start
```
#### R2 – interfaces + static route

```bash
conf t
! R1–R2 link
interface g0/0/0
 ip address 10.0.0.2 255.255.255.252
 no shutdown
exit

! LAN for Subnet C
interface g0/0/1
 ip address 192.168.1.97 255.255.255.240
 no shutdown
exit

! Default route toward R1
ip route 0.0.0.0 0.0.0.0 10.0.0.1
end
copy run start
```

### 1.3  Basic switch config (S1 & S2)

#### S1
```bash
enable
conf t
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
copy run start
```
#### S2

```bash
enable
conf t
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
copy run start
```
 
### 1.4  Create VLANs and management SVIs

#### S1 – VLANs, mgmt SVI, parking-lot
```bash
conf t
! VLANs
vlan 100
 name Clients
vlan 200
 name Management
vlan 999
 name Parking_Lot
vlan 1000
 name Native
exit

! Management interface in VLAN 200
interface vlan 200
 ip address 192.168.1.66 255.255.255.224
 no shutdown
exit
ip default-gateway 192.168.1.65

! Parking-lot all unused ports
interface range f0/1 - 4 , f0/7 - 24 , g0/1 - 2
 switchport mode access
 switchport access vlan 999
 shutdown
exit
end
copy run start
```

#### S2 – mgmt SVI, shut unused
```bash
conf t
! Management interface on VLAN 1 (Subnet C)
interface vlan 1
 ip address 192.168.1.98 255.255.255.240
 no shutdown
exit
ip default-gateway 192.168.1.97

! Shut all unused ports (adjust if some are used in your pod)
interface range f0/1 - 4 , f0/6 - 17 , f0/19 - 24 , g0/1 - 2
 shutdown
exit
end
copy run start
```


### 1.5  Assign switch ports & configure trunk

#### S1 – access port for PC-A + trunk to R1
```bash
conf t
! PC-A access port, VLAN 100
interface f0/6
 switchport mode access
 switchport access vlan 100
 no shutdown
exit

! F0/5 as 802.1Q trunk toward R1
interface f0/5
 switchport mode trunk        ! force trunking
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 1000
 switchport trunk allowed vlan 100,200,1000
 no shutdown
exit
end
copy run start
```
#### S2 – access port for PC-B (VLAN 1)
```bash
conf t
interface f0/18
 switchport mode access
 switchport access vlan 1
 no shutdown
exit
end
copy run start

(Port F0/5 on S2 that goes to R2 can stay as default access on VLAN 1; you don’t need a trunk there.)
```

## Part 2 – Configure and verify two DHCPv4 servers on R1

### R1 – DHCP server
```bash
conf t
! Exclude first 5 usable in each served subnet
ip dhcp excluded-address 192.168.1.1 192.168.1.5     ! Subnet A
ip dhcp excluded-address 192.168.1.97 192.168.1.101  ! Subnet C

! Pool for Subnet A (VLAN 100 clients)
ip dhcp pool R1_Client_LAN
 network 192.168.1.0 255.255.255.192
 default-router 192.168.1.1
 domain-name ccna-lab.com
 dns-server 209.165.201.14
 lease 2 12 30
exit

! Pool for Subnet C (behind R2)
ip dhcp pool R2_Client_LAN
 network 192.168.1.96 255.255.255.240
 default-router 192.168.1.97
 domain-name ccna-lab.com
 dns-server 209.165.201.14
 lease 2 12 30
exit
end
copy run start
```
#### Verification commands on R1
```bash
show ip dhcp pool
show ip dhcp binding
show ip dhcp server statistics

Then on PC-A:

ipconfig /renew
ipconfig
ping 192.168.1.1
```

### Part 3 – Configure and verify DHCP relay on R2

#### R2 – relay on G0/0/1
```bash
conf t
interface g0/0/1
 ip helper-address 10.0.0.1   ! R1’s G0/0/0
exit
end
copy run start
```

#### On PC-B:
```bash
ipconfig /renew
ipconfig
ping 192.168.1.1
```
### Back on R1 / R2 you can also check:

```bash
R1# show ip dhcp binding
R1# show ip dhcp server statistics
R2# show ip dhcp server statistics
```