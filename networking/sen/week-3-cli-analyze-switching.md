# Using the Command-Line Interface
## Cisco 2960-XR Catalyst Switch Series

## CLI Access Points

## Console Connection to a Switch

## A Part of a 2960-XR Switch with Console Ports Shown

## Terminal Settings for Console Access

## User and Enable (Privileged) Modes

## Example of Privileged Mode Commnads Being Rejeted in User Mode

## Nondefault Basic Configuration

## Cisco IOS Softare Command Help

## Key Sequences for Command Edit and Recall

## Nondefault Basic Configuration

## CLI Configuration Mode Versus Exec Modes

## Navigating Between Different Configuration Modes

## Command Switch Configuration Modes

## Navigation In and Out of Switch Configuration Modes

## Cisco Switch Memory Types
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.6.png"/>

## Two Main Cisco IOS Configuration Files
| Configuration  | Purpose                                                                                                                          | Where it is stored |
|----------------|----------------------------------------------------------------------------------------------------------------------------------|--------------------|
| startup-config | Stores the initial configuration used anytime the switch reloads Cisco IOS.                                                      | NVRAM              |
| running-config | Store the currently used configuration commands. The file changes dynamically when someone enters commands in configuration mode | RAM                |

## How Configuration Mode Commands Change the Running-Config File, Not the Startup-Config File
```
write memory
copy running-config start-config
```

- Get rid of all existing configuration and start over with a clean configuration:
```bash
write erase
erase startup-config
erase nvram
```

# Analyzing Ethernet LAN Switching
## Campus LAN and Data Center LAN - Conceptual Drawing
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.7.png"/>

## IEEE 802.3 Ethernet Frame (One Variation)
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.8.png"/>

- The role of a LAN switch is to forward Ethernet frames to the correct destionation (MAC) address.
- LAN switches receive Ethernet frames and then make a switching decision: either forward the frame out some other ports or ignore the frame.
    1. Deciding when to forward a frame or when to filter (not forward) a frame, based on the destination MAC address.
    2. Preparing to forward frames by learning MAC addresses by examining the source MAC address of each frame received by the switch.
    3. Preparing to forward only one copy of the frame to the destination by creatin a (Layer 2) loop-free environment with other switches by using Spanning Tree Protocol (STP)

## Sample Switch Forwarding and Filtering Decision
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.9.png"/>

## Forwarding Decision with Two Switches
### First Switch
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.10.png"/>

- Figure 5-4 shows the first switching decision in a case in which Fred sends a frame to Wilma, with destination MAC `0200.3333.3333`. The topology has changed versus the previous figure, this time with two switches, and Fred and Wilma connected to two different switches. Basically, the switch receives the first switch's logic, in reaction to Fred sending the original frame. Basically, the switch receives the frame in port F0/1, finds the destination MAC (0200.3333.3333) in the MAC address table, sees the outgoing port of G0/1, so SW1 forwards the frame out its G0/1 port.

### Second Switch
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.11.png"/>

- That same frame next arrives at switch SW2, entering SW2's G0/2 inteface. As shown in Figure 5-5, SW2 uses the same logic steps, but using SW2's table. The MAC table lists the forwarding instructions for that switch only. In this case, switch SW2 forwads the frame out its F0/3 port, based on SW2's MAC address table.

## Switch Learning: Empty Table and Adding Two Entries
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.12.png"/>

- The switch begins with an empty MAC table, as shown in the upper right part of the figure. Then Fred sends his first frame (label "1") to Bareny, so the switch adds an entry for `0200.1111.1111`, Fred's MAC address, associated with interface F0/1.

- Continuing the example, when Barney replies in Step, the switch adds a second entry, this one for `0200.2222.2222`, Fred's MAC address, associated with interface F0/2.

## Switch FLooding: Unknown Unicast, Arrives, Floods out Other Ports
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.13.png"/>

- When there is no matching entry in the table, switches forward the frame out all interfaces (except the incoming interface) using a process called `flooding`. And the frame whose destination address is unknown to the switch is called an unknown unicast frame, or simply an unknown unicast.


## Network with Redundant Links But Without STP: The Frame Loops Forever
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.14.png"/>

- A topology like Figure 5-8, with redundant links, is good, but we need to prevent the bad effect of those looping frames. To avoid Layer 2 loops, all switches need to use STP. It causes each interface on a switch to settle into either a `blocking` state or `forwarding` state. `Blocking` means that the interface cannot forward or receive data frame, while `forwarding` means that the interface can send and receive data frame. If a correct subset of the interfaces is blocked, only a single currently active logical path exists between each pair of LANs.

## `show mac address-table dynamic` on Switch SW1
- To see a switch's MAC address table, use the `show mac address-table dynamic`.
- To see all the dynamically learned MAC addresses only, instead use the `show mac address-table dynamic` command.


## Single Switch Topolgy Used in Verification Section
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.13.png"/>


## `show interfaces status` on Switch SW1
- `show interfaces status` to check the status of the interfaces, once you do the installation and connect to the Console.

## `show interfaces f0/1 counters` on Switch SW1
- `counters` option lists statistics about incoming and outgoing frames on the interfaces. In particular, it lists the number of unicast, multicast, and broadcast frames (both the `in` and `out` directions), and a total byte count for those frames. Example 5-3 shows an example, again for interface `F0/1`

## `show mac address-table dynamic` with the `address` keyword
- If you know the MAC address, you can search for it - just type in the MAC address at the end of the command.

## `show mac address-table dynamic` with the `interface` keyword
- Sometimes you might be troubleshooting while looking at a network topology diagram and want to take at all the MAC addresses learned off a particular port. IOS supplies that option with the `show mac address-table dynamic interface` command. 

## `show mac address-table vlan` command
- The command is used to find the MAC address table entries for one VLAN.

## The MAC Address Default Aging Timer Displayed

## Two-Switch Topology Example

## The MAC Address Table on Two Switches
