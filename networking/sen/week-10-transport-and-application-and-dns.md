# Introduction to TCP/IP Transport and Applications
## TCP/IP Transport Layer
| Function                                    | Desription                                                                                                                                                                                   |
|---------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Multiplexing using ports                    | Function that allows receiving hosts to choose the correct application for which the data is destined, based on the port number.                                                             |
| Error recovery (reliability)                | Process of numbering and acknowledging data with Sequence and Acknowledgement header fields.                                                                                                 |
| Flow control using windowing                | Process that uses window sizes to protect buffer spac and routing devices.                                                                                                                   |
| Connection establishment and termination    | Process used to intialize port number and Sequence and Acknowledgement fields                                                                                                                |
| Ordered data transfer and data segmentation | Continuous tream of bytes from an upper-layer process that is "segmented" for transmission and delivered to upper-layer processes at the receiving device, with the bytes in the same order. |

## TCP Header Fields
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.2.png"/>

## Hannah Sending Packets to Jessie with Three Applications
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.3.png"/>

- George needs to know which application to give the data to, but all three packets are from the same Ethernet and IP address. You might think that George could look at whether the packet contains a UDP or TCP header, but as uyou see in the figure, two appliations (wire transfer and web) are using TCP.

- TCP and UDP solve this problem by using a port number field in the TCP or UDP header, respectively. Each of Hannah's TCP and UDP segmetns uses a different destination port number so that George knows which application to give the data to.

- Multiplexing relies on a concept called a socket. A socket consists of three things:
    - An IP address
    - A transport protocol
    - A port number

## Hannah Sending Packets to Jessie with Three Applications Using Port Numbers to Multiplex
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.4.png"/>

- The Internet Assigned Numbers Authority (IANA), the same organization that manages IP address allocation worldwide, subdivides the port number ranges into three main ranges.
    - Well Known (System) Ports: Numbers from 0 to 1023, assigned by IANA, with a stricter review process to assign new ports than user ports.
    - User (Registered) Ports: Numbers from 1024 to 49151, assigned by IANA with a less strict process to assign new ports compared to well-known ports.
    - Ephemeral (Dynamic, Private) Ports: Numbers from 49152 to 65535, no assigned and intended to be dynamically allocated and used temporarily for a client application while the app is running.

## Connections Between Sockets
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.5.png"/>

## Popular Applications and Their Well-Known Port Numbers
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.6.png"/>
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.7.png"/>

## TCP Connection Establishment
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.8.png"/>

## TCP Connection Termination
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.9.png"/>

- TCP establishes and terminates connections between the endpoints, whereas UDP does not. These concepts are so called: connection-oriented and connectionless
    - Connection-oriented protocol: A protocol that requires an exchange of messages before data transfer begins, or that has a required pre-established correlation between two endpoints
    - Connectionless protocol: A protocol that does not require an exchange of messages and that does not require a pre-established correlation between two endpoints.

## TCP Acknowledgement Without Errors
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.10.png"/>

## TCP Acknowledgement With Errors
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.11.png"/>

## TCP Windowing
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.12.png"/>

- TCP implements flow control by using a window concept that is applied to the amount of data that can be outstanding and awaiting acknowledgement at any one point in time. The window concept lets the receiving host tell the sender how much data it can receive right now, giving the receiving host a way to make the sending host slow down or speed up.

- The receiver can slide the window size up and dow - called a sliding windown or dynamic window - to change how much data the sending host can send.

## UDP Header
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.13.png"/>

## Structure of a URI Used to Retrieve a Web Page
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.14.png"/>

## DNS Resolution and Requesting a Web Page
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.15.png"/>

## Recursive DNS Lookup
<img src="https://github.com/matoanbach/networking/blob/main/pics/w10.16.png"/>

## Multiple HTTP Get Requests/Responses

## Dilemma: How Host A Chooses the App That Should Receive This Data

## Three Key Fields with Which to Identify the Next Header