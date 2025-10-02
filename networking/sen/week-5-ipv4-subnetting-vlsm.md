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
| Dotted Decimal     | CIDR Notation |
|--------------------|---------------|
| 255.255.255.128    | /25           |
| 255.255.255.192    | /26           |
| 255.255.255.224    | /27           |
| 255.255.255.240    | /28           |
| 255.255.255.248    | /29           |
| 255.255.255.252    | /30           |
| 255.255.255.254    | /31           |
| 255.255.255.255    | /32           |

### Subnetting Trick
**Subnet:** `192.168.1.192/26`

#### Binary Breakdown of Last Octet (192)
| Bit Value | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|-----------|-----|----|----|----|---|---|---|---|
| Bit State |  1  |  1 |  0 |  0 | 0 | 0 | 0 | 0 |

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