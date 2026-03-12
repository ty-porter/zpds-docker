import socket

HOST = "127.0.0.1"
PORT = 27016
SERVER = (HOST, PORT)

# A2S_INFO query packet
query = b"\xFF\xFF\xFF\xFFTSource Engine Query\x00"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(3)

sock.sendto(query, SERVER)

try:
    data, addr = sock.recvfrom(4096)
    print("Server responded!")
    print(data)
except socket.timeout:
    print("No response from server.")