# Fundamentals of Wireless Networks and Securing Wireless Networks
## Wireless LAN Topologies
- Unidirectional Communication: The transmitter can contact the receiver at any and all times
- Bidirectional Communication: data should travel in both directions. 

## Basic Service Set
- A basic service set (BSS) is when we make every wireless service area a closed group of mobile devices that forms around a fix device; before a device can participate, it must advertise its capabilities and then be granted permission to join.
<img src="https://github.com/matoanbach/networking/blob/main/pics/w9.1.png"/>

- The centre of every BSS is a wireless access point (AP). It operates in infrastructure mode, which means it offers the services that are necessary to form the infrastructure of a wireless network.
- Basic Service Area (BSA) is where the BSS is bounded by the area where the AP's signal is usable.
- BSSID is a unique BSS identifier that is based on the AP's own radio MAC address.
- SSID as a nonunique and human-readable name tag that identifies the wireless service.

## Distribution System
## Extended Service Set
- ESS is when APs are placed at different geographic locations, they can be interconnected by a switched infrastructure. 
- The idea is to make multiple APS cooperate so that the wireless service is consistent and seamless from the client's perspective.
- Each cell has a unique BSSID, both cells share one common SSID. Regardless of a client's location within the ESS, the SSID will remain the same but the client can always distinguish one AP from another.

## Independent Basic Service Set
- IBSS stands for `independent basic service set`. This 802.11 standard allows two or more wireless clients to communicate directly with each other, with no other means of network connectivity. 

## Repeater
- A repeater mode is when an AP device takes the signal it receives and repeats or retransmits it in a new cell area around the repeater. The idea is to move the repeater out away from the AP so that it is still within range of both the AP and the distant clients.

## Workgroup Bridge
- Workgroup Bridge (WGP) is used to connect the device's wired network adapter to a wireless network.
- You might encounter two types of workgroup bridges:
    - Universal workgroup bridge (uWGB): A single wired device can be bridged to a wireless network.
    - Workgroup bridge (WGB): A Cisco-proprietary implemenatation that allows multiple wired devices to be bridged to a wireless network.

## Outdoor bridged links
- They are commonly used for connectivity between buildings or between cities.

## Mesh Network
- To provide wireless coverage over a very large area, it is not always practical to run Ethernet cabling to every AP that would be needed. Instead, you could use multiple APs configured in mesh mode. In a mesh topology, wireless traffic is bridged from AP to AP, in a daisy-chain fashion, using another wireless channel.

## APs and Wireless Standards
| Admendment  | 2.4 GHz | 5 GHz | Max Data Rate | Notes                                                                                                           |
|-------------|---------|-------|---------------|-----------------------------------------------------------------------------------------------------------------|
| 802.11-1997 | Yes     | No    | 2 Mbps        | The original 802.11 standard ratified in 1997                                                                   |
| 802.11b     | Yes     | No    | 11 Mbps       | Introduced in 1999                                                                                              |
| 802.11g     | Yes     | No    | 54 Mbps       | Introduced in 2003                                                                                              |
| 802.11a     | Yes     | No    | 54 Mbps       | Introduced in 1999                                                                                              |
| 802.11n     | No      | Yes   | 600 Mbps      | HT (high throughput), introduced 2009                                                                           |
| 802.11ac    | No      | Yes   | 6.93 Gbps     | VHT (very high throughput), introduced 2013                                                                     |
| 802.11ax    | Yes     | Yes   | 4x 802.11ac   | High Efficiency Wireless, Wi-Fi6; expected late 2019; will operate on other bands too, as they become available |

# Securing Wireless Networks
## Wireless Client Authentication Methods
### Open Authentication
- Open authentication is true to its name; it offers open access to a WLAN.
- The only requirement is that a client must use an 802.11 authentication request before it attempts to associate with an AP. No other credentials are needed.

### WEP
- WEP uses the RC4 cipher algorithm to make every wireless data frame private and hidden from eavesdroppers.
- The algorithm uses a string of bits as a key, commonly called a WEP key, to derive other encryption keys - one per wireless frame.
- WEP is known as a shared-key security method.

### 802.1x Client Authentication Roles
1. LEAP (Lightweight EAP) - using username and PW credentials
2. EAP-FAST (Flexible Authentication by Secure Tunneling) - Using PAC and TLS. PAC (Protected Access Credential - shared secret) and TLS (Transport Layer Security Tunnel)
    - Phase 1: The PAC is generated or provisioned and installed on the client.
    - Phase 2: After the supplicant and AS have authenticated each other, they negotiate a Transport Layer Security (TLS) tunnel.
    - Phase 3: The end user can then be authenticated through the TLS tunnel for additional security.

3. PEAP (Protected EAP) - AS uses digital certificate with Certificate Authority, CA
4. EAP - TLS (One step more, it uses CA on both sides, on the AS and on the Client device) 
    - PEAP leverages a digital certificate on the AS as a robust method to authenticate the RADIUS server. It is easy to obtain and install a certificate on a single server, but the clients are left to identify themselves through other means. EAP Transport Layer Security (EAP - TLS) goes on step further by requiring certificates on the AS and on every client device.
    - With EAP-TLS, the AS and the supplicant exchange certificates and can authenticate each other. A TLS tunnel is built afterward so that encryption key material can be securely exchanged.
    - EAP-TLS is the most secure wireless authentication method available; however, implementing it can sometimes be complex. Along with the AS, each wireless client must obtain and install a certificate. This can be automated by implementing a Public Key Infrastructure (PKI) that could supply certificates securely and efficiently and revoke them when a client or user should no longer have access to the networ that could supply certificates securely and efficiently and revoke them when a client or user should no longer have access to the network.

## Wireless Privacy and Integrity Methods
### WEP
- Wired Equivalent Privacy (deprecated in 2004) replaced by 802.11i admendment (WPA frameword was introduced).

### TKIP
- Temporal Key Integrity Protocol (deprecated in 2012)
- TKIP addes the following security feature using legacy hardware and the underlying WEP encryptions:
    - MIC: This efficient algorithm adds a hash value to each frame as a message integrity check to prevent tampering; commonly called `Michael` as n informal reference to MIC.
    - Time stamp: A time stamp is added into the MIC to prevent replay attacks that attemp to reuse or replay frames that have already been sent.
    - Sender's MAC address: The MIC includes the sender's MAC address as evidence of the frame source.
    - TKIP sequence counter: This feature provides a record of frames sent by a unique MAC address, to prevent frames from being replayed as an attack.
    - Key mixing algorithm: This algorithm computes a unique 128-bit WEP key for each frame.
    - Longer initialization vector (IV): The IV size is doubled from 24 to 48 bits, making it virtually impossible to exhaust all WEP keys by brute-force calculation.

### CCMP
- The Counter/CBC-MAC Protocol (CCMP) is considered to be more secure than TKIP. CCMP consists of two algorithms:
    - AES counter mode encryption
    - Ciper Block Chaining Message Authentication Code (CBC-MAC) used as a message integrity check (MIC)
- The Advanced Encryption Standard (AES) is the current encryption algorithm adopted by U.S National Institute of Standards and Technology (NIST) and the U.S government, and widely used around the world.
- AES is open, publicly accessible, and represents the most secure encryption method available today.
- Before CCMP can be used to secure a wireless network, the client devices and APs must support the AES counter mode and CBC-MAC in hardware.

### GCMP
- The Galois/Counter Mode Protocol (GCMP) is a rebust authenticated encryption suite that is more secure and more efficient than CCMP. GCMP consists of two algorithms:
- AES counter mode encryption.
- Galois Message Authentication Code (GMAC) used as a message integrity check (MIC)
- GCMP is used in WPA3

### WPA, WPA2, and WPA3
- Now, a variety of authentication methods and encryption and message integrity algorithms are available. When it comes tome to configure a WLAN with wireless security, which scheme is the best?
- The Wi-Fi Alliance, a nonprofit wireless industry association, has worked out straightforward ways to do that throught its Wi-Fi Protected Access (WPA) industry certifications. To date, there are three different versions: WPA, WPA2, and WPA3.
- WPA was based on parts of 802.11i and included 802.1x authentication, TKIP, and a method for dynamic ecryption key management.
- Once 802.11i was ratified and published, the Wi-Fi Alliance included it in full in its WPA Version 2 (WPA2) certification. WPA2 is based around the superior AES CCMP algorithms, rather than the deprecated TKIP from WPA.
- In 2018, the Wi-Fi Alliance introduced WPA Version 3 (WPA3) as a future replacement for WPA2, adding several important and superior security mechanisms.
- WPA3 leverages strong encryption by AES with GCMP. It also uses Protected Management Frames (PMF) to secure important 802.11 management frames between APs and clients, to prevent malicious acitivity that might spoof or tamper with a BSS's operation.

### Comparing WPA, WPA2, and WPA3
| Authentication and Encryption Feature Support | WPA | WPA2 | WPA3 |
|-----------------------------------------------|-----|------|------|
| Authentication with Pre-Shared Keys?          | Yes | Yes  | Yes  |
| Authentication with 802.1x?                   | Yes | Yes  | Yes  |
| Encryption and MIC with TKIP?                 | Yes | No   | No   |
| Encryption and MIC with CCMP                  | Yes | Yes  | No   |
| Encryption and MIC with GCMP                  | No  | No   | Yes  |