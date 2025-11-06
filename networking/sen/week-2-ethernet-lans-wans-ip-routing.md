# Fundamentals of Ethernet LANs
## SOHO LAN
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.4.png"/>

- The LAN needs a device called an Ethernet LAN switch, which provides many physical ports into which cables can be connected. The LAN uses Ethernet cables to connect different Ethernet devices or nodes to one of the switch's Ethernet ports.

- The router connects the LAN to the WAN, in this case to the Internet.

## Small Wired and Wireless SOHO LAN
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.5.png"/>

## Typical Enterprise LANs - Single-Building Enterprise Wired and Wireless LAN
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.6.png"/>

- Figure 2-3 shows a conceptual view of a typical enterprise LAN in a three-story building. Each floor has an Ethernet LAN switch and a wireless LAN AP. To allow communication between floors, each per-floor switch connects to one centralized distribution switch. For example, PC3 can send data to PC2, but it would first flow through switch SW3 to the first floor to the distribution switch (SWD) and then back up through switch SW2 on the second floor.
- The figure also shows the typical way to connect to LAN to a WAN using a router. LAN switches and wireless access points work to create the LAN itself. Routers connect to both the LAN and the WAN. To connect to the LAN, the router simply uses an Ethernet LAN interface and an Ethernet cable, as shown on the lower right of Figure 2-3.

## Types of Ethernet
| Speed     | Common Name      | Informal IEEE Standard Name | Formal IEEE Standard Name | Cable Type, Maximum Length |
|-----------|------------------|-----------------------------|---------------------------|----------------------------|
| 10 Mbps   | Ethernet         | 10BASE-T                    | 802.3                     | Copper, 100m               |
| 100 Mbps  | Fast Ethernet    | 100BASE-T                   | 802.3u                    | Copper, 100m               |
| 1000 Mbps | Gigabit Ethernet | 1000BASE-LX                 | 802.3z                    | Fibre, 5000m               |
| 1000 Mbps | Gigabit Ethernet | 1000BASE-T                  | 802.ab                    | Copper, 100m               |
| 10 Gbps   | 10 Gig Ethernet  | 10GBASE-T                   | 802.3an                   | Copper, 100m               |

## Ethernet LAN Forwards a Data Link Frame over many types of Links
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.7.png"/>

## Creating One Electrical Circuit over one pair to send in one direction
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.8.png"/>

## Basic Components of an Ethernet Link
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.9.png"/>

- The 10BASE-T and 100BASE-T standards require two pairs of wires, while the 1000BASE-T standard requires four pairs. Each wire has a color-coded plasting coating, with the wires in a pair having a color scheme. For example, for the blue wire pair, one wire's coating is all blue, while the other wire's coating is blue-and-white striped.
- Many Ethernet UTP cables use an RJ-45 connector on both ends. The RJ-45 connector has eight physical locations into which the eight wires in the cable can be inserted, called pin positions, or simply pins. These pins create a place where the ends of the copper wires can touch the electronics inside the nodes at the end of the physical link so that electricity can flow.

## RJ-45 Connectors and Ports
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.10.png"/>

## 10-Gbps SFP+ with cable sitting just outside a catalyst 3560CX switch

## Using one pair for each transmission direction with 10- and 100-Mbps ethernet
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.11.png"/>

## 10Base-T and 100Base-T Straight-Through Cable Pinout
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.12.png"/>

## Ethernet Straight-Through Cable concept
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.13.png"/>

## Crossover Ethernet Cable
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.14.png"/>

## Typical Uses for straight-through and crossover ethernet cables
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.15.png"/>

## Four-Pair straight-throigh cable to 1000BASE-T
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.16.png"/>

## Components of a Fiber-Optic cable
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.17.png"/>

## Transmission on multimode fiber with internal reflection
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.18.png"/>

## Transmission on single-mode fiber with laser transmitter
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.19.png"/>

## Two fiber cables with Tx connected to Rx on each cable
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.20.png"/>

## A Sampling of IEEE 802.3 10-Gbps fiber standards
| Standard    | Cable Type | Max Distance |
|-------------|------------|--------------|
| 10GBASE-S   | MM         | 400m         |
| 10GBASE-LX4 | MM         | 300m         |
| 10GBASE-LR  | SM         | 10km         |
| 10GBASE-E   | SM         | 30km         |

## Comparisons between UTP, MM, and SM Ethernet cabling
| Criteria                                      | UTP  | Multimode | Single-Mode |
|-----------------------------------------------|------|-----------|-------------|
| Relative Cost of Cabling                      | Low  | Medium    | Medium      |
| Relativev Cost of a Switch Port               | Low  | Medium    | High        |
| Approximate Max Distance                      | 100m | 500m      | 40km        |
| Relative Susceptibility to Interference       | Some | None      | None        |
| Relative Risk of Copying from Cable Emissions | Some | None      | None        |

## Commonly used ethernet frame format

```txt
     Header
Bytes|Preamble - 7|SFD - 1|Destination - 6|Source - 6|Type - 2|Data - 46 -> 1500|FCS - 4|
```
| Field       | Bytes     | Description                                                                                                                                                                    |
|-------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|             |           |                                                                                                                                                                                |
| Preamle     | 7         | Synchronization                                                                                                                                                                |
| SFD         | 1         | Signifies that the next byte begins                                                                                                                                            |
| Destination | 6         | Identifies the intended recipient of this frame.                                                                                                                               |
| Source      | 6         | Identifies the sender of this frame.                                                                                                                                           |
| Type        | 2         | Defines the type pf protocol listed inside the frame; today, most like identifies IP version 4 (IPv4) or IP version 6 (IPv6).                                                  |
| Data        | 46 - 1500 | Holds data from a higher layer, typically an L3PDU (usually an IPv4 or IPv6 packet). The sender adds padding to meet the minimum length requirement for this field (46 bytes). |
| FCS         | 4         | Provides a method for the receiving NIC to determine whether the frame experienced transmission errors.                                                                        |

## Structure of unicast ethernet addresses
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.21.png"/>

## Use of ethernet type field
| LAN Addressing Term or Feature             | Description                                                                                                       |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| MAC                                        | Media Access Control 802.3 (Ether) defines the MAC sublayer of IEEE ethernet.                                     |
| Ethernet address, NIC address, LAN address | Other names often used instead of MAC address. These terms describe the 6-byte address of the LAN interface card. |
| Burned-in address                          | The 6-byte address assigned by the vendor making the card                                                         |
| Unicast address                            | A term for a MAC address that represents a single LAN interface.                                                  |
| Multicast address                          | On Ethernet, a multicast address implies some subnet of all devices currently on the Ethernet LAN.                |

<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.22.png"/>

- A host can send one Ethernet frame with an IPv4 packet and the next Ethernet frame with an IPv6 packet. Each frame would have a different Ethernet Type field value, using the values reserved by the IEEE, as shown in Figure 2-21.

## Example of sending data in a modern ethernet LAN
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.23.png"/>

- Following the steps in the figure:
1. PC1 builds and sends the original Ethernet frame, using its own MAC address as the source address and PC2's MAC address as the destination address.
2. Switch SW1 receives and forwards the Ethernet frame out its G0/1 interface (short for Gigabit interface 0/1) to SW2.
3. Switch SW2 receives and forwards the Ethernet frame out its F0/2 interface (short for Fast Ethernet interface 0/2) to PC2.
4. PC2 receives the frame, recognizes the destination MAC address as its own, and processes the frame.

## A collision occurring because of LAN Hub behavior
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.24.png"/>

- The downside of using LAN hubs is that if two or more devices transmitted a signal at the same instant, the electrical signal collides and becomes garbled. The hub repeats all received electrical signals, even if it receives multiple signals at the same time. For example, Figure 2-23 shows the idea, with PCs Archie and Bob sending an electrical signal at the same instant of time (at step 1A and 1B) and the hub repeating both electrical signals out toward Larry on the left (Step 2).

## Full and Half Duplex in an ethernet LANs
<img src="https://github.com/matoanbach/networking/blob/main/pics/w2.25.png"/>

- Algorithm to avoid collision is called `Carrier sense multiple access with collision detection` (CSMA/CD).
1. A device with a frame to send listens until the Ethernet is not busy
2. When the Ethernet is not busy, the sender begins the frame.
3. The sender listens while sending to discover whether a collision occurs; collisions might be caused by many reasons, including unfornate timing. If a collision occurs, all currently sending nodes do the following:
     - They send a jamming singal that tells all nodes that a collison happened.
     - They independently choose a random time to wait before trying again, to avoid unfortunate timing.
     - The next attemp starts again at Step 1.
