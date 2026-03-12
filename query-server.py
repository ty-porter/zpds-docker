import socket, sys

try:
    HOST, PORT = sys.argv[1:]
    SERVER = (HOST, int(PORT))
except:
    print(
"""
Server query tool:
usage:
    python query-server.py <HOST> <PORT>
"""
    )

# A2S_INFO query packet
query = b"\xFF\xFF\xFF\xFFTSource Engine Query\x00"

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(3)

print("Sending A2S_INFO query packet with 3s timeout...")
sock.sendto(query, SERVER)

try:
    data, addr = sock.recvfrom(4096)
    print("Server responded!")
    print(data)
except socket.timeout:
    print("No response from server.")