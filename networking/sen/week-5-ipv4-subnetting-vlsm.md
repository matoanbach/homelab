## IPv4 Address Classes
| Class | First Octet (Binary) | First Octet Range (Decimal) | Address Range               |
|-------|----------------------|-----------------------------|-----------------------------|
| A     | 0xxxxxxx             | 0 - 127                     | 0.0.0.0 ~ 127.255.255.255   |
| B     | 10xxxxxx             | 128 - 191                   | 128.0.0.0 ~ 191.255.255.255 |
| C     | 110xxxxx             | 192 - 223                   | 192.0.0.0 ~ 223.255.255.255 |
| D     | 1110xxxx             | 224 - 239                   | 224.0.0.0 ~ 239.255.255.255 |
| E     | 1111xxxx             | 240 - 255                   | 240.0.0.0 ~ 255.255.255.255 |

| Class   | Leading Bits | Size of Network Number Bit Field | Size of Rest Bit Field | Number of Networks | Addresses per Network |
|---------|--------------|----------------------------------|------------------------|--------------------|-----------------------|
| Class A | 0            | 8                                | 24                     | 128 (2^7)          | 16,777,216 (2^24)     |
| Class B | 10           | 16                               | 16                     | 16,384 (2^14)      | 65,536 (2^16)         |
| Class C | 110          | 24                               | 8                      | 2,097,152 (2^21)   | 256 (2^8)             |


- Company X needs IP addressing for 5000 end hosts.
- A class C network does not provide enough addresses, so a class B network must be assigned.
- This will result in about 60000 addresses being wasted.

## iana
- The IANA (Internet Assigned Numbers Authority) assigns IPv4 addresses/networks to companies based on their size.
- For example, a very large company might receive a class A or class B network, while a small company might receive a class C network.
- However, this led to many wasted IP addresses.

## CIDR (Classless Inter-Domain Routing)
- When the Internet was first created, the creators did not predict that the Internet would become as large as it is today.
- This resulted in wasted address space like the examples I showed you (there are many more examples).
- The IETF (Internet Engineering Task Force) introduced CIDR in 1993 to replace the `classful` addressing system.
- With CIDR, the requirements of classes are removed.
- This allowed larger networks to be split into smaller networks, allowing greater efficiency.
- These smaller networks are called `subnetworks` or `subnets`.

### CIDR Notation
| Dotted Decimal  | CIDR Notation |
|-----------------|---------------|
| 255.255.255.128 | /25           |
| 255.255.255.192 | /26           |
| 255.255.255.224 | /27           |
| 255.255.255.240 | /28           |
| 255.255.255.248 | /29           |
| 255.255.255.252 | /30           |
| 255.255.255.254 | /31           |
| 255.255.255.255 | /32           |

### Subnetting Trick
**Subnet:** `192.168.1.192/26`

#### Binary Breakdown of Last Octet (192)
| Bit Value | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|-----------|-----|----|----|----|---|---|---|---|
| Bit State | 1   | 1  | 0  | 0  | 0 | 0 | 0 | 0 |

#### Portion Split
- **Network Portion:** First 26 bits → `192.168.1.192`  
- **Host Portion:** Last 6 bits  

#### Subnet Details
- **Subnet Mask:** `255.255.255.192`  
- **Block Size (Increment):** 64  
- **Subnet Range:** `192.168.1.192 – 192.168.1.255`  
- **Network Address:** `192.168.1.192`  
- **Broadcast Address:** `192.168.1.255`  
- **Usable Hosts:** 62 (from `192.168.1.193` to `192.168.1.254`)

## Subnet/Hosts (Class C)
| Prefix Length | Number of Subnets | Number of Hosts |
|---------------|-------------------|-----------------|
| /25           | 2                 | 126             |
| /26           | 4                 | 62              |
| /27           | 8                 | 30              |
| /28           | 16                | 14              |
| /29           | 32                | 6               |
| /30           | 64                | 2               |
| /31           | 128               | 0 (2)           |
| /32           | 256               | 0 (1)           |

## Subnet/Hosts (Class B)
| Prefix Length | Number of Subnets | Number of Hosts |
|---------------|-------------------|-----------------|
| /17           | 2                 | 32,766          |
| /18           | 4                 | 16,382          |
| /19           | 8                 | 8,190           |
| /20           | 16                | 4,094           |
| /21           | 32                | 2,046           |
| /22           | 64                | 1,022           |
| /23           | 128               | 510             |
| /24           | 256               | 254             |
| /25           | 512               | 126             |
| /26           | 1024              | 62              |
| /27           | 2048              | 30              |
| /28           | 4096              | 14              |
| /29           | 8192              | 6               |
| /30           | 16384             | 2               |
| /31           | 32768             | 0 (2)           |
| /32           | 65536             | 0 (1)           |

## Subnet/Hosts (Class A)

### Subnetting Class A Networks
- PC1 has an IP address of 10.217.182.223/11. Identify the following for PC1's subnet:
    - Network address: `10.192.0.0/11`
    - Broadcast address: `10.223.255.255/11`
    - First usable address: `10.192.0.1/11`
    - Last usable address: `10.233.255.254/11`
    - Number of hosts (usable) addresses: `2,097,150` 

## Variable-Length Subnet Mask
- Until now, we have practiced subnetting used FLSM (Fixed-Length Subnet Masks).
- This means that all of the subnets use the same prefix length (ie. subnetting a class C network into 4 subnets using `\24`)
- VLSM (Variable-Length Subnet Masks) is the process of creating subnets of different sizes, to make your use of network addresses more efficient.
- VLSM is more complicated than FLSM, but it's easy if you follow the steps correctly.

## DHCP
- DHCP is used to allow hosts to automatically/dynamically learn various aspects of their network configuration, such as IP addresses, subnet mask, default gateway, DNS Server, etc, without manual/static ocnfiguration.
- It is an essential part of modern networks.
    - When you connect a phone/laptop to WiFi, do you ask the network admin which IP address, subnet mask, default gateway, etc, the phone/laptop should use?
- Typically used for `client devices` such as workstation (PCs), phones, etc.
- Devices such as routers, servers, etc, are usually manually configured.
- In small networks (such as home networks) the router typically acts as the DHCP server for hosts in LAN.
- In larger networks, the DHCP server is usually a Windows/Linux server.

```bash
ipconfig /all
ipconfig /release
ipconfig /renew
```

### DHCP D-O-R-A
| Type     | Directrion       | Com                  |
|----------|------------------|----------------------|
| Discover | Client -> Server | Broadcast            |
| Offer    | Server -> Client | Broadcast or Unicast |
| Request  | Client -> Server | Broadcast            |
| Ack      | Server -> Client | Broadcast or Unicast |
| Release  | Client -> Server | Unicast              |

### DHCP Relay
- Some network engineers might choose to configure each router to ac as the DHCP server.
- However, large enterprises often choose to use a centralized DHCP server.
- If the server is centralized, it won't receive the DHCP clients' broadcast DHCP messages. (Broadcast messages don't leave the local subnet)
- To fix this, you can configure a router to act as a `DHCP relay agent`.
- The router will forward the clients' broadcast DHCP messages to the remote DHCP server as unicast messages.


<img src="https://github.com/matoanbach/networking/blob/main/pics/w5.1.png"/>

# DHCP Server Configuration in IOS

## Commands

```
R1(config)#ip dhcp excluded-address 192.168.1.1 192.168.1.10
```
- Specify a range of addresses that **won’t** be given to DHCP clients.

```
R1(config)#ip dhcp pool LAB_POOL
```
- Create a DHCP pool.

```
R1(dhcp-config)#network 192.168.1.0 ?
/nn or A.B.C.D  Network mask or prefix length <cr>
R1(dhcp-config)#network 192.168.1.0 /24
```
- Specify the subnet of addresses to be assigned to clients (except the excluded addresses).

```
R1(dhcp-config)#dns-server 8.8.8.8
```
- Specify the DNS server that DHCP clients should use.

```
R1(dhcp-config)#domain-name jeremysitlab.com
```
- Specify the domain name of the network (ie. PC1 = pc1.jeremysitlab.com).

```
R1(dhcp-config)#default-router 192.168.1.1
```
- Specify the default gateway.

```
R1(dhcp-config)#lease 0 5 30

R1# show ip dhcp binding
```
- Specify the lease time.  
  - Format: `lease days hours minutes`  
  - Or use: `lease infinite`

# DHCP Relay Agent Configuration in IOS

## Commands

```
R1(config)#interface g0/1
```
- Configure the interface connected to the subnet of the client devices.

```
R1(config-if)#ip helper-address 192.168.10.10
```
- Configure the IP address of the DHCP server as the 'helper' address.

```
R1(config-if)#do show ip interface g0/1
GigabitEthernet0/1 is up, line protocol is up
  Internet address is 192.168.1.1/24
  Broadcast address is 255.255.255.255
  Address determined by non-volatile memory
  MTU is 1500 bytes
  Helper address is 192.168.10.10

[output omitted]
```

# DHCP Client Configuration in IOS

## Commands

```
R2(config)#interface g0/1
```
- Configure the interface.

```
R2(config-if)#ip address dhcp
```
- Use the `ip address dhcp` mode to tell the router to use DHCP to learn its IP address.

```
R2(config-if)#do sh ip interface g0/1
GigabitEthernet0/1 is up, line protocol is up
  Internet address is 192.168.10.1/24
  Broadcast address is 255.255.255.255
  Address determined by DHCP

[output omitted]
```

# DHCP Command Summary

## Windows Commands
```
C:\Users\user> ipconfig /release
C:\Users\user> ipconfig /renew
```

## DHCP Server Commands
```
R1(config)# ip dhcp excluded-address low-address high-address
R1(config)# ip dhcp pool pool-name
R1(dhcp-config)# network ip-address {/prefix-length | subnet-mask}
R1(dhcp-config)# dns-server ip-address
R1(dhcp-config)# domain-name domain-name
R1(dhcp-config)# default-router ip-address
R1(dhcp-config)# lease {days hours minutes | infinite}
R1# show ip dhcp binding
```

## DHCP Relay Agent Command
```
R1(config-if)# ip helper-address ip-address
```

## DHCP Client Command
```
R1(config-if)# ip address dhcp
```
