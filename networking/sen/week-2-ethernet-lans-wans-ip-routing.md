# Ethernet Frame
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.1.png"/>

### Preamble
- Length: 7 bits (56 bits)
- `10101010` * 7
- Allow devices to synchronize their receiver clocks

### Start Frame Delimiter
- Length: 1 byte (8 bits)
- `10101011`
- Mark the end of the preamble, and the beginning of the rest of the frame.

### Destination and Source
- Indicate the devices sending and receiving the frame.
- Consist of the destination and MAC address (Media Access Control)
- Has 6 bytes (48 bits) address of physical device

### Type and Length
- 2 bytes (16 bits)
- A value of 1500 or less in this field indicates the LENGTH of the encapsulated packet (in bytes)
- A value of 1536 or greater in this field indicates the TYPE of the encapsulated packet (usually IPv4 or IPv6), and the length is determined via other methods.
- IPv4 = 0x0800 (hexadecimal) (2048 in decimal)

### FCS (Frame Check Sequence)
- 4 bytes
- Detect corrupted data by running a `CRC` algorithm over the received data
- CRC = `Cyclic Redundancy Check`


## Routing betwen Switches
### MAC addresses
- 6 bytes physical address assigned to the device when it is made
- A.K.A `Burned-In address` (BIA)
- Is globally unique
- The first 3 bytes are the OUI (Organizationally Unique Identifier), which is assigned to the company making the device.
- The last 3 bytes are unique to the device itself.
- Written as 12 hexadecimal characters.


## ARP (Address Resolution Protocol)
- ARP is used to discover the Layer 2 address (MAC address) of a known Layer 3 address (IP address)
- Consists of two messages:
    - ARP Request
    - ARP Reply
- `ARP Request` is `broadcast` = Sent to all hosts on the network
- `ARP Reply` is `unicast` = Sent only to one host (the host that sent the request)

## ARP Table
- Use `arp -a` to view the ARP table (Windows, MacOS, Linux)
- `Internet address` = IP Address (Layer 3 address)
- `Physical address` = MAC Address (Layer 2 address)
- `Type static` = default entry
- `Type dynamic` = learned via ARP 
### Show the MAC address table
```bash
show mac address-table
```
### Clear the MAC address table
```bash
clear mac address-table dynamic
# OR
clear mac address-table dynamic address 0c2f.b011.9d00
clear mac address-table dynamic interface Gi0/0
```

## Routing between Routers
- `Routing` is the process that routers use to determine the path that IP packets should take over a network to reach their destination.
    - Routers store routes to all of their known destinations in a `routing table`
    - When routers receive packets, they look in the `routing table` to find the best route to forward that packet.
- There are two main routing methods (methods that routers use to learn routers).
    -  Dynamic routing: Routers use _dynamic_ routing protocols (i.e. OSPF) to share information with each other automatically and build their routing tables
    - Static routing: A network engineer/admin manually configures routes on the router.

- A route tells the router: to send a packet to destination X, you should send the packet to `next-hop` Y.
    - Or, if the destination is directly connected to the router, send the packet directly to the destination.
    - Or, if the destination is the router's own IP address, receive the packet for yourself (don't forward it).

- WAN: A Wide Area Network = a network that extends over a large geographical area.

### Pre-configurations (IP Addresses)
```bash
R1# conf t
R1(config)# interface g0/0
R1(config-if)# ip address 192.168.13.1 255.255.255.0
R1(config-if)# no shutdown

R1(config-if)# interface g0/1
R1(config-if)# ip address 192.168.12.1 255.255.255.0
R1(config-if)# no shutdown

R1(config-if)# interface g0/2
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown

R1# show ip int br
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0     192.168.13.1    YES manual up                    up
GigabitEthernet0/1     192.168.12.1    YES manual up                    up
GigabitEthernet0/2     192.168.1.1     YES manual up                    up
GigabitEthernet0/3     unassigned      YES NVRAM administratively down down
```
## Routing Table (`show ip table`)
```bash
R1# show ip route

Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
       D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
       N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
       E1 - OSPF external type 1, E2 - OSPF external type 2
       i - IS-IS, su - IS-IS summary, L1 - IS-IS level-1, L2 - IS-IS level-2
       ia - IS-IS inter area, * - candidate default, U - per-user static route
       o - ODR, P - periodic downloaded static route, H - NHRP, l - LISP
       a - application route
       + - replicated route, % - next hop override, p - overrides from PfR

Gateway of last resort is not set

     192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.1.0/24 is directly connected, GigabitEthernet0/2
L       192.168.1.1/32 is directly connected, GigabitEthernet0/2
     192.168.12.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.12.0/24 is directly connected, GigabitEthernet0/1
L       192.168.12.1/32 is directly connected, GigabitEthernet0/1
     192.168.13.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.13.0/24 is directly connected, GigabitEthernet0/0
L       192.168.13.1/32 is directly connected, GigabitEthernet0/0
```

-  A connected route is a route to the network that the interface is connected to.
- R1 G0/2 IP = 192.168.1.1/24
- Network Address = 192.168.1.0/24
- It provides a route to all hosts in that network (ie. 192.168.1.10, 192.168.1.100, 192.168.1.232, etc.)
- R1 knows: "If I need to send a packet to any host in the 192.168.1.10/24 network, I should send it out of G0/2"
- A local route is a route to the exact IP address configuration on the interface.
- A `/32` netmask is used to specify the exact IP address of the interface.
    - `/32` means all 32 bits are _fixed_, they can't be changed
- Even though R1's G0/2 is configured as 192.168.1.1/24, the connected route is to 192.168.1.1/32
- R1 knows: "If I receive a packet destined for this IP address, the message is for me"

### Route selection
# Routing Table Notes

- **Routers store information** about destinations they know in their **routing table**.  
  When they receive packets, they look in the routing table to find the best route to forward the packet.  

- **Each route** in the routing table is an instruction:  
  - To reach destinations in network X, send the packet to **next-hop Y** (the next router in the path).  
  - If the destination is directly connected (**Connected route**), send the packet directly to the destination.  
  - If the destination is the router’s own IP (**Local route**), receive the packet for yourself.  

- **Connected route (C)**: Added when an interface IP is configured and enabled.  
  Example: if interface IP = `192.168.1.1/24`, then a route to `192.168.1.0/24` is added.  
  Tells the router: “Packets to this network go out this interface.”  

- **Local route (L)**: Added for the exact IP on the interface.  
  Example: if interface IP = `192.168.1.1/24`, then a route to `192.168.1.1/32` is added.  
  Tells the router: “Packets to this address are for me, not to be forwarded.”  

- **Route matching**: A packet matches a route if its destination IP falls within the network specified.  
  Example: `192.168.1.60` matches `192.168.1.0/24` but not `192.168.0.0/24`.  

- **No matching route**: The router drops the packet.  
  (Different from switches, which flood frames when there’s no MAC table entry.)  

- **Multiple matching routes**: The router chooses the **most specific match**, i.e., the route with the **longest prefix length**.  
  (Different from switches, which require an exact MAC address match.)

# Static Routing
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.2.png"/>

- R2 connected and Local Routes
```bash
R2# conf t
R2(config)# interface g0/0
R2(config-if)# ip address 192.168.12.2 255.255.255.0
R2(config-if)# no shutdown
R2(config-if)# interface g0/1
R2(config-if)# ip address 192.168.24.2 255.255.255.0
R2(config-if)# no shutdown

R2# show ip route
!codes output omitted

     192.168.12.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.12.0/24 is directly connected, GigabitEthernet0/0
L       192.168.12.2/32 is directly connected, GigabitEthernet0/0

     192.168.24.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.24.0/24 is directly connected, GigabitEthernet0/1
L       192.168.24.2/32 is directly connected, GigabitEthernet0/1
```

### Static Route Configuration (R1)
- ip route ip-address netmask next-hop
```bash
R1(config)# ip route 192.168.4.0 255.255.255.0 192.168.13.3
do show ip route
``` 

### Static Route Configuration with `exit-interface`
- ip route _ip-address_ _netmask_ _exit-interface_
```bash
R2(config)# ip route 192.168.1.0 255.255.255.0 g0/0
```
- ip route _ip-address_ _netmask_ _exit-interface_ _next-hop_
```bash
R2(config)# ip route 192.168.4.0 255.255.255.0 g0/1 192.168.24.4
```

### Default Route
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.3.png"/>

```bash
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.2
R1(config)# do show ip route
!most codes omitted
          ia - IS-IS inter area, * - candidate default, U - per-user static route
!most codes omitted
Gateway of last resort is 203.0.113.2 to network 0.0.0.0

S*   0.0.0.0/0 [1/0] via 203.0.113.2
S    10.0.0.0/8 [1/0] via 192.168.12.2
S    172.16.0.0/16 [1/0] via 192.168.13.3
     192.168.12.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.12.0/24 is directly connected, GigabitEthernet0/1
L       192.168.12.1/32 is directly connected, GigabitEthernet0/1
     192.168.13.0/24 is variably subnetted, 2 subnets, 2 masks
C       192.168.13.0/24 is directly connected, GigabitEthernet0/0
L       192.168.13.1/32 is directly connected, GigabitEthernet0/0
     203.0.113.0/24 is variably subnetted, 2 subnets, 2 masks
C       203.0.113.0/24 is directly connected, GigabitEthernet0/2
L       203.0.113.1/32 is directly connected, GigabitEthernet0/2
```