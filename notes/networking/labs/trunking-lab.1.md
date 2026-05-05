# Topology
<img src="https://github.com/matoanbach/homelab/blob/main/networking/pics/trunking-lab.1.png"/>

## Ping between the PCs. Which pings succeed?


## Assign PC1 and PC2 to VLAN13, and PC2 and PC4 to VLAN24

### Switch 1
```bash
interface FastEthernet0/1
 switchport access vlan 13
 switchport mode access

interface FastEthernet0/2
 switchport access vlan 24
 switchport mode access
```
### Switch 2
```bash
interface FastEthernet0/1
 switchport access vlan 13
 switchport mode access
!
interface FastEthernet0/2
 switchport access vlan 24
 switchport mode access
```

## Create a trunk link between SW1 and SW2
### Switch 1
```bash
interface GigabitEthernet0/1
 switchport trunk native vlan 1
 switchport trunk allowed vlan 1,13,24
 switchport mode trunk
!
interface GigabitEthernet0/2
 switchport trunk native vlan 1
 switchport trunk allowed vlan 1,13,24
 switchport mode trunk
```
### Switch 2
```bash
interface GigabitEthernet0/1
 switchport trunk allowed vlan 1,13,24
 switchport mode trunk
```

## Configure inter-VLAN routing by using subinterfaces on R1's G0/0 interface. Use an address of 10.0.0.1/25 for VLAN 13 and 10.0.0.129/25 for VLAN 24
```bash
interface GigabitEthernet0/0/0
 no shutdown
!
interface GigabitEthernet0/0/0.1
 encapsulation dot1Q 1 native
 no ip address
!
interface GigabitEthernet0/0/0.13
 encapsulation dot1Q 13
 ip address 10.0.0.1 255.255.255.128
!
interface GigabitEthernet0/0/0.24
 encapsulation dot1Q 24
 ip address 10.0.0.129 255.255.255.128
```

## Test connectivity by pinging between PCs.