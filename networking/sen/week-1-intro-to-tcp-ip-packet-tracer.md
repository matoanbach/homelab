# Introduction to TCP/IP Networking
## The Two TCP/IP Networking Models
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.2.png"/>

- The bottom layer focuses on how to transmit bits over each individual link.
- The data-link layer focuses on sending data over one type of physical link: for instance, networks use different data-link protocols for Ethernet LANs versus wireless LANs.
- The network layer focuses on delivering data over the entire path from the original sending computer to the final destination computer.
- The top two layers focus more on the applications that need to send and receive data.

## TCP/IP Architectural Model and Example Protocols
| TCP/IP Architecture Layer | Example Protocols               |
|---------------------------|---------------------------------|
| Application               | HTTP, POP 3, SMTP               |
| Transport                 | TCP, UDP                        |
| Internet                  | IP, ICMP                        |
| Data Link & Physical      | Ethernet, 802.11 (Wi-Fi) TCP/IP |

## HTTP
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.3.png"/>
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.4.png"/>

## TCP/IP Transport Layer
<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.5.png"/>

## Same-Layer and Adjacent-Layer Interaction
<img src="https://github.com/matoanbach/networking/blob/main/pics/w1.2.png"/>

## Postal Service Forwarding (Routing)

## Simple TCP/IP Network

## Basic Routing Example

## Ethernet

## Five Steps of Data encapsulation: TCP/IP
<img src="https://github.com/matoanbach/networking/blob/main/pics/w1.3.png"/>

## Perspective on Encapsulation and `Data`
<img src="https://github.com/matoanbach/networking/blob/main/pics/w1.4.png"/>

## OSI Networking Model

## OSI Reference Model Layer Definitions
- Application Layer: This layer provides an interface between the communications software and any applications that need to communicate outside the computer on which the application resides. It also defines processes for user authentication.
- Presentation Layer: This layer's main purpose is to define and negotiate data formats, such as ASCII text, EBCDIC text, binaray, BCD, and JPEG. Encryption is also defined by OSI as a presentation layer service.
- Session Layer: This layer defines how to start, control, and end conversations (called sessions). This includes the control and management of multiple bidirectional messages so that the application can be notified if only some of a series of messages are completed. This allows the presentation layer to have a seamless view of an incoming stream of data.
- Transport Layer: This layer's protocols provide a large number of servies. Although OSI layers 5 through 7 focus on issues related to the application, Layer 4 focuses on issues related to data delivery to another computer (for instance, error recovery and flow control.)
- Network Layer: This layer defines three main features: logical addressing, routing (forwarding), and path determination. Routing defines how devices (typically routers) forward packets to their destination. Logical addressing defines how each device can have an address that can be used by the routing process. Path determination refers to the work done by routing protocols to learn all possible routes, and choose the best route.
- Data Link Layer: This layer defines the rules that determine when a device can send data over a particular medium. Data link protocols also define the format of a header and trailer that allows devices attached to the medium to successfully send and receive data.
- Physical Layer: This layer typically refers to standards from other organizations. These standards deal with the physical characteristics of the transmission medium, including connectors, pins, use of pins, electrical currents, encoding, light modulation, and the rules for how to activate and deactivate the use of the physical medium.

## OSI Reference Model Example Devices and Protocols
| Layer Name                                      | Protocols and Specifications              | Devices                                                   |
|-------------------------------------------------|-------------------------------------------|-----------------------------------------------------------|
| Application, Presentation, Session (Layers 5-7) | Telnet, HTTP, FTP, SMTP, POP3, VoIP, SNMP | Hosts, firewalls                                          |
| Transport (Layer 4)                             | TCP, UDP                                  | Hosts, firewalls                                          |
| Network (Layer 3)                               | IP                                        | Router                                                    |
| Data Link (Layer 2)                             | Ethernet (IEEE 802.3), HDLC               | LAN switch, wireless access point, cable modem, DSL modem |
| Physical (Layer 1)                              | RJ-45, Ethernet (IEEE 802.e)              | LAN hub, LAN repeater, cables                             |


## OSI Encapsulation and Protocol Data Units
<img src="https://github.com/matoanbach/networking/blob/main/pics/w1.5.png"/>