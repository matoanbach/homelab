## Part 1 – Set Up the Topology and Initialize Devices

### 1.1 Erase old configs (on each router and switch)
```bash
enable
write erase        ! or: erase startup-config
reload
! When prompted:
Proceed with reload? [confirm]    <Enter>
System configuration dialog? [yes/no]: no

(Do that on R1, R3, S1, S2.)
```

## Part 2 – Basic Device Settings and IP Addressing

### 2.1 Configure PC interfaces (Packet Tracer / Windows)

- PC-A
```txt
	•	IP: 192.168.0.10
	•	Mask: 255.255.255.0
	•	Default gateway: 192.168.0.1
```

- PC-C
```txt
	•	IP: 192.168.1.10
	•	Mask: 255.255.255.0
	•	Default gateway: 192.168.1.1
```

### 2.2 Basic settings on R1

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
### 2.3 Basic settings on R3

```bash
enable
configure terminal
 hostname R3
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

### 2.4 Configure IP settings on the routers

#### R1 interfaces
```bash
configure terminal
 interface g0/1
  ip address 192.168.0.1 255.255.255.0
  no shutdown
 exit

 interface s0/0/1
  ip address 10.1.1.1 255.255.255.252
  no shutdown
 exit
end
```

### R3 interfaces + loopbacks

```bash
configure terminal
 interface g0/1
  ip address 192.168.1.1 255.255.255.0
  no shutdown
 exit

 interface s0/0/0
  ip address 10.1.1.2 255.255.255.252
  clock rate 128000
  no shutdown
 exit

 interface loopback0
  ip address 209.165.200.225 255.255.255.224
 exit

 interface loopback1
  ip address 198.133.219.1 255.255.255.0
 exit
end
```

### 2.5 Verification commands

#### On R1:

```bash
show ip interface brief
show ip route
```

#### On R3:

```bash
show ip interface brief
show ip route
```

- Pings:
```txt
	•	On PC-A: ping 192.168.0.1
	•	On PC-C: ping 192.168.1.1
	•	On R1: ping 10.1.1.2
	•	On R3: ping 10.1.1.1
	•	PC-A → ping 192.168.1.10 (will fail until static routes are added)
```
### Part 3 – Configure Static Routes

#### 3.1 Recursive static route on R1 (to 192.168.1.0/24)

```bash
configure terminal
 ip route 192.168.1.0 255.255.255.0 10.1.1.2
end
show ip route

(You should see an S route to 192.168.1.0/24 via 10.1.1.2.)

At this point, PC-A → PC-C ping still fails because R3 has no route back to 192.168.0.0/24.
```

#### 3.2 Directly connected static route on R3 (to 192.168.0.0/24)

```bash
configure terminal
 ip route 192.168.0.0 255.255.255.0 s0/0/0
end
show ip route

(You should see S 192.168.0.0/24 is directly connected, Serial0/0/0.)

Now PC-A ↔ PC-C pings should succeed.
```

####  3.3 Static routes from R1 to the loopback networks on R3

- We use one recursive and one directly connected:

##### On R1:

```bash
configure terminal
 ! To 198.133.219.0/24 via next-hop IP (recursive)
 ip route 198.133.219.0 255.255.255.0 10.1.1.2

 ! To 209.165.200.224/27 via exit interface (directly connected)
 ip route 209.165.200.224 255.255.255.224 s0/0/1
end
show ip route
```

###### Now from PC-A:
```bash
ping 198.133.219.1
ping 209.165.200.225
(both should succeed once routes and return paths exist).
```

#### 3.4 Remove static routes for the two loopbacks (on R1)
```bash
configure terminal
 no ip route 198.133.219.0 255.255.255.0 10.1.1.2
 no ip route 209.165.200.224 255.255.255.224 s0/0/1
end
show ip route
```
## Part 4 – Configure and Verify a Default Route

### 4.1 Default route on R1 via S0/0/1
```bash
configure terminal
 ip route 0.0.0.0 0.0.0.0 s0/0/1
end
show ip route

You should see something like:

S* 0.0.0.0/0 is directly connected, Serial0/0/1

S* indicates a static default and “Gateway of last resort.”
```

### 4.2 Final pings from PC-A

#### From PC-A:
```bash
ping 209.165.200.225
ping 198.133.219.1

Both should now succeed (assuming R3 still has its static route back to 192.168.0.0/24).

If you want, next we can go question-by-question in the lab sheet (the written answers) and keep them super short, like 1–2 sentences each.
```