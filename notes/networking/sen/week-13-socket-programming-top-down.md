# An application-layer protocol defines:
- Types of messages exchanged
    - e.g., requests, response
- Message syntax
    - what fields in messages & how fields are delinated
- message semantics
    - meaning of information in field
- rules
    - for when and how processes send & respond to messages
- open protocols
    - defined in RFCs, everyone has access to protocol definition
    - allows for interoperability
    - e.g., HTTP, SMTP
- proprietary protocols
    - e.g., Skype, Zoom

## HTTP Overview
- HTTP uses TCP:
    - client initiates TCP connection (creates socket) to server, por t80
    - server accepts TCP connection from client
    - HTTP messages (application-layer protocol messages) exchanged between browser (HTTP client) and Web server(HTTP server)
    - TCP connection closed

- HTTP is `stateless`
    - Server maintains no information about pass client requests.
    - protocols that maintain `state` are complex!
        - pass history (state) must be maintained
        - if server/client crashes, ther views of `state` may be inconsistent, must be reconciled.

## HTTP connection: two types
- Non-persistent HTTP
1. TCP connection opened
2. at most one object sent over TCP connectiom
3. TCP connection closed
4. Downloading multiple onject required multiple connections
- Persistent HTTP
1. TCP connection opened to a server
2. Multiple object can be sent over single TCP connection between client, and that server
3. TCP connection closed

### Non-persistent HTTP: response time
- `RTT`: time for a small packet to travel from client to server and back
- `HTTP response time (per object)`:
    - one RTT to intiate TCP connection
    - one RTT for HTTP request and first few bytes of HTTP response sto return
    - object/file transmission time
- Non-persistent HTTP response time = 2RTT + file transmission time

### Persistent HTTP
- Persistent HTTP 1.1:
    - Server leaves connection open after sending response
    - subsequent HTTP messages between same cleint/server sent over open connection
    - client sends requests as soon as it encounters a referenced object
    - as little as one RTT for all the referenced objects (cutting response time in half)
#### HTTP request message
- Request line (GET, POST, HEAD commands): `GET /index.html HTTP/1.1\r\n`
- Header lines:
```txt
Host: www-net.cs.umass.edu\r\n
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:80.0) Gecko/20100101 Firefox/80.0 \r\n
Accept: text/html,application/xhtml+xml\r\n
Accept-Language: en-us,en;q=0.5\r\n
Accept-Encoding: gzip,deflate\r\n
Connection: keep-alive\r\n
\r\n
```
- Other HTTP request messages:
    - POST method:
        - web page often includes form input
        - user input sent from client to server in entity body of HTTP POST request message
    - GET method (for sending data to server):
        - include user data in URL field of HTTP GET request message (folllowing a `?`)
    - HEAD method:
        - requests headers (only) that would be returned if specified URL were requested with an HTTP GET method
    - PUT method:   
        - uploadas new file (object) to server
        - completely replaces file that exists at specified URL with content in entity body of POST HTTP request message
#### HTTP response message
- Status line (protocol status code status phrase): `HTTP/1.1 200 OK`
- Header lines:
```txt
Date: Tue, 08 Sep 2020 00:53:20 GMT
Server: Apache/2.4.6 (CentOS) OpenSSL/1.0.2k-fips PHP/7.4.9 mod_perl/2.0.11 Perl/v5.16.3
Last-Modified: Tue, 01 Mar 2016 18:57:50 GMT
ETag: "a5b-52d015789ee9e"
Accept-Ranges: bytes
Content-Length: 2651
Content-Type: text/html; charset=UTF-8
\r\n
data data data data data ... 
```
- data, e.g., requested HTML file: `data data data data data ...`

## Cookies
- Web sites and client browser use cookies to maintain some state between transactions
- Four components:
1. cookie header line of HTTP response message
2. cookie header line in next HTTP request mressage
3. cookie file kept on user's host, managed by user's browser
4. back-end database at web site.
- For example:
- Susan uses browser on laptop, visits specific e-commerce site for first time.
- When initial HTTP requests arrives at site, site creates:
    - Unique ID (akd `cookie`)
    - Entry in backend database for ID
- Subsequent HTTP requests from Susam to this site will contain cookie ID value, allowing site to `identity` Susan

### HTTP cookies: comments
- What cookies can be used for:
    - authorization
    - shopping carts
    - recommendations
    - user session state (web e-mail)
- Cookies and privacy:
    - cookies permit sites to learn a lot about you one their site
    - third party persistent cookies (tracking cookies) allow common identity (cookie value) to be tracked across multiple web sites.

## Web caches
- Goal: satisfy client requests without involving origin server
- user configures browser to point to a (local) web cache
- browser sends all HTTP requests to cache
    - `if` object in cache: cache returns object to client
    - `else` cache requests object from origin server, caches received object, then returns object to client

## HTTP/2
- Key goal: decreased delay in multi-object HTTP requests
- methods, status codes, most header fields unchanged from HTTP 1.1
- transmission order of requested objects based on client-specified object priority 
- push unrequested objects to client
- divide objects into frames, schedule frames to mitigate HOL blocking.

## HTTP/2 to HTTP/3
- HTTP/3: adds security, per object error- and congestion-control (more pipelining) over UDP