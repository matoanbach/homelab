# Implementing Ethernet Virtual LANs

## Creating Two Broadcast Domains with Two Physical Switches and No VLANs

<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.1.png"/>

- To create two different LAN broadcast domains, you had to buy two different Ethernet LAN switches, as shown in Figure 8-1.

- By using two VLANs, a single switch can accomplish the same goals of the design in Figure 8-1 - to create two broadcast domains - with a single switch. With VLANs, a switch can configure some interfaces into one broadcast domain and some into another, creating multiple broadcast domains. These individual broadcast domains create by the switch are called virtual LANs (VLAN).

## Creating Two Broadcast Domains Using One Switch and VLANs

<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.2.png"/>

- For example, in Figure 8-2, the single switch creates two VLANs, treating the ports in each VLAN as being completely separate. The switch would never forward a frame sent by Dino (in VLAN 1) over to either Wilma or Betty (in VLAN 2).

## Multiswitch VLAN Without VLAN Trunking
<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.3.png"/>

- Figure 8-3 shows an example that demonstrates VLANs that exist on multiple switches, but it does not use trunking. First, the design uses two VLANs: VLAN 10 and VLAN 20. Each switch has two ports assigned to each VLAN exists in both switches. To forward traffic in VLAN 10 between the two switches, the desing includes a link between switches, with that link fully inside VLAN 10. Likewise, to support VLAN 20 traffic between switches, the design uses a second link between switches, with that link inside VLAN 20.

- The design works, but it does not scale very well. It requires one physical link between switches to support very VLAN. If a design needed 10 or 20 VLANs, you would need 10 or 20 links between switches, and you would use 10 or 20 switch ports (one each switch) for those links.

## Multiswitch VLAN with Trunking
<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.4.png"/>

- The use of trunking allows switches to forward frames from multiple VLANs over a single physical connection by adding a smaller header to the Ethernet frame.

## VLAN Trunking Between Two Switches

<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.5.png"/>

- Figure 8-5 shows PC11 sending a broadcast frame on interface Fa0/1 at Step. To flood the frame, switch SW1 needs to forward the broadcast frame to switch SW2. However, SW1 needs to let SW2 know that the frame is part of VLAN 10, so that after the frame is received, SW2 will flood the frame only into VLAN 10, and not into VLAN 20. So, as shown at Step 2, before sending the frame, SW1 adds a VLAN header to the original Ethernet frame, with the VLAN header listing a VLAN ID of 10 in this case.

- When SW2 receives the frame, it understands that the frame is in VLAN 10. SW2 then removes the VLAN header, forwarding the original frame out its interface in VLAN 10 (Step 3).

## 802.1Q Trunking

<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.6.png"/>

- 802.1Q also definesa one specifal VLAN ID on each trunk as the native VLAN (defaulting to use VLAN 1). Note that both switches must agree on which VLAN is the native VLAN.

- The 802.1Q native VLAN provides some interesting functions, mainly to support connections to devices that do not understand trunking.

## Layer 2 Switch Does Not Route Between the VLANs

<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.7.png"/>


## Routing Between Two VLANs on Two Physical Interfaces
<img src="https://github.com/matoanbach/networking/blob/main/pics/w4.8.png"/>

## Network with One Switch and Three VLANs

## Configuring VLANs and Assigning VLANs to Interfaces

## Shorter VLAN Configuration Example (VLAN 3)

## Trunking Adminstrative Mode Options with the `switchport mode` Command

| Command Option    | Description                                                                                                                         |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| access            | Always act as an access (nontrunk) port                                                                                             |
| trunk             | Always act as a trunk port                                                                                                          |
| dynamic desirable | Initiates negotiation messages and responds to negotiation messages to dynamically choose whether to start using trunking           |
| dynamic auto      | Passively waits to receive trunk negotiation messages, at which point the switch will respond and negotiate whether to use trunking |

## Network with Two Switches and Three VLANs

## Initial (Default) State: Not Trunking Between SW1 and SW2

## SW1 Changes from Dynamoc Auto to Dynamic Desirable

## Expected Trunking Operational Mode Based on the Configured Administrative Modes

## Before IP Telephony: PC and Phone, One Cable Each, Connect to Two Different Devices


## Cabling with an IP Phone, a Single Cable, and an Integrated Switch

## A LAN Design, with Data in VLAN 10 and Phones in VLAN 11


## Configuring the Voice and Data VLAN on a ports connected to Phones

## Verifying the Data VLAN (Access VLAN) and Voice VLAN

## Allowed VLAN List and the List of Active VLANs

## Enabling and Disabling VLANs on a Switch

## Operational Trunking State

## Mismatched Trunking Operational States