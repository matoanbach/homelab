
# TCP socket
from socket import *

# server
server = socket(AF_INET, SOCK_STREAM)
server.bind(serverAddress)
server.listen(1)
while True:
    server.accept()
    server.recv()
    server.send
    break
server.close()


# clietn
client = socket(AF_INET, SOCK_STREAM)
client.connect()
client.send()
client.recv()
client.close()