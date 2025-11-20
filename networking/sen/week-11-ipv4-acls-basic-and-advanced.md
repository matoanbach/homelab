# Basic IPV4 Control Lists

## IPv4 Access Control List Basics

- IPv4 access control lists give network engineers a way to identify different types of packets.
- ACL configuration list values that the router can see in the IP, ICMP, TCP, and UDP (and other) headers.
- IPv4 ACLs perform many functions in Cisco routers, including packet filtering and Quality of Service.

## Locations to Filter Packets from Hosts A and B Going Toward Server S1

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.1.png"/>

- To filter a packet, you must enable an ACL on an interface that processes the packet, in the same direction the packet flows throught that interface.
- When enabled, the router then processes every inbound or outbound IP paclet using that ACL. For example, if enabled on R1 for packets inbound on inteface F0/0, R1 would compare every inbound IP packet on F0/0 to the ACL to decide that packet'fate: to continue unchanged or to be discarded.

## Pseudocode to Demonstrate ACL Command-Matching Logic

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.2.png"/>

- Figure 2-2 shows a two-line ACL in a rectangle at the bottom, with simple matching logic: both statements just look to match the source IP address in the packet. When enabled, R2 looks at every inbound IP packet on that interface and compare each packet to those two ACL commands. Packets sent by host A (source IP address 10.1.1.1) are allowed through, and those sourced by host B (source IP address 10.1.1.2) are discarded.

## Comparison of IP ACL Types

- Cisco has added many ACL features, including the following:
  - Standard numbered ACLs (1-99)
  - Extended numbered ACLs (100-199)
  - Additional ACL numbers (1300-1999 standard, 2000-2699 extended)
  - Named ACLs
  - Improved editing with sequence numbers

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.3.png"/>

## Backdrop for Discussion of List Process with IP ACLs

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.4.png"/>

- Consider the first-match ACL logic for a packet sent by host A to server S1. The source IP address will be `10.1.1.1` and it will be routed so that it enters R2's S0/0/1 interface, driving R2's ACL 1 logic. R2 compares this packet to the ACL, matching the first item in the list with a permit action. So this packet should be allowed through, as shown in Figure 2-5, on the left.

## ACL Items Compared for Packets from Hosts A, B, and C on Previous Slide

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.5.png"/>

## Logic for WC Masks `0.0.0.255`, `0.0.255.255`, and `0.255.255.255`

- <img src="https://github.com/matoanbach/networking/blob/main/pics/w11.6.png"/>

## Syntactically Correct ACL Replaces Pseudocode

- <img src="https://github.com/matoanbach/networking/blob/main/pics/w11.7.png"/>
- Wildcard masks, as dotted-decimal number (DDN) values, actually represent a 32-bit binary number. As a 32-bit number, the WC mask actually direct the router's logic bit by bit. In short, a WC mask bit of 0 means the comparison should be done as normal, but a binary 1 means that the bit is a wildcard and can be ignored when comparing the numbers.

## Binary Wildcard Mask Example

- <img src="https://github.com/matoanbach/networking/blob/main/pics/w11.8.png"/>

- For example, for subnet `172.16.8.0` `255.255.252.0`, use the subnet number (`172.16.8.0`) as the address parameter, and then do the following math to find the wildcard mask:

```bash
access-list 1 permit 172.16.8.0 0.0.3.255
```

## Matching Any/All Addresses

- In some cases, one ACL command can be used to match any and all packets that reach that point in the ACL using the `any` keyword.
- Example: `access-list 1 permit any`
- All cisco IP ACLs end with an implicit `deny any`

## Implementing Standard IP ACLs

```bash
access-list [access-list-numer] {deny | permit} source [source-wildcard]
```

1. Plan th location (router and interface) and direction (in or out) on that interface:
   - Standard ACLs should be placed near to the destination of the packets so that they do not unintentionally discard packets that should not be discarded.
   - Because standard ACLs can only match a packet's source IP address, identify the source IP address of packets as they go in the direction that the ACL is examining.
2. Configure one or more `access-list` global configuration commands to create the ACL, keeping the following in mind:
   - The list is searched sequentically, using first-match logic
   - The default action, if a packet does not match any of the `access-list` commands, is to deny (discard) the packet
3. Enable the ACL on the chosen router interface, in the correct direction, using the `ip access-group [number] {in | out}` interface command

## Standard Numbered ACL Example 1 Configurationes

```bash
config t
access-list 1 permit 10.1.1.1
access-list 1 deny 10.1.1.0 0.0.0.255
access-list 1 permit 10.0.0.0 0.255.255.255
interface s0/0/1
ip access-group 1 in
```

## ACL show Commands on R2

```bash
show ip access-lists
```

## Standard Numbered ACL Example 2

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.9.png"/>

## Creating Log Messages for ACL Statistics

```bash
access-list 2 permit 10.2.2.1 log
```

## Example of Checking the Interface and Direction for an ACL

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.9.png"/>

## Building One-Line Standard ACLs: Practice

| Problem | Criteria                                                    | Solution                                    |
| ------- | ----------------------------------------------------------- | ------------------------------------------- |
| 1       | Packets from 172.16.5.4                                     | access-list 1 permit 172.16.5.4             |
| 2       | Packets from hosts with 192.168.6 as the first three octets | access-list 1 permit 192.168.6.0 0.0.0.255  |
| 3       | Packets from hosts with 192.168 as the first two octets     | access-list 1 permit 192.168.0.0 0.0.0.255  |
| 4       | Packets from any host                                       | access-list 1 permit any                    |
| 5       | Packets from subnet 10.1.200.0/21                           | access-list 1 permit 10.1.200.0 0.0.7.255   |
| 6       | Packets from subnet 10.1.200.0/27                           | access-list 1 permit 10.1.200.0 0.0.0.31    |
| 7       | Packets from subnet 172.20.112.0/23                         | access-list 1 permit 172.20.112.0 0.0.1.255 |
| 8       | Packets from subnet 172.20.112.0/26                         | access-list 1 permit 172.20.112.0 0.0.0.63  |
| 9       | Packets from subnet 192.168.9.64/28                         | access-list 1 permit 192.168.9.64 0.0.0.15  |
| 10      | Packets from subnet 192.168.9.64/30                         | access-list 1 permit 192.168.9.64 0.0.0.3   |

## Reverse Engineering from ACl to Address Range

## Finding IP Addresses/Ranges Matching by Existing ACLs

| Problem | Criteria                                   | Solution       |
| ------- | ------------------------------------------ | -------------- |
| 1       | access-list 1 permit 10.7.6.5              |                |
| 2       | access-list 2 permit 192.168.4.0 0.0.0.127 | 192.168.4.0/25 |
| 3       | access-list 3 permit 192.168.6.0 0.0.0.31  | 192.168.6.0/28 |
| 4       | access-list 4 permit 172.30.96.0 0.0.3.255 | 172.30.96.0/22 |
| 5       | access-list 5 permit 172.30.96.0 0.0.0.63  | 172.30.96.0/26 |
| 6       | access-list 6 permit 10.1.192.0 0.0.0.31   | 10.1.192.0/27  |
| 7       | access-list 7 permit 10.1.192.0 0.0.1.255  | 10.1.192.0/23  |
| 8       | access-list 8 permit 10.1.192.0 0.0.63.255 | 10.1.192.0/19  |

## IOS Changing the Address Field in an `access-list` Command

# Advanced IPv4 Access Control Lists

## IP Header, with Focus on Required Fields in Extended IP ACLs

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.11.png"/>

## Extended ACL Syntax, with Required Fields

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.12.png"/>

## Extended `access-list` commands and logic explanations

| `access-list` statement                             | what it matches                                                                                                     |
| --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `access-list 101 deny tcp any any`                  | Any IP packet that has a TCp header                                                                                 |
| `access-list 101 deny udp any any`                  | Any IP packet that has a UDP header                                                                                 |
| `access-list 101 deny icmp any any`                 | Any IP packet that has an ICMP header                                                                               |
| `access-list 101 deny ip host 1.1.1.1 host 2.2.2.2` | All IP packets from host 1.1.1.1 goint to host 2.2.2.2, regardless of the header after the IP header                |
| `access-list 101 deny udp 1.1.1.0 0.0.0.255 any`    | All IP packets that have a UDP header following the IP header, from subnet 1.1.1.0/24, and going to any destination |

## IP header, Followed by a TCP Header and Port Number Fields

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.13.png"/>

## Extended ACL Syntax with TCP and UDP Port Numbers Enabled

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.14.png"/>

## Filtering Packets Based on Destination Port

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.15.png"/>

- The figure shows the syntax of an ACL that matches the following:
  - Packets that include a TCP header
  - Packets sent from the client subnet
  - Packets sent to the server subnet
  - Packets with TCP destination port 21 (FTP server control port)

## Filtering Packets Based on Source Port

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.16.png"/>

## Popular Applications and Their Well-known port numbers

| Port Number(s) | Protocol | Application       | `access-list` command keyword |
| -------------- | -------- | ----------------- | ----------------------------- |
| 20             | TCP      | FTP Data          | `ftp-data`                    |
| 21             | TCP      | FTP control       | `ftp`                         |
| 22             | TCP      | SSH               | --                            |
| 23             | TCP      | Telnet            | `telnet`                      |
| 25             | TCP      | SMTP              | `smtp`                        |
| 53             | TCP      | DNS               | `domain`                      |
| 67             | UDP      | DHCP Server       | `bootps`                      |
| 68             | UDP      | DHCP Server       | `bootpc`                      |
| 69             | UDP      | TFTP              | tftp                          |
| 80             | TCP      | HTTP (WWW)        | www                           |
| 110            | TCP      | POP3              | pop3                          |
| 161            | UDP      | SNMP              | snmp                          |
| 443            | TCP      | SSL               | --                            |
| 514            | UDP      | Syslog            | --                            |
| 16,384-32,767  | UDP      | RTP(Voice, Video) | --                            |

## Extended `access-list` command examples and logic explanations

| `access-list` statement                                      | what it matches                                                                                                                                                                     |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `access-list 101 deny tcp any gt 49151 host 10.1.1.1 eq 23`  | Packets with a TCP header, any source IP address, with a source port greater than (gt) 1023, a destination IP address of exactly 10.1.1.1, and a destination port equal to (eq) 23. |
| `access-list 101 deny tcp any host 10.1.1.1 eq 23`           | The same as the preceding example, but any source port matches, because that parameter is omitted in this case.                                                                     |
| `access-list 101 deny tcp any host 10.1.1.1 eq telnet`       | The same as the preceding example. The `telnet keyword` is used instead of port 23                                                                                                  |
| `access-list 101 deny udp 1.0.0.0 0.255.255.255 lt 1023 any` | A packet with a source in network 1.0.0.0/8, using UDP with a source port lest than (lt) 1023, with any destination IP address.                                                     |

## Extended IP Access List Configuration Commands

| Command                                 | Configuration Mode and Description                                                |
| --------------------------------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| access-list <access-list-number> <deny  | permit protocol> source <source-wildcard> destination <destination-wildcard> [log | log-input]                                                                                                              | Global command for extended numbered `access lists`. Use a number between 100 and 199 or 2000 and 2699, inclusive. |
| `access-list <access-list-number> {deny | permit} {tcp                                                                      | udp} source <source-wildcard> [operator [port]] destination destination-wildcard [operator [port]] [established] [log]` | A version of the `access-list` command with paramters specific to TCP and/or UDP                                   |

## Network Diagram for Extended Access List Example 1

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.17.png"/>

## R1's Extended Access List: Example 1

```bash
interface Serial0
    ip address 172.16.12.1 255.255.255.0
    ip access-group 101 in
!
interface Serial1
    ip address 172.16.13.1 255.255.255.0
    ip access-group 101 in
!
access-list 101 remark Stop Bob to FTP servers, and Larry to Server1 web
access-list 101 deny tcp host 172.16.3.10 172.16.1.0 0.0.0.255 eq ftp
access-list 101 deny tcp host 172.16.2.10 host 172.16.1.100 eq www
access-list 101 permit ip any any
```

## R3's Extended Access List Stopping Bob from Reachng FTP Servers Near R1

```bash
interface Ethernet0
ip address 172.16.3.1 255.255.255.0
ip access-group 103 in
access-list 103 remark deny Bob to FTP servers in subnet 172.16.1.0/24
access-list 103 deny tcp host 172.16.3.10 172.16.1.0 0.0.0.255 eq ftp
access-list 103 permit ip any any
```

## Network Diagram for Extended Access List Example 2

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.18.png"/>

## Yosemite Configuration for Extended Access List Example 2

```bash
interface ethernet 0
ip access-group 110 in
!
access-list 110 deny ip host 10.1.2.1 10.1.1.0 0.0.0.255
access-list 110 deny ip 10.1.2.0 0.0.0.255 10.1.3.0 0.0.0.255
access-list 110 permit ip any any
```

## Building One-Line Extended ACLs: Practice

| Problem | Criteria                                                                                                                                   |Solution|
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------ |-|
| **1**   | From web client **10.1.1.1**, sent to a web server in subnet **10.1.2.0/24**.                                                              |access-list 101 permit tcp host 10.1.1.1 10.1.2.0 0.0.0.255 eq 80|
| **2**   | From Telnet client **172.16.4.3/25**, sent to a Telnet server in subnet **172.16.3.0/25**. Match all hosts in the client’s subnet as well. |access-list 101 permit tcp 172.16.4.3 0.0.0.127 172.16.3.0 0.0.0.127 eq telnet|
| **3**   | ICMP messages from the subnet in which **192.168.7.200/26** resides to all hosts in the subnet where **192.168.7.14/29** resides.          |access-list 101 permit icmp 192.168.7.192 0.0.0.63 192.168.7.8 0.0.0.7|
| **4**   | From web server **10.2.3.4/23**’s subnet to clients in the same subnet as host **10.4.5.6/22**.                                            |access-list 101 permit tcp 10.2.2.0 0.0.1.255 10.4.4.0 0.0.3.255 eq 80|
| **5**   | From Telnet server **172.20.1.0/24**’s subnet, sent to any host in the same subnet as host **172.20.44.1/23**.                             |access-list 101 permit tcp 172.20.1.0 0.0.0.255 eq telnet 172.20.44.0 0.0.1.255|
| **6**   | From web client **192.168.99.99/28**, sent to a web server in subnet **192.168.176.0/28**. Match all hosts in the client’s subnet as well. |access-list 101 permit tcp 192.168.99.96 0.0.0.31 192.168.176.0 0.0.0.15 eq 80|
| **7**   | ICMP messages from the subnet in which **10.55.66.77/25** resides to all hosts in the subnet where **10.66.55.44/26** resides.             |access-list 101 permit icmp 10.55.66.0 0.0.0.127 10.66.55.0 0.0.0.63|
| **8**   | Any and every IPv4 packet.                                                                                                                 |access-list 101 permit ip any any|

## Named ACL vs. Numbered ACL Configuration

<img src="https://github.com/matoanbach/networking/blob/main/pics/w11.19.png"/>

## Name Access List Configuration

## Removing One Command from a Named ACL

## Editing ACLs Using Sequence Numbers

## Adding to and displaying numbered ACL Configuration

## General Recommendation for ACL Implementation

- Place extended ACLs as close as possible to the source of the packet
- Place standard ACLs as close as possible to the destination of the packet
- Place more specific statements early in the ACL.
- Disable an ACL from its interface (using the `no ip access-group interface subcommand`) before making changes to the ACL.
