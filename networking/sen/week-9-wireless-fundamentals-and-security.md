# Fundamentals of Wireless Networks and Securing Wireless Networks
## Wireless LAN Topologies
- Unidirectional Communication: The transmitter can contact the receiver at any and all times
- Bidirectional Communication: data should travel in both directions. 

## Basic Service Set
- A basic service set (BSS) is when we make every wireless service area a closed group of mobile devices that forms around a fix device; before a device can participate, it must advertise its capabilities and then be granted permission to join.
<img src="https://github.com/matoanbach/networking/blob/main/pics/w9.1.png"/>

- The centre of every BSS is a wireless access point (AP). It operates in infrastructure mode, which means it offers the services that are necessary to form the infrastructure of a wireless network.
- Basic Service Area (BSA) is where the BSS is bounded by the area where the AP's signal is usable.
- BSSID is a unique BSS identifier that is based on the AP's own radio MAC address.
- SSID as a nonunique and human-readable name tag that identifies the wireless service.

## Distribution System
## Extended Service Set
- ESS is when APs are placed at different geographic locations, they can be interconnected by a switched infrastructure. 
- The idea is to make multiple APS cooperate so that the wireless service is consistent and seamless from the client's perspective.
- Each cell has a unique BSSID, both cells share one common SSID. Regardless of a client's location within the ESS, the SSID will remain the same but the client can always distinguish one AP from another.

## Independent Basic Service Set
- IBSS stands for `independent basic service set`. This 802.11 standard allows two or more wireless clients to communicate directly with each other, with no other means of network connectivity. 

## Repeater
- A repeater mode is when an AP device takes the signal it receives and repeats or retransmits it in a new cell area around the repeater. The idea is to move the repeater out away from the AP so that it is still within range of both the AP and the distant clients.

## Workgroup Bridge
- Workgroup Bridge (WGP) is used to connect the device's wired network adapter to a wireless network.
- You might encounter two types of workgroup bridges:
    - Universal workgroup bridge (uWGB): A single wired device can be bridged to a wireless network.
    - Workgroup bridge (WGB): A Cisco-proprietary implemenatation that allows multiple wired devices to be bridged to a wireless network.

## Outdoor bridged links
- They are commonly used for connectivity between buildings or between cities.

## Mesh Network
- To provide wireless coverage over a very large area, it is not always practical to run Ethernet cabling to every AP that would be needed. Instead, you could use multiple APs configured in mesh mode. In a mesh topology, wireless traffic is bridged from AP to AP, in a daisy-chain fashion, using another wireless channel.

## APs and Wireless Standards
|Admendment|2.4 GHz|5 GHz|Max Data Rate|Notes|
|-|-|-|-|-|
|802.11-1997|Yes|No|2 Mbps|The original 802.11 standard ratified in 1997|
|802.11b|Yes|No|11 Mbps|Introduced in 1999|
|802.11g|Yes|No|54 Mbps|Introduced in 2003|
|802.11a|Yes|No|54 Mbps|Introduced in 1999|
|802.11n|No|Yes|600 Mbps|HT (high throughput), introduced 2009|
|802.11ac|No|Yes|6.93 Gbps|VHT (very high throughput), introduced 2013|
|802.11ax|Yes|Yes|4x 802.11ac|High Efficiency Wireless, Wi-Fi6; expected late 2019; will operate on other bands too, as they become available|