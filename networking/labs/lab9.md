# LAB 9
<img src="https://github.com/matoanbach/networking/blob/main/pics/lab9.1.png"/>
## Part 1 – Build the Network and Configure Basic Device Settings

### 1.1 Basic settings – R1
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
### 1.1 Basic settings – R2

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

### 1.2 Basic settings – S1
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

### 1.2 Basic settings – S2

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
# Configure VLANs on the Switches
```

### 1.3 VLANs, management SVI, parking-lot – S1
```bash
configure terminal
! Create VLANs
vlan 20
 name Management
vlan 30
 name Operations
vlan 40
 name Sales
vlan 999
 name ParkingLot
vlan 1000
 name Native
exit

! Management SVI
interface vlan 20
 ip address 10.20.0.2 255.255.255.0
 no shutdown
exit
ip default-gateway 10.20.0.1

! Assign used ports
! PC-A in VLAN 30
interface fastEthernet0/6
 switchport mode access
 switchport access vlan 30
 no shutdown
exit

! Parking lot all unused ports on S1
interface range fastEthernet0/2 - 4 , fastEthernet0/7 - 24 , gigabitEthernet0/1 - 2
 switchport mode access
 switchport access vlan 999
 shutdown
exit
end
```
### 1.3 VLANs, management SVI, parking-lot – S2

```bash
configure terminal
! Create VLANs
vlan 20
 name Management
vlan 30
 name Operations
vlan 40
 name Sales
vlan 999
 name ParkingLot
vlan 1000
 name Native
exit

! Management SVI
interface vlan 20
 ip address 10.20.0.3 255.255.255.0
 no shutdown
exit
ip default-gateway 10.20.0.1

! Assign used ports
! Management port S2 F0/5 -> VLAN 20
interface fastEthernet0/5
 switchport mode access
 switchport access vlan 20
 no shutdown
exit

! PC-B in VLAN 40
interface fastEthernet0/18
 switchport mode access
 switchport access vlan 40
 no shutdown
exit

! Parking-lot all other unused ports
interface range fastEthernet0/2 - 4 , fastEthernet0/6 - 17 , fastEthernet0/19 - 24 , gigabitEthernet0/1 - 2
 switchport mode access
 switchport access vlan 999
 shutdown
exit
end

(Use show vlan brief on each switch to verify.)
# Configure Trunking
```

### 1.4 Trunk between S1 and S2 – F0/1 on both


#### On S1:
```bash
configure terminal
interface fastEthernet0/1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 1000
 switchport trunk allowed vlan 20,30,40,1000
 no shutdown
exit
end
```

#### On S2:
```bash
configure terminal
interface fastEthernet0/1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 1000
 switchport trunk allowed vlan 20,30,40,1000
 no shutdown
exit
end
```

#### Check:
```
show interfaces trunk
```

#### 1.5 Trunk S1–R1 – S1 F0/5
```bash
configure terminal
interface fastEthernet0/5
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk native vlan 1000
 switchport trunk allowed vlan 20,30,40,1000
 no shutdown
exit
end

(Interface on R1 is routed, so trunking is on S1 side only.)
```

# Configure Routing

#### 1.6 Inter-VLAN routing on R1 (router-on-a-stick) + loopback
```bash
configure terminal
! Physical interface to S1
interface gigabitEthernet0/0/1
 no shutdown
exit

! VLAN 20 – Management
interface gigabitEthernet0/0/1.20
 description Management VLAN 20
 encapsulation dot1Q 20
 ip address 10.20.0.1 255.255.255.0
exit

! VLAN 30 – Operations
interface gigabitEthernet0/0/1.30
 description Operations VLAN 30
 encapsulation dot1Q 30
 ip address 10.30.0.1 255.255.255.0
exit

! VLAN 40 – Sales
interface gigabitEthernet0/0/1.40
 description Sales VLAN 40
 encapsulation dot1Q 40
 ip address 10.40.0.1 255.255.255.0
exit

! Native VLAN 1000 – no IP
interface gigabitEthernet0/0/1.1000
 description Native VLAN 1000
 encapsulation dot1Q 1000 native
 no ip address
exit

! Loopback simulating Internet
interface loopback1
 ip address 172.16.1.1 255.255.255.0
exit
end

show ip interface brief
```
### 1.7 R2 G0/0/1 and default route

```bash
configure terminal
interface gigabitEthernet0/0/1
 ip address 10.20.0.4 255.255.255.0
 no shutdown
exit

! Default route on R2 toward R1
ip route 0.0.0.0 0.0.0.0 10.20.0.1
end

show ip route
```

# Configure Remote Access (SSH) – all devices

- Do this on R1, R2, S1, S2.
```bash
configure terminal
username SSHadmin secret $cisco123!
ip domain-name ccna-lab.com

crypto key generate rsa
 modulus 1024

line vty 0 4
 transport input ssh
 login local
exit
end

- You can also verify with:
```bash
show ip ssh
show users
```

# Verify Connectivity (before ACLs)
- Set PC IPs:
```txt
	•	PC-A
	•	IP: 10.30.0.10
	•	Mask: 255.255.255.0
	•	Gateway: 10.30.0.1
	•	PC-B
	•	IP: 10.40.0.10
	•	Mask: 255.255.255.0
	•	Gateway: 10.40.0.1
```

- Then test (should all succeed before ACLs):
```txt
	•	PC-A → ping 10.40.0.10
	•	PC-A → ping 10.20.0.1
	•	PC-B → ping 10.30.0.10
	•	PC-B → ping 10.20.0.1
	•	PC-B → ping 172.16.1.1
	•	PC-B → SSH 10.20.0.1
	•	PC-B → SSH 172.16.1.1
```

# Part 2 – Configure and Verify Extended IPv4 ACLs

- Security policies recap
```txt
	•	Policy 1: Sales (10.40.0.0/24) cannot SSH to Management (10.20.0.0/24). Other SSH OK.
	•	Policy 2: Sales cannot send ICMP echo to Operations (10.30.0.0/24) or Management (10.20.0.0/24).
	•	Policy 3: Operations (10.30.0.0/24) cannot send ICMP echo to Sales (10.40.0.0/24).
```

- We’ll enforce these with ACLs on R1 subinterfaces:
```txt
	•	ACL 101 inbound on G0/0/1.40 (Sales VLAN interface).
	•	ACL 102 inbound on G0/0/1.30 (Operations VLAN interface).
```

## 2.1 ACL 101 – block Sales → Mgmt/Ops ICMP + Sales → Mgmt SSH

- On R1:
```bash
configure terminal
! Block SSH from Sales (10.40.0.0/24) to Management (10.20.0.0/24)
access-list 101 deny tcp 10.40.0.0 0.0.0.255 10.20.0.0 0.0.0.255 eq 22

! Block ICMP echo from Sales to Management
access-list 101 deny icmp 10.40.0.0 0.0.0.255 10.20.0.0 0.0.0.255 echo

! Block ICMP echo from Sales to Operations
access-list 101 deny icmp 10.40.0.0 0.0.0.255 10.30.0.0 0.0.0.255 echo

! Permit everything else
access-list 101 permit ip any any

! Apply inbound on Sales subinterface
interface gigabitEthernet0/0/1.40
 ip access-group 101 in
exit
end
```

## 2.2 ACL 102 – block Ops → Sales ICMP echo

- Still on R1:

```bash
configure terminal
! Block ICMP echo from Operations (10.30.0.0/24) to Sales (10.40.0.0/24)
access-list 102 deny icmp 10.30.0.0 0.0.0.255 10.40.0.0 0.0.0.255 echo

! Permit all other traffic
access-list 102 permit ip any any

! Apply inbound on Operations subinterface
interface gigabitEthernet0/0/1.30
 ip access-group 102 in
exit
end
```

- Check ACLs:
```bash
show access-lists
show ip interface gigabitEthernet0/0/1.30
show ip interface gigabitEthernet0/0/1.40
```

### 2.3 Verification (after ACLs)

- Expected results from the lab after ACLs are applied:
```txt
From	Protocol	To	Expect
PC-A	ping	10.40.0.10	Fail (Ops → Sales ICMP blocked)
PC-A	ping	10.20.0.1	Success
PC-B	ping	10.30.0.10	Fail (Sales → Ops ICMP blocked)
PC-B	ping	10.20.0.1	Fail (Sales → Mgmt ICMP blocked)
PC-B	ping	172.16.1.1	Success (Sales → Loopback OK)
PC-B	SSH	10.20.0.4	Fail (Sales → R2 SSH via Mgmt blocked)
PC-B	SSH	172.16.1.1	Success
```