# Operating Cisco Routers
## Interface Status Codes
| Name            | Location           | General Meaning                                                                                                                                                                                            |
|-----------------|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Line Status     | First status code  | Refers to the Layer 1 status. (For example, is the cable installed, is it right/wrong cable, is the device on the other end powered on?)                                                                   |
| Protocol Status | Second status code | Refers generally to the Layer 2 status. It is always down if the line status is down. If the line status is up, a protocol status of down is usually caused by a mismatched data-link layer configuration. |

## Typical Combinations of Interface Status Codes
| Line Status           | Protocol Status | Typical Reasons                                                                                                                                                                                                                                                                                                             |
|-----------------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Administratively down | Down            | The interface has a shutdown command configured on it.                                                                                                                                                                                                                                                                      |
| Down                  | Down            | The interface is not shutdown, but the physical layer has a problem. For example, no cable has been attached to the interface, or with Ethernet, the switch interface on the other end of the cable is shut down, or the switch is powered off, or the devices on the ends of the cable use a different transmission speed. |
| Up                    | Down            | Almost always refers to data-link layer problems, most often configuration problems. For example, serial links have this combination when one router was configured to use PPP and the other defaults to use HDLC.                                                                                                          |
| Up                    | Up              | Layer 1 and Layer 2 of this interface are functioning.                                                                                                                                                                                                                                                                      |

## Configuring IP Addresses on Cisco Routers

<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.1.png"/>

```bash
configure terminal
interface G0/0
ip address 172.16.1.1 255.255.255.0
no shutdown

interface S0/0/0
ip address 172.16.4.1 255.255.255.0
no shutdown

interface G0/1/0
ip address 172.16.5.1 255.255.255.0
no shutdown
```

## Verify IP Addresses on Cisco Routers
- run `show protocols`
- This command confirms the state of each of the three R1 interfaces and the IP address and masl configured on those same interfaces.

## Key commands to list router interface status
| Command                       | Lines of Output per Interface | IP Configuration Listed | Interface Status Listed |
|-------------------------------|-------------------------------|-------------------------|-------------------------|
| show ip interface brief       | 1                             | Address                 | Yes                     |
| show protocols [type nmuber]  | 1 or 2                        | Address/mask            | Yes                     |
| show interfaces [type number] | Many                          | Address/mask            | Yes                     |


# Configuring IPv4 Addresses and Static Routes
## IPv4 Routing Process Reference
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.2.png"/>

- Step 1: If the destination is local, send directly:
    - Find the destination host's MAC address. Use the already-know Address Resolution Protocol (ARP) table entry, or use ARP messages to learn the information.
    - Encapsulate the IP packet in a data-link frame, with the destination data-link address of the destination host.
- Step 2: If the destination is not local, send to the default gateway:
    - Find the default gateway's MAC address. Use the already-known Address Resolution Protocol (ARP) table entry, or use ARP messages to learn the information.
    - Encapsulate the IP packet in a data-link frame, with the destination data-link address of the default gateway.

## Router Routing Logic Summary
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.3.png"/>

1. R1 notes that the received Ethernet frame passes the FCS check and that the destination Ethernet MAC address is R1's MAC address, so R1 processes the frame.
2. R1 de-encapsulates the IP packet from inside the Ethernet frame's header and trailer.
3. R1 compares the IP packet's destination IP address to R1's IP routing table.
4. R1 encapsulates the IP packet inside a new data-link frame, in this case, inside a High-Level Data Link Control (HDLC) header and trailer
5. R1 transmits the IP packet, inside the new HDLC frame, out the serial link on the right.

## Routing
### Step 1: Decide whether to process the incoming frame
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.4.png"/>

- Host A sends a frame destined for R1's MAC address. So, after the frame is received, and after R1 confirms with the FCS that no error occurred, R1 confirms that the frame is destined for R1's MAC address (0200.0101.0101 in this case). All checks have been passed, so R1 will process the frame. 

### Step 2: De-encapsulation of the IP Packet
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.5.png"/>

- After the router know that it has to process the received frame, the next step is relatively simple: de-encapsulating the packet. In router memory, the router no longer needs the original frame's data-link header and trailer, so the router removes and discards them, leaving the IP packet. Note that the IP address remains unchanged (172.16.2.9).

### Step 3: Choosing where to forward the packet
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.6.png"/>


### Step 4: Encapsulating the packet in a new frame
<img src="https://github.com/matoanbach/networking/blob/main/pics/w6.7.png"/>

### Step 5: Transmitting the Frame

- After the frame has been prepared, the router simply needs to transmit the frame. The router might have to wait, particularly if other frames are already waiting their turn to exit the interface.


## Connected and Local Routes on a Router
- Connected routes: Added because of the configuration of the `ip address` interfcace subcommand on the local router

- Local routes: defined as a route for one specific IP address configured on the router interface.