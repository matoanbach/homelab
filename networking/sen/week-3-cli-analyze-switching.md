# CCNA 200-301 — Day 4  
## Introduction to the Cisco IOS CLI

---

## What is a CLI?
- **Command-line interface**
- The interface you use to configure Cisco devices
- Compared to GUI (Graphical User Interface)

---

## How to Connect to a Cisco Device (Console Port)
- **RJ45**
- **USB Mini-B**
- **Rollover cable** (pinouts shown)
- Terminal Emulator (e.g., PuTTY from putty.org)

---

## Cisco IOS CLI Modes

### User EXEC Mode
- Prompt: `Router>`
- Very limited access
- Can view some information, cannot change configuration
- Also called *user mode*

### Privileged EXEC Mode
- Command:  
```bash
Router> enable
Router#
```
- Full access to view configuration, restart device, save config
- Cannot fully change configuration

### Global Configuration Mode
- Prompt: `Router(config)#`
- Used to configure the device

---

## Passwords
- **enable password**
- Case-sensitive
- Does not display as you type
- **service password-encryption**
- Encrypts current & future passwords (weak encryption)
- Does not affect `enable secret`
- **enable secret**
- Uses MD5 encryption
- Stronger, recommended

---

## Running-config / Startup-config
- **Running-config**: current active config in RAM
- **Startup-config**: loaded from NVRAM at boot
- Commands:
- `show running-config`
- `show startup-config`
- Saving config:
- `write`
- `write memory`
- `copy running-config startup-config`

---

## Canceling Commands
- Use `no` in front of a command to remove it
```bash
Router(config)# no command
```

---

## Modes Review
- `Router>` → User EXEC mode
- `Router#` → Privileged EXEC mode
- `Router(config)#` → Global configuration mode

---

## Command Review
- `enable` → enter privileged EXEC mode
- `configure terminal` → enter global config mode
- `enable password password` → set password for privileged EXEC
- `service password-encryption` → encrypt passwords
- `enable secret password` → secure, encrypted password
- `do <command>` → run exec-level command from config mode
- `show running-config` / `show startup-config` → display configs
- `write` / `copy running-config startup-config` → save configs


## Common Switch Configuration Mods

| Prompt| Name Of Mode| Context Setting configure terminal |
|---|---|---|
|hostname(config)# | Global | None - first mode after `configure terminal`|
|hostname(config-line)# | Line | line console 0; line vty 0 15 |
|hostname(config-if)| Interface | interface type number |
|hostname(vlan)#| VLAN |vlan number|

<img src="https://github.com/matoanbach/networking/blob/main/pics/w3.1.1.png"/>

## Lab
### Part 2
- Step 1: Assign static IP information to the PC interfaces.
    - Configure the IP address, subnet mask, and default gateway settings on PC-A
    - Configure the IP address, subnet mask, and default gateway settings on PC-B
    - Ping
- Step 2: Configure the router.
    - **a.** Console into the router and enable privileged EXEC mode.  
        - `Router>` → `enable` → `Router#`

    - **b.** Enter configuration mode.  
        - `Router# configure terminal`

    - **c.** Assign a device name to the router.  
        - `Router(config)# hostname R1`

    - **d.** Disable DNS lookup to prevent the router from attempting to translate incorrectly entered commands as though they were host names.  
        - `R1(config)# no ip domain-lookup`

    - **e.** Assign `class` as the privileged EXEC encrypted password.  
        - `R1(config)# enable secret class`

    - **f.** Assign `cisco` as the console password and enable login.  
        - ```
            R1(config)# line console 0
            R1(config-line)# password cisco
            R1(config-line)# login
            ```

    - **g.** Assign `cisco` as the VTY password and enable login.  
        - ```
            R1(config)# line vty 0 4
            R1(config-line)# password cisco
            R1(config-line)# login
            ```

    - **h.** Encrypt the plaintext passwords.  
        - `R1(config)# service password-encryption`

    - **i.** Create a banner that warns anyone accessing the device that unauthorized access is prohibited.  
        - `R1(config)# banner motd # Unauthorized access is prohibited! #`

    - **j.** Configure and activate both interfaces on the router.  
        - Example:  
            ```
            R1(config)# interface g0/0/0
            R1(config-if)# ip address 192.168.0.1 255.255.255.0
            R1(config-if)# ipv4 address 2001:db8:acad::1/64
            R1(config-if)# ipv4 address fe80::1 link-local 
            R1(config-if)# no shutdown

            R1(config)# interface g0/0/1
            R1(config-if)# ip address 192.168.1.1 255.255.255.0
            R1(config-if)# ipv4 address 2001:db8:acad:1::1/64 
            R1(config-if)# ipv4 address fe80::1 link-local 
            R1(config-if)# no shutdown
            ```

    - **k.** Configure an interface description for each interface indicating which device is connected to it.  
        - `R1(config-if)# description Link to PC-A`  
        - `R1(config-if)# description Link to Switch`

    - **l.** To enable IPv6 routing, enter the command:  
        - `R1(config)# ipv6 unicast-routing`

    - **m.** Save the running configuration to the startup configuration file.  
        - `R1# copy running-config startup-config`

    - **n.** Set the clock on the router.  
        - `R1# clock set HH:MM:SS DAY MONTH YEAR`  
        - *Tip:* Use `?` for help with the correct sequence.

    - **o.** Ping PC-B from a command prompt window on PC-A.  
        - `ping 192.168.x.x`  

    **Question:**  
    - Were the pings successful?  
    - If not, check:  
    - IP addressing  
    - Interface status (`no shutdown`)  
    - Firewall settings on PCs
- Step 3: Configure the switch
    - **a.** Console into the switch and enable privileged EXEC mode.  
        - `Switch>` → `enable` → `Switch#`

    - **b.** Enter configuration mode.  
        - `Switch# configure terminal`

    - **c.** Assign a device name to the switch.  
        - `Switch(config)# hostname S1`

    - **d.** Disable DNS lookup to prevent the switch from attempting to translate incorrectly entered commands as though they were host names.  
        - `S1(config)# no ip domain-lookup`

    - **e.** Configure and activate the VLAN 1 interface on the switch S1.  
        ```bash
        S1(config)# interface vlan 1
        S1(config-if)# ip address 192.168.1.2 255.255.255.0
        S1(config-if)# no shutdown
        ```
    - **f.** Configure the default gateway for the switch S1.
        - `S1(config)# ip default-gateway 192.168.1.1`
    - **g.** Save the running configuration to the startup configuration file.
        - `S1# copy running-config startup-config`
### Part 3:
- Step 1: Display the routing table on the router.
    - **a.**
    ```bash
    R1#show ip route
    Codes: L - local, C - connected, S - static, R - RIP, M - mobile, B - BGP
    D - EIGRP, EX - EIGRP external, O - OSPF, IA - OSPF inter area
    N1 - OSPF NSSA external type 1, N2 - OSPF NSSA external type 2
    E1 - OSPF external type 1, E2 - OSPF external type 2, E - EGP
    i - IS-IS, L1 - IS-IS level-1, L2 - IS-IS level-2, ia - IS-IS inter area
    * - candidate default, U - per-user static route, o - ODR
    P - periodic downloaded static route
    
    Gateway of last resort is not set
    
    192.168.0.0/24 is variably subnetted, 2 subnets, 2 masks
    C 192.168.0.0/24 is directly connected, GigabitEthernet0/0/0
    L 192.168.0.1/32 is directly connected, GigabitEthernet0/0/0
    192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
    C 192.168.1.0/24 is directly connected, GigabitEthernet0/0/1
    L 192.168.1.1/32 is directly connected, GigabitEthernet0/0/1
    ```
    - **c**
    ```bash
    R1#show ipv6 route
    IPv6 Routing Table - 5 entries
    Codes: C - Connected, L - Local, S - Static, R - RIP, B - BGP
        U - Per-user Static route, M - MIPv6
        I1 - ISIS L1, I2 - ISIS L2, IA - ISIS interarea, IS - ISIS summary
        ND - ND Default, NDp - ND Prefix, DCE - Destination, NDr - Redirect
        O - OSPF intra, OI - OSPF inter, OE1 - OSPF ext 1, OE2 - OSPF ext 2
        ON1 - OSPF NSSA ext 1, ON2 - OSPF NSSA ext 2
        D - EIGRP, EX - EIGRP external
    C   2001:DB8:ACAD::/64 [0/0]
        via GigabitEthernet0/0/0, directly connected
    L   2001:DB8:ACAD::1/128 [0/0]
        via GigabitEthernet0/0/0, receive
    C   2001:DB8:ACAD:1::/64 [0/0]
        via GigabitEthernet0/0/1, directly connected
    L   2001:DB8:ACAD:1::1/128 [0/0]
        via GigabitEthernet0/0/1, receive
    L   FF00::/8 [0/0]
        via Null0, receive
    ```
    