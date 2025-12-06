# Device Management Protocols

## System Message Logging (Syslog)

- Be default, IOS shows log messages to console users for all severity levels of messages. That default happens because of the default `logging console` global configuration command.
- For other global configuration, like `Telnet` and `SSH`, two commands are required: `logging monitor` and `terminal monitor`

## IOS Storing Log Messages for Later View: Buffered and Syslog Server

- `logging bufferd` to store copies of the log messages in RAM. Use can then come back later and see the old log messages by using the `show logging` EXEC command.
- `logging host {address | hostname}` global command to configure a router or switch to send log messages to a syslog server, referencing the IP address or host name of the syslog server.

## Log Message Format

- A timestamp
- The facility on the router that generated the message
- The severity level
- A mnemonic for the message
- The description of the message

## Disabling Timestamps and Enabling Sequence Numbers in Log Messages

```bash
no service timestamps
service sequence-numbers
```

- IOS dictates most of the contents of the messages, but you can at least toggle on and off the use of the `timestamp` (which is included by default) and a log message `sequence number` (which is not enabled by default)

## Syslog Message Severity Levels by Keyword and Numeral

- E: Emergency  : Severe
- A: Alert      : Severe
- C: Critical   : Impactful
- E: Error      : Impactful
- W: Warning    : Impactful
- N: Notififcation  : Normal
- I: Information    : Normal
- D: Debug          : Debug

## How to Configure Logging Message Levels for Each Log Service

- Table below summarizes the configuration commands used to enable logging and to set the severity level for each type
- When the severity level is set, IOS will send messages of that severity level and more severe ones (lower severity numbers) to the service identified in the command.

| Service  | To Enable Logging                | To Set Message Levels                       |
| -------- | -------------------------------- | ------------------------------------------- |
| Console  | logging console                  | logging console level-name OR level-number  |
| Monitor  | logging monitor                  | logging monitor level-name OR level-number  |
| Buffered | logging buffered                 | logging buffered level-name OR level-number |
| Syslog   | logging host address OR hostname | logging trap level-name OR level-number     |

## Sample Network Used in Logging Examples

```bash
logging console 7
logging monitor debug
logging buffered 4
logging host 172.16.3.9
logging trap warning
```

## Viewing the Configured Log Settings of the Earlier Example

```bash
show logging
```

## Example 3: Using `debug ip ospf hello` from R1's Console

- The `debug` EXEC command givs the network engineer a way to ask IOS to monitor for certain internal events, with that monitoring process continuing over time, so that IOS can issue log messages when those events occur.
- The debug remains active until some user issues the `no debug` command with the same parameters, disabling the debug.

# Network Time Protocol (NTP)

- Each networking device has some concept of a `date` and a `time-of-day` clock

## Setting Date/Time with `clock set`, plus Timezone/DST

- NTP's job is to synchronize clocks, but NTP works best if you set the device clock to a reasonably close time before enablin the NTP client function with the `ntp server` command.
- Note: `recurring` keyword tells the router to spring forward an hour and fall back an hour automatically over the years.

```bash
(config) clock timezone EST - 5
(config) clock summer-time EDT recurring
clock set 20:52:49 21 October 2015
show clock
```

## R1 as NTP Client, R2 as Client/Server, R3 as Server

<img src="https://github.com/matoanbach/networking/blob/main/pics/w12.1.png"/>

- Cisco supplies two `ntp` configuration commands that dictate how NTP works on a router or switch, as follows:

1. `ntp master {stratum-level}`: NTP server mode - the device acts only as an NTP server
2. `ntp server {address | hostname}`: NTP client/server mode - the device acts as both client and server

- Note: In the world of NTP, stratum levels define the distance from the reference clock. A reference clock is a `stratum-0` that is assumed to be accurate and has little or no delay associated with it.

## Example: NTP Client/Server Configuration

- As you can see, NTP requires little configuration to make it work with a single configuration command on each device.

```bash
# Configuration on R1:
ntp server 172.16.2.2
# Configuration on R2:
ntp server 172.16.3.3
# Configuration on R3
ntp master 2
```

## Verifying NTP Client Status on R1

- Example below shows a status of synchronized, which confirms the NTP clienet has completed the process of chaning its time to match the server's time.
- It also confirms the IP address of the server - this device's reference clock - with the IP address of the reference device.

## Verifying NTP Client Status on R1 and R2

```bash
R1# show ntp associations
! This output is taken from router R1, acting in client/server mode
address ref clock st when poll reach delay offset disp
*~172.16.2.2 172.16.3.3 3 50 64 377 1.223 0.090 4.469
* sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured

R2# show ntp associations
! This output is taken from router R2, acting in client/server mode
address ref clock st when poll reach delay offset disp
*~172.16.3.3 127.127.1.1 2 49 64 377 1.220 -7.758 3.695
* sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
```

- The \* means that R1 has successfully contacted the server.
- NTP servers and clients use a number to show the perceived accuracy of their reference clock data based on stratum level. The lower the stratum level, the more accurate the reference clock is considered to be.
- Routers and switches use the default stratum level of 8 for their internal reference clock based on the default setting of 8 for the stratum level in the `ntp master [stratum-level]` command.
- The command allows you to set a value from 1 through 15.
- Any devices that calculate their stratum as 16 consider the time data unusable and do not trust the time. So, avoid setting higher stratum values on the `ntp master` command.

## Examining NTP Server, Reference Clock, and Stratum Data

- `NIST` = US National Institute of Standards and Technology

## NTP Using a Loopback Interface for Better Availability

- There is an availability issue of referencing an NTP server's physical interface IP address.
- Solution -> loopback:

```bash
ntp server 172.16.9.9
interface loopback 0
    ip address 172.16.9.9 255.255.255.0

ntp master 4
ntp source loopback 0
show interfaces loopback 0
```

# Analizing Topology Using CDP and LLDP

- `show cdp` commands list information about neighbors

| Command                            | Description                                                                                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `show cdp neighbors [type number]` | Lists one summary line of information about each neighbor, or just the neighbor found on a specific interface if an interface was listed |
| `show cdp neighbors detail`        | Lists one large set (approximately 15 lines) of information, one set for every neighbor                                                  |
| `show cdp entry` name              | Lists the same information as the `show cdp neighbors detail` command, but only for the named neighbor (case sensitive)                  |

## commands to verify CDP operations

| Command              | Description                                                                                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `show cdp`           | States whether CDP is enabled globally, and lists the default update and holdtime timers                                                                     |
| `show cdp interface` | States whether CDP is enabled on each interface, or a single interface if the interface is listed, and states update and holdtime timers on those interfaces |
| `show cdp traffic`   | Lists global statistics for the number of CDP advertisements sent and received                                                                               |

## `show lldp neighbors` command

## `show lldp entry r2`

## Enabling LLDP on All ports, disabling on a few ports
```bash
lldp run
interfaces gigabitEthernet1/0/17
    no lldp transmit
    no lldp receive
interfaces gigabitEtherent1/0/18
```

## Enabling LLDP on Limited Ports, Leaving Disabled on Most
```bash
interface gigabitEthernet1/0/19
    lldp transmit
    lldp receive
interface gigabitEthernet1/0/20
    lldp receive
```