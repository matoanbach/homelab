- Ethernet is a collection of network protocols/standards.
- For the purpose 

## What is a networking model?
- Networking models categorize and provide a structure for networking protocols and standards.
- A set of rules defining how network devices and software should work.

## OSI Model
- Open System Interconnection model
- A conceptual model that categorizes and standardizes the different functions in a network
- Created by the `International Organization for Standardization` (ISO).
- Functions are divided into 7 `Layers`.
- These layers work together to make the network work.

### `Application` layer
- This layer is the closest to the end user.
- Interacts with software applications, for example your web browser (Brave, Firefox, Chrome, etc).
- HTTP and HTTPS are Layer 7 protocols (`https`://www.cisco.com)
- Functions if Layer 7 include:
    - Identifying communication partners.
    - Synchronizaing communication.

### `Presentation` layer
- Data in the application layer is in `application format`.
- It needs to be `translated` to a different format to be sent over the network.
- The `presentation` layer is there to translate between application and network formats.
- For example, encryption of data as it is sent, and decryptiong of data as it is received.
- Also translates between different Application - Layer formats.

### `Session` layer
- Controls dialogues (sessions) between communication hosts.
- Establishes, manages, and terminates connections between the local application (for example, your web browser) and the remote application (for example, YouTube).

### `the first three` layers
- Network engineers don't usually work with the top 3 layers.
- Application developers work with the top layers of the OSI model to connect their applicaitons over networks.

### `Transport` layer
- Segments and reassembles data for communications between end hosts.
- Breaks large pieces of data into smaller segments which can be more easily sent over the network and are less likely to cause transmission problems if errors occur.
- Provide `host-to-host` communication.

### `Network` layer
- Provides connectivity between end hosts on different networks (ie. outside of the LAN).
- Provides logical addressing (IP addresses).
- Provides path selection between source and destination.
- Routers operate at Layer 3.

### `Data Link` layer
- Provides node-to-node connectivity and data transfer (for example, PC to switch, switch to router, router to router).
- Defines how data is formatted for transmission over a physical medium (for example, copper UTP cables).
- Detects and (possibly) corrects Physical Layer errors.
- Uses Layer 2 addressing, seperate from Layer 3 addressing.
- Switches operate at this layer.

### `Physical` layer
- Defines physical characteristics of the medium used to transfer data between devices.
- For example, voltage levels, maximum transmission distances, physical connectors, cable specifications, etc.
- Digital bits are converted into electrical (for wired connections) or radio (for wireless connections) signals.
- Cables, layouts, and so on are related to the Physical layer.

### `PDUs` - Protocol Data Units
```bash
[data]                                                  - data
[data][L4 header]                                       - segment
[data][L4 header][L3 header]                            - packet
[L2 trailer][data][L4 header][L3 header][L2 header]     - Frame
```

## TCP/IP
- It has 4 layers: Application, Transport, Internet and Link.
<img src="https://github.com/matoanbach/networking/blob/main/pics/w1.1.png"/>