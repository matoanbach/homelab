
# UDP socket 
from socket import *

# server
server = socket(AF_INET, SOCK_DGRAM)
server.bind(serverAddress)
while True:
    server.recvfrom()
    server.sendto(message, clientAddress)
    break

# client
client = socket(AF_INET, SOCK_DGRAM)
client.sendto(message, serverAddress)
response = client.recvfrom()
client.close()