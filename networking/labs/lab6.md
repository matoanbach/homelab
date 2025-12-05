# Lab 6
<img src="https://github.com/matoanbach/homelab/blob/main/networking/pics/lab6.1.png"/>

## Part 1 – Build the Network & Basic Device Settings

### 1.1 Basic router config (R1, R2, R3)

- R1
```bash
enable
configure terminal
 hostname R1
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
  logging synchronous
 exit

 line vty 0 4
  password cisco
  login
 exit

 banner motd #Unauthorized access is prohibited#
 service password-encryption
end
copy running-config startup-config
```
- R2
```bash
enable
configure terminal
 hostname R2
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
  logging synchronous
 exit

 line vty 0 4
  password cisco
  login
 exit

 banner motd #Unauthorized access is prohibited#
 service password-encryption
end
copy running-config startup-config
```
- R3
```bash
enable
configure terminal
 hostname R3
 no ip domain-lookup
 enable secret class

 line console 0
  password cisco
  login
  logging synchronous
 exit

 line vty 0 4
  password cisco
  login
 exit

 banner motd #Unauthorized access is prohibited#
 service password-encryption
end
copy running-config startup-config
```

### 1.2 Configure router interfaces + clock rate + IPs

```txt
Addressing from table  ￼
	•	R1
	•	G0/0: 192.168.1.1 /24
	•	S0/0/0 (DCE): 192.168.12.1 /30
	•	S0/0/1: 192.168.13.1 /30
	•	R2
	•	G0/0: 192.168.2.1 /24
	•	S0/0/0: 192.168.12.2 /30
	•	S0/0/1 (DCE): 192.168.23.1 /30
	•	R3
	•	G0/0: 192.168.3.1 /24
	•	S0/0/0 (DCE): 192.168.13.2 /30
	•	S0/0/1: 192.168.23.2 /30
```

- R1 interfaces
```bash
configure terminal
 interface g0/0
  ip address 192.168.1.1 255.255.255.0
  no shutdown
 exit

 interface s0/0/0
  ip address 192.168.12.1 255.255.255.252
  clock rate 128000      ! DCE
  no shutdown
 exit

 interface s0/0/1
  ip address 192.168.13.1 255.255.255.252
  no shutdown
 exit
end
copy running-config startup-config
```
- R2 interfaces


```bash
configure terminal
 interface g0/0
  ip address 192.168.2.1 255.255.255.0
  no shutdown
 exit

 interface s0/0/0
  ip address 192.168.12.2 255.255.255.252
  no shutdown
 exit

 interface s0/0/1
  ip address 192.168.23.1 255.255.255.252
  clock rate 128000      ! DCE
  no shutdown
 exit
end
copy running-config startup-config
```

- R3 interfaces
```bash
configure terminal
 interface g0/0
  ip address 192.168.3.1 255.255.255.0
  no shutdown
 exit

 interface s0/0/0
  ip address 192.168.13.2 255.255.255.252
  clock rate 128000      ! DCE
  no shutdown
 exit

 interface s0/0/1
  ip address 192.168.23.2 255.255.255.252
  no shutdown
 exit
end
copy running-config startup-config
```

### 1.3 Configure PC hosts (Packet Tracer GUI)
```txt
	•	PC-A NIC
	•	IP: 192.168.1.3
	•	Mask: 255.255.255.0
	•	Default GW: 192.168.1.1
	•	PC-B NIC
	•	IP: 192.168.2.3
	•	Mask: 255.255.255.0
	•	Default GW: 192.168.2.1
	•	PC-C NIC
	•	IP: 192.168.3.3
	•	Mask: 255.255.255.0
	•	Default GW: 192.168.3.1
```

### Verification commands (on routers):
```
ping 192.168.12.2
ping 192.168.13.2
ping 192.168.23.1
ping 192.168.23.2
show ip interface brief
```
### Part 2 – Configure and Verify OSPF Routing

#### 2.1 Configure OSPF on R1

```bash
configure terminal
 router ospf 1
  network 192.168.1.0 0.0.0.255 area 0
  network 192.168.12.0 0.0.0.3 area 0
  network 192.168.13.0 0.0.0.3 area 0
 exit
end
```

#### 2.2 Configure OSPF on R2
```bash
configure terminal
 router ospf 1
  network 192.168.2.0 0.0.0.255 area 0
  network 192.168.12.0 0.0.0.3 area 0
  network 192.168.23.0 0.0.0.3 area 0
 exit
end
```
#### 2.3 Configure OSPF on R3

```bash
configure terminal
 router ospf 1
  network 192.168.3.0 0.0.0.255 area 0
  network 192.168.13.0 0.0.0.3 area 0
  network 192.168.23.0 0.0.0.3 area 0
 exit
end
```
#### 2.4 Verification commands

```bash
show ip ospf neighbor
show ip route
show ip route ospf       ! only OSPF routes
show ip protocols
show ip ospf
show ip ospf interface brief
show ip ospf interface
```

## Part 3 – Change Router ID Assignments

#### 3.1 Set router IDs using loopback interfaces

- R1
```bash
configure terminal
 interface loopback0
  ip address 1.1.1.1 255.255.255.255
 exit
end
copy running-config startup-config
reload
```
- R2
```
configure terminal
 interface loopback0
  ip address 2.2.2.2 255.255.255.255
 exit
end
copy running-config startup-config
reload
```
- R3
```bash
configure terminal
 interface loopback0
  ip address 3.3.3.3 255.255.255.255
 exit
end
copy running-config startup-config
reload
```
#### Check:
```
show ip protocols
show ip ospf neighbor
```

### 3.2 Change router ID with router-id command

- R1 → 11.11.11.11
```bash
configure terminal
 router ospf 1
  router-id 11.11.11.11
 exit
end
clear ip ospf process
yes
```
- R2 → 22.22.22.22

```bash
configure terminal
 router ospf 1
  router-id 22.22.22.22
 exit
end
clear ip ospf process
yes
```
- R3 → 33.33.33.33

```bash
configure terminal
 router ospf 1
  router-id 33.33.33.33
 exit
end
clear ip ospf process
yes
```
### Verify:

```bash
show ip protocols
show ip ospf neighbor
```


## Part 4 – Configure OSPF Passive Interfaces

### 4.1 Make G0/0 on R1 passive
```bash
configure terminal
 router ospf 1
  passive-interface g0/0
 exit
end
```
### Check:
```bash
show ip ospf interface g0/0
show ip route
```
### 4.2 Make all interfaces on R2 passive, then enable selected ones

#### First: passive default on R2
```bash
configure terminal
 router ospf 1
  passive-interface default
 exit
end
```

#### Check neighbors:
```bash
show ip ospf neighbor
show ip ospf interface s0/0/0
```
- Then: re-enable OSPF on S0/0/0 (and later S0/0/1)

```bash
configure terminal
 router ospf 1
  no passive-interface s0/0/0
  ! later in the lab:
  ! no passive-interface s0/0/1
 exit
end
```
- Verification:
```bash
show ip route
show ip ospf neighbor
show ip route ospf
```

## Part 5 – Change OSPF Metrics

### 5.1 Change reference bandwidth (all routers)

- On R1:
```bash
configure terminal
 router ospf 1
  auto-cost reference-bandwidth 10000
 exit
end
```
- Repeat same on R2 and R3.

- To reset to default later:
```bash
configure terminal
 router ospf 1
  auto-cost reference-bandwidth 100
 exit
end
```

- Verification:
```bash
show ip ospf interface g0/0
show ip ospf interface s0/0/1
show ip route ospf
```

#### 5.2 Change interface bandwidths

- On R1 – S0/0/0

```bash
configure terminal
 interface s0/0/0
  bandwidth 128
 exit
end
```

- Check:
```bash
show interface s0/0/0
show ip route ospf
show ip ospf interface brief
```

- Then R1 – S0/0/1 (match S0/0/0)
```bash
configure terminal
 interface s0/0/1
  bandwidth 128
 exit
end
```
- Then apply bandwidth 128 to all remaining serial interfaces (R2, R3) as per lab:
- Example:
```bash
configure terminal
 interface s0/0/0
  bandwidth 128
 exit

 interface s0/0/1
  bandwidth 128
 exit
end

(on R2 and R3 as needed)
```

- Verify:
```bash
show ip ospf interface brief
show ip route ospf
```

#### 5.3 Manually change OSPF cost

- On R1 S0/0/1:
```bash
configure terminal
 interface s0/0/1
  ip ospf cost 1565
 exit
end
```

- Verify effect:
```bash
show ip route ospf
show ip ospf interface s0/0/1

You’ll see all OSPF routes from R1 going via R2 because the path through S0/0/1 now has higher cost than the path through S0/0/0.
```