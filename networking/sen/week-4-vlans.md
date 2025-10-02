## VLAN 
- They are configured on switches on a `per-interface` basis.
- They are logically separate end hosts at Layer 2.
- Switches do not forward traffic directly between hosts in different VLANs.

### VLAN Configuration
- VLAN 1, 1000-1005 exist by default and cannot be deleted.
- An access port is a switchport which belongs to a single LAN, and usually connects to end hosts like PCs.
- Switchports which carry multiple VLANs are called `trunked ports`.

## Trunk Ports
- In a small network with few VLANs, it is possible to use separate interfeace for each VLAN when connecting switches to switches, and switches to routers.
- However, when the number of VLANs increases, this is not viable. It will result in wasted interfaces, and often routers won't have enough interfaces for each VLAN.
- You can use `trunk ports` to carry traffic from multiple VLANs over a single interface.
- Switches will tag all frames that they send over a trunk link. This allows the receiving switch to know which VLAN the frame belongs to.
- Trunk ports = `tagged` ports
- Access ports = `untagged` ports

## VLAN Tagging
- There are two main trunking protocols: ISL (Inter-Switch Link) and IEEE 802.1Q (so-called dot1q).
- ISL is an old Cisco proprietary protocol created before the industry standard IEEE 802.1Q.
- IEEE 802.1Q is an industry standard protocol created by the IEEE (Institute of Electrical and Electronics Engineers).
- You will probably NEVER use ISL in the real world. Even modern Cisco equipment doesn't support it. FOr the CCNA, you only need to learn 802.1Q.

## 802.1Q Tag
- The 802.1Q tag is inserted between the `Source` and `Type/Length` fields of the Ethernet frame.
- The tag is 4 bytes (32 bits) in length.
- The tag consists of two main fields:
    - Tag Protocol Identifier (TPID)
    - Tag Control Information (TCI)
- The TCi consists of three sub-fields

### 802.1Q Tag - TPID (Tag Protocol Identifier)
- 16 bits (2 bytes) in length
- Always set to a value of `0x8100`. This indicates that the frame is 802.1Q-tagged.

### 802.1Q Tag - PCP (Priority Code Point)
- 3 bits in length
- USed for Class of Service (CoS), which prioritizes important traffic in congested networks.

### 802.1Q Tag - DEI (Drop Eligible Indicator)
- 1 bit in length
- Used to indicate frames that can be dropped if the network is congested.

### 802.1Q Tag - VID (VLAN Id)
- 12 bits in length
- Identifies the VLAN the frame belongs to.
- 12 bits in length = 4096 total VLANs (2^12), range of 0 - 4095.
- VLANS 0 and 4095 are reserved and can't be used.
- Therefore, the actual range of VLANs is 1 - 4096.
- Cisco's proprietary ISL also has a VLAN range of 1 - 4094.

### VLAN Ranges
- The range of VLANs (1 - 4094) is divided into two sections:
    - Normal VLANs: 1 - 1005
    - Extended VLANs: 1006 - 4094
- Some older devices cannot use the extended VLAN range, however it's safe to expect that modern switches will support the extended VLAN range.

### Native VLAN
- 802.1Q has a feature called the `native VLAN`.
- The native VLAN is VLAN 1 by default on all trunk ports, however, this can be manually configured on each trunked port.
- The switch does not add an 802.1Q tag to frames in the native VLAN.
- When a switch receives an untagged frame on a trunk port, it assumes the frame belongs to the native VLAN.

## Native VLAN on a router (ROAS)
- There are `2 methods` of configuring the native VLAN on a router:
    - Use the command `encapsulation dot1q [vlan-id] native` on the router subinterface.
    - Configure the IP address for the native VLAN on the router's physical interface (the `encapsulation dot1q [vlan-id]` command in not neccesary.)

### Layer 3 (Multilayer) Switches
- Layer 2 switches
- Layer 3 switches
    - A multiplayer switch is capable of both switching AND routing.
    - It is `Layer 3 aware`.
    - Youc can assign IP addresses to its interfaces, like a router.
    - You can create virtual interfaces for each VLAN, and assign IP addresses to those interfaces.
    - You can configure routes on it, just like a router.
    - It can be used for inter-VLAN routing.

### Inter-VLAN Routing via SVI
- SVI (Switch Virtual Interfaces) are the virtual interfaces you can assign IP addresses to in a multilayer switch.
- Configre each PC to use the SVI (NOT the router) as their gateway address.
- To send traffic to different subnets/VLANs, the PCs will send traffic to the switch, and the switch will route the traffic.

## DTP and VTP
### DTP (Dynamic Trunking Protocol)
- DTP is a Cisco proprietary protocol that allows Cisco switches to dynamically determine their interface status (`access` or `trunk`) without manual configuration.
- DTP is enabled by default on all Cisco switch interfaces.
- So far, we have been manually configuring swichport using these commands:
    - `switchport mode access`
    - `switchport mode trunk`
- For security purposes, manual configuration is recommended. DTP should be disabled on all switchports.
- A switchport in `dyniamc desirable` mode will actively try to form a trunk with other Cisco switches. It will form a trunk if connected to another switchport in the following modes:
    - `switchport mode trunk`
    - `switchport mode dynamic desirable auto`
- A switchport in `dynamic auto` mode will NOT actively try to form a trunk with other Cisco switches, however it will form a trunk if the switch connected to it is actively trying to form a trunk. It will form a trunk with a switchport in the following mode:
    - `switch mode trunk`
    - `switch mode dynamic desirable`

| Administrative Mode   | Trunk | Dynamic Desirable | Access | Dynamic Auto |
|-----------------------|-------|-------------------|--------|--------------|
| **Trunk**             | Trunk | Trunk             | X      | Trunk        |
| **Dynamic Desirable** | Trunk | Trunk             | Access | Trunk        |
| **Access**            | X     | Access            | Access | Access       |
| **Dynamic Auto**      | Trunk | Trunk             | Access | Access       |

- On older switches, `switches mode dynamic desirable` is the default administrative mode.
- On newer switches, `switchport mode dynamoc auto` is the default administrative mode.
- You can disable DTP negotiation on an interfae with this command: `switchport nonegotiate`
- Configuring an access port with `switchport mode access` also disable DTP negotiation on an interface.
- Switches that support both `802.1Q` and `ISL` trunk encapsulations can use DTP to negotiate the encapsulation they will use.
- This negotiation is enabled by default, as the default trunk encapsulation mode is `switchport trunk encapsulation negotiate`
- `ISL` is favored over 802.1Q, so if both switches support ISL it will be selected.
- DTP frames are sent in VLAN1 when using `ISL`, or in the native VLAN when using `802.1Q` (the default native VLAN is VLAN1, however).
### VTP (VLAN Trunking Protocol)
- VTP allows you to configure VLANs on a central VTP server switch, and other switches (VTP clients) will synchronize their VLAN database to the server.
- It is designed for large networks with many VLANs, so that you don't have to configure each VLAN on every switch.
- It is rarely used, and it is recommended that you do not use it.
- There are three VTP versions: 1, 2 and 3.
- There are three VTP modes: `server`, `client` and `transparent`.
- VTP Servers:
    - Can add/modify/delete VLANs.
    - Store the VLAN databse in non-volatile RAM (NVRAM)
    - Will increase the `revision number` every time a VLAN is added/modified/deleted.
    - Will advertise the latest version of the VLAN database on trunk interfaces, and the VTP clients will synchronize their VLAN database to it.
    - VTP servers also functions as VTP clients.
    - Therefore, a VTP server will synchronize to another VTP server with a higher revision number.
- VTP clients:
    - Cannot add/modify/delete VLANs.
    - Do not store the VLAN databse in NVRAM (in VTPv3, they do)
    - Will sync their VLAn database to the server with the highest revision number in their VTP domain.