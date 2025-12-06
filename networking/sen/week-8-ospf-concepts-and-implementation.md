# Understanding OSPF Concepts
## Objectives
- Comparing Dynamic Routing Protocol Features
- OSPF Concepts and Operation
- OSPF Areas and LSAs

## Comparing Dynamic Routing Protocol Features
- Routing protocols - These are used by routers to learn and share routes automatically. They exchange information with other routes to find the best path for data. Examples are `RIP`, `EIGRP`, `OSPF`, `BGP`.
- Routed (or Routable) Protocols - These are the actual procols that carry user data and have addressing built in so routers can foward the packets. Examples are `IPv4` and `IPv6`
- In shorts:
    - Routing protocols = how routers learn paths
    - Routed protolcols = what routes move data for (actual traffic)

## Routing Protocol Functions
1. Learn routing information about IP subnets from neighboring routers.
2. Advertise routing information about IP subnets to neighboring routers.
3. If more than one possible route exists to reach one subnet, pick the best route based on a metric.
4. If the network topology changes - for example, a link fails - react by advertising that some routes have failed and have failed and pick a new currently best route. (This process is called convergence)

<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.1.png"/>

- Step 1. R2 advertises a route to the lower right subnet - 172.16.3.0/24 - to both router R1 and R3.
- Step 2. After R3 learns about the route to 172.16.3.0/24 from R2, R3 advertises that route to R1
- Step 3. R1 must make a decision about the two routes it learned about for reaching subnet 172.16.3.0/24 - one with metric 1 from R2 and one with metric 2 from R3. R1 chooses the lower metric route through R2 (function 3).

## Interior and Exterior Routing Protocols
- Ip routing protocols fall into one of two major categories: interior gateway protocols (IGP) or exterior gateway protocols (EGP). The definitions of each are as follows:
    - IGP: a routing protocol that was designed and intended for use inside a single autonomous system (AS)
    - EGP: A routing protocol that was designed and intended for use between different autonomous systems.

- An autonomous system (AS) is a network under the administrative control of a single organization.
- Some routing protocols work best inside a single AS by design, these are called IGPs
- Other routing protocols work best between ASs by design, these are called EGPs

## Comparing IGPs
### IGP Routing Protocol Algorithms
- Three main branches of routing protocol algorithms exist for IGP routing protocols:
    1. Distance vector (sometimes called Bellman-Ford after its creators)
    2. Advanced distance vector (sometimes called `balanced hybrid`)
    3. Link-state
- Distance vector protocols were invented first (RIP and IGRP)
- Link state protocols (OSPF and IS-IS) and advanced distance vector protocols (EIGRP) came later.

### IGP Routing Protocol Metrics
- Routing protocols choose the best route to reach a subnet by choosing the route with the lowest metric.
| IGP   | Metric                                   | Description                                                                                                                  |
|-------|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| RIPv2 | Hop count                                | The number of routers (hops) between a router and the destination subnet                                                     |
| OSPF  | Cost                                     | The sum of all interface cost settings for all links in a route, with the cost defaulting to be based on interface bandwidth |
| EIGRP | Calculation based on bandwidth and delay | Calculated based on the route's slowest link and the cumulative delay associated with each interface in the route            |

### Administrative Distance
- When two different routing protocols learn routes to the same subnet, IOS cannot compare the metrics.
- When IOS must choose between routes learned using different routing protocols it uses a concept called `administrative distance`.
- `administrative distance` is a number that denotes how believable an entire routing protocol is, on a single router.

| Route Type                   | Administrative Distance |
|------------------------------|-------------------------|
| Connected                    | 0                       |
| Static                       | 1                       |
| BGP (External routes - eBGP) | 20                      |
| EIGRP (Internal routes)      | 90                      |
| IGRP                         | 100                     |
| OSPF                         | 110                     |
| IS-IS                        | 115                     |
| RIP                          | 120                     |
| EIFRP (External routes)      | 170                     |
| BGP (Internal routes - iBGP) | 200                     |
| DHCP default route           | 254                     |
| Unusable                     | 255                     |

## OSPF Overview
- Link State protocols build IP routes with a couple of major steps:
    - The routers learn a lot of information about the network (Routers, links, IP addresses, status information, etc.)
    - The routers then flood this information so that all routers know the same information.
    - Each router can then calculate routes to all subnets from their own perspectives.

### Topology Information and LSAs
- OSPF organizes topology information using LSAs and the link-state database (LSDB)
- Each LSA is a data structure with some specific information about the network topology.
- The LSDB is a collection of all the LSAs known to a router.
- The flooding process has a way to prevent loops so that the LSAs do not get flooded around in circles:
    - Before sending an LSA to yet another neighbor, routers communicate which LSAs they already have.
    - Only LSAs that are not know are flooded.
- Routers reflood LSA information based on the LSAs separate aging timer (default 30 minutes)

### Applying Dijkstra Math to find the best routes
- To build routes, link state routes must do some math based on the topological information found in the LSDB.
- All link state protocols use a math algorithm called Dijkstra Shortest Path First (SPF) to process the LSDB.
- The algorithm analyzes the LSDB and builds the routes that the local route will add to the IP routing table.

### Becoming OSPF Neighbors
- OSPF neighbors are routers that both use OSPF, and both sit on the same data link.
- OSPF routers introduce themselves by sending Hello messages.
- Assuming the two neighbors have compatible OSPF parameters, the two will form a neighbor relationship.
- The OSPF neighbor relationship lets OSPF know when a neighbor might not be a good option for routing packets.
- The OSPF neighbor model allows new routers to by dynamically discovered.

<img src="https://github.com/matoanbach/homelab/blob/main/networking/pics/w8.8.png"/>

### Meeting Neighbors and Learning Their Router-ID
- When OSPF exchanges `Hello` messsage they lust each router's `router-id` (RID).
- This RID serves as each router's unique name or identifier for OSPF.
- OSPF RIDs are `32-bit` numbers.
- IOS chooses its OSPF RID based on an active interface IPv4 address.
- The OSPF RID can also be directly configured.
- As soon as a router has choosen its OSPF RID's and some interfaces come up. the router is ready to meet its OSPF neighbors.
- Note:
    - The default hello intervals are 10 seconds for the hello time, and 40 seconds for the dead time.
    - To discover other OSPF-speaking routers, a router sends `multicast OSPF Hello packets` to each interface and hopes to receive OSPF `hello packets` from other routers connected to those interfaces.
- The process:
    - The Hello message follows the IP packet header, with IP protocol type 89.
    - Hello packets are sent to multicast IP address 224.0.0.4, a multicast IP address intended for all OSPF-speaking routers.
    - OSPF routers listen for packets sent to IP multicast address 224.0.0.5, in part hoping to receive Hello packets and learn about new neighbors.
- The 2-way state is a particularly important OSPF state. At that point, the following major facts are true:
    - The router received a Hello from the neighbor, with that router's own RID listed as being seen by the neighbor.
    - The router has checked all the parameters in the Hello received from the neighbor, with no problems. The router is willing to become an OSPF neighbor.
    - If both routers reach a 2-way state with each other, it means that both routers meet all OSPF configuration requirements to become neighbors. Effectively, at that point, they are neighbors and ready to exchange their LSDB with each other.

### Fully Exchanging LSAs with Neighbors
- After two routers decide to exchange databases, they do not simply send the contents of their entire database:
    1. They tell each other a list of LSAs that are in their respective databases.
    2. Each router checks to see which LSAs it already has.
    3. Each router then requests only those LSAs that it does not know about yet.
- OSPF messages that actually send the LSAs between neighbors are called `Link-State-Update` (LSU) packets.
- Each LSU packet holds data structures called Link State Advertisements (LSA).
- When finished, the routers reach a full state, meaning they have fully exchanged the contents of their LSDBs.

### Maintaining Neighbors and the LSDB
- Once two neighbors reach a full state, they have done all the initial work to exchange OSPF information.
- Neighbors still have to do some small ongoing tasks to maintain their neighbor relationship:
    - Routers monitor each neighbor relationship using Hello messages and two related timers: Hello Interval and Dead Interval.
    - Routers send and expect to receive a Hello message from each neighbor based on the Hello interval
    - If a neighbor is silent for the length of the Dead Interval, the router assumes the neighbor has failed.
    - Routers must also be able to react when the topology changes.

### OSPF Maintainance Task Summary
- Maintain neighbor state by sending Hello messages based on the Hello interval, and listening for Hellos before the Dead Interval expires.
- Flood any changed LSAs to each neighbor.
- Reflood unchanged LSAs as their lifetime expires (default 30 minutes)

## Designated Routers on Ethernet Links
- Network types are:
    1. Point-to-point (Ex. WAN link)
    2. Point-to-multipoint (Ex. Broadcast)
- On Ethernet Links, OSPF elects one of the routers on the same subnet to act as the `designated router` (DR)
- The DR plays a key role in how the database exchange process works.
- Note: BDR = Backup Designated Router (hot stand-by)
- The database exchange process on an Ethernet link does not happen between every pair of routers on the same VLAN/subnet.
- The database exchange happens between the DR and each of the other routers.
- The `backup designated router` (BDR) watches the status of the DR and takes over for the DR if it fails.
- The `DR and BDR both do full database exchanges with all other routers` on the LAN, they both reach a full state with all neighbors.

### Stable OSPF Neighbor States and Their Meanings
| Neighbor State | Term for Neighbor                          | Term for Relationship |
|----------------|--------------------------------------------|-----------------------|
| 2-way          | Neighbor                                   | Neighbor Relationship |
| Full           | Adjacent Neighbor, Fully Adjacent Neighbor | Adjency               |

### Calculating the Best Routes with SPF
<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.2.png"/>

- Once SPF has identified a route, OSPF calculates the metric for a route as follows:
    - The sum of the OSPF interface costs for all outgoing interfaces in the route.

## OSPF Area Design 

- Larger OSPFv2 networks suffer when using a single area design:
    - A larger topology database requires more memory on each router.
    - Processing the larger topology database with the SPF algorithm requires processing power that grows exponentially with the size of the topology database.
    - A single interface status change, anywhere in the internetwork (up to down, or down to up), forces every router to run SPF again.
- Solution:
    - The solution is to take one large LSDB and break it into several smaller LSDBs by using OSPF area.
    - With areas each link is placed into one area.
    - SPF does it complicated math on the topology inside the area and that area's topology only.
    - Generally, networks larger than a few dozen routers benefit from areas.

- OSPF area design follows a couple of basic rules:
    - Put all interfaces connected to the same subnet inside the same area.
    - An area should be contiguous.
    - Some routers may be internal to an area, with all interfaces assigned to that single area.
    - Some routers may be Area Border Routers (ABR), because some interfaces connect to the backbone area, and some connect to nonbackbone areas.
    - All nonbackbone areas must connect to the backbond area (area o) by having at least one ABR connected to both the backbone area and the nonbackbone area.

<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.2.png"/>

| Term               | Description                                                                                                                           |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| Area Border Router | An OSPF router with interfaces connected to the backbone area and to at least one other area                                          |
| Backbone router    | A router connected to the backbone area (includes ABRs)                                                                               |
| Internal router    | A router in one area (not the backbone area)                                                                                          |
| Area               | A set of routers and links that shares the same detailed LSDB information, but not with routers in other areas, for better efficiency |
| Backbone area      | A special OSPF area to which all other areas must connect - area 0                                                                    |
| Intra-area route   | A route to a subnet inside the same area as the router                                                                                |
| Interarea route    | A route to a subnet in an area of which the router is not a part                                                                      |

### How Areas Reduce SPF Calculation Time
- SPF spends most of its processing time working through all the topology details
- Areas reduce this workload because the LSDB only lists those routers and links inside that area.
- While the LSDB has less topology information, it still must have information about all subnets in all areas.
- OSPF uses very brief summary information about the subnets to other areas.
- These LSAs do not include topology information about the other areas.

<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.4.png"/>

### OSPF Area Design Advantages
- The smaller per-area LSDB requires less memory.
- Routers require fewer CPU cycles to process the smaller per-area LSDB with the SDF algorithm, reducing CPU overhead and improving convergence time.
- Changes in the network (for example, links failing and recovering) require SPF calculations only on routers connected to the area where the link changed state, reducing the number of routers that must rerun SPF.
- Less information to be advertised between areas, reducing the bandwidth required to send LSAs.

# Implementing OSPF
## Implementing Single-Area OSPFv2
- Step 1: Use the `router ospf <process-id>` global command to enter OSPF configuration mode for a particular OSPF process.
- Step 2: Configure the OSPF router ID by doing the following:
    - Use the `router-id <id-value>` router subcommand to define the router ID, or
    - Use the `interface loopback <number>` global command, along with an ip address `address mask` command, to configure an IP addresss on a loopback interface (chooses the highest IP address of all working loopbacks), or
    - Rely on an interface IP address (chooses the highest IP address of all working nonloopbacks).
- Step 3: Use on or more `network <ip-address wildcard-mask> area <area-id>` router subcommands to enable OSPFv2 on many interfaces matched by the configured address and mask, enabling OSPF on the interface for the listed area.

<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.5.png"/>

## OSPF Single-Area Configuration

### Example 20-2 - OSPF Single-Area Configuration on R2 Using one network command
```bash
router ospf 1
    network 10.0.0.0 0.255.255.255.255 area 0
```
- The `router ospf 1` global command puts the users into OSPF configuration mode and sets the OSPF `process-id` to 1.
- This `process-id` just needs to be unique on the local router and be between 1 and 65535.
- The OSPF `network` command tells the router to finds its local interfaces that match the first two parameters in the command.
- Those interfacews then discover neighbors, create neighbor relationships and assign the interface to the area listed.

### Wildcard Matching with the network Command
- Rather than comparing the entire number in the network command to the entire IPv4 address on the interface, the router can compare a subset of the octets, based on the wildcard mask, as follows:
    - `wildcard 0.0.0.0`: compare all four octest. In other words, the numbers must exactly match.
    - `wildcard 0.0.0.255`: compare the first three octets only. Ignore the last octet when comparing the numbers.
    - `wildcard 0.0.255.255`: compare the first two octets only. Ignore the last two octets when comparing the numbers.
    - `wildcard 0.255.255.255`: compare the first octet only. Ignore the last three octets when comparing the numbers.
    - `wildcard 255.255.255.255`: compare nothing; this wildcard mask means that all address will match the `network` command.

## Verifying OSPF Operation

<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.6.png"/>

### OSPF Neighbors on Router R1
```bash
show ip ospf neighbor
```
- **Interface**: This is the local router's interface connected to the neighbor. For example, the first neighbor in the list is reachable through R1's G0/0/0 interface.
- **Address**: This is the neighbor's IP address on that link. Again, for this first neighbor, which R2, uses IP address 10.1.12.2.
- **State**: While many possible states exist, for the details discussed in this chapter, FULL is the correct and fully working state in this case.
- **Neighbor ID**: This is the router ID of the neighbor.

### OSPF Database on Router R1
```bash
R1# show ip ospf database

OSPF Router with ID (1.1.1.1) (Process ID 1)
Router Link States (Area 0)
Link ID ADV Router Age Seq# Checksum Link count
1.1.1.1 1.1.1.1 431 0x8000008F 0x00DCCA 5
2.2.2.2 2.2.2.2 1167 0x8000007F 0x009DA1 2
3.3.3.3 3.3.3.3 441 0x80000005 0x002FB1 1
4.4.4.4 4.4.4.4 530 0x80000004 0x007F39 2
Net Link States (Area 0)
Link ID ADV Router Age Seq# Checksum
10.1.12.2 2.2.2.2 1167 0x8000007C 0x00BBD5
10.1.13.3 3.3.3.3 453 0x80000001 0x00A161
10.1.14.1 1.1.1.1 745 0x8000007B 0x004449
10.1.23.3 3.3.3.3 8 0x80000001 0x00658F
```
- When OSPF is working correctly in the internetwork with a single-area design, all of the routers will have the same LSDB contents.

### Example: Router R3 Configuration and the `show ip protocols` command
- The best way to verify the configuration begings with the `show running-config` command, of course. However, the `shwo ip protocols` command repeats the details of the OSPFv2 configuration and does not require enable mode access.

```bash
# First, a reminder of R3's configuration per Example 20-3
router ospf 1
    network 10.1.13.3 0.0.0.0 area 0
    network 10.1.23.3 0.0.0.0 area 0
#
# The output from router R3:
R3# show ip protocols
*** IP Routing is NSF aware ***
Routing Protocol is "ospf 1"
    Outgoing update filter list for all interfaces is not set
    Incoming update filter list for all interfaces is not set
Router ID 3.3.3.3
    Number of areas in this router is 1. 1 normal 0 stub 0 nssa
    Maximum path: 4
Routing for Networks:
    10.1.13.3 0.0.0.0 area 0
    10.1.23.3 0.0.0.0 area 0
Routing Information Sources:
    Gateway Distance Last Update
    1.1.1.1 110 02:05:26
    4.4.4.4 110 02:05:26
    2.2.2.2 110 01:51:16
Distance: (default is 110)
```

### Example: Router R1 `show ip ospf interface brief` command

- IOS interprets the network commands to choose interfaces on which to run OSPF, so it could be that IPS chooses a different set of interfaces than you predicted. To check the list of interfaces chosen by IOS, use the `show ip ospf interface brief` command, which lists all interfaces that have been enabled for OSPF processing.

```bash
R1# show ip ospf interface brief
Interface PID Area IP Address/Mask Cost State Nbrs F/C
Gi0/0/0 1 0 10.1.12.1/24 1 BDR 1/1
Gi0/1/0 1 0 10.1.13.1/24 1 BDR 1/1
Gi0/2/0 1 0 10.1.14.1/24 1 DR 1/1
Gi0/0.2 1 0 10.1.2.1/24 1 DR 0/0
Gi0/0.1 1 0 10.1.1.1/24 1 DR 0/0
```

### Configuring the OSPF Router ID
- OSPF speaking routers must have a router-ID (RID) for proper operation.
- By default, routers will choose an interface IP address to use as the RID.
- Typically, engineers prefer to choose each router's RID.
- A Cisco router uses the following process when the router reloads and brings up the OSPF process to find the RID.
    1. If the `router-id <rid>` OSPF subcommand is configured, this value is used the RID. (it can be any number like 1.1.1.1 to 255.255.255.255)
    2. If any loopback interfaces have an IP address configured, and the interface has an interface status of up, the router picks the highest numeric IP address among these loopback interfaces.
    3. The router picks the highest numeric IP address from all other interfaces whose interface status code (first status code) is up. (In other words, an interface in up/down state will be included by OSPF when choosing its router ID.)

#### Example: OSPF Router ID configuration Examples
```bash
! R1 Configuration first
router ospf 1
    router-id 1.1.1.1
    network 10.1.0.0 0.0.255.255 area 0
```

```bash
! R2 Configuration next
!
interface Loopback2
ip address 2.2.2.2 255.255.255.255
```
- To verify what is the router id on R1:
```bash
R1# show ip ospf
```

#### Implementing Multiarea OSPF
<img src="https://github.com/matoanbach/networking/blob/main/pics/w8.7.png"/>

```bash
router ospf 1
    network 10.1.1.1 0.0.0.0 area 0
    network 10.1.1.1 0.0.0.0 area 0
    network 10.1.1.1 0.0.0.0 area 23
    network 10.1.1.1 0.0.0.0 area 23
    network 10.1.1.1 0.0.0.0 area 4
```