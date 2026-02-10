#!/usr/bin/env python3
import socket
import sys

def get_local_ip():
    try:
        # This doesn't actually connect to the internet, but allows us to see the interface used
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

def is_private_ip(ip):
    parts = list(map(int, ip.split('.')))
    if parts[0] == 10:
        return True
    if parts[0] == 172 and 16 <= parts[1] <= 31:
        return True
    if parts[0] == 192 and parts[1] == 168:
        return True
    return False

def main():
    ip = get_local_ip()
    print(f"Detected Local IP: {ip}")
    if is_private_ip(ip):
        print("\n[WARNING] You are using a Private IP Address.")
        print("This address is only visible within your local network.")
        print("To connect your MT5 or Bridge to the internet, you should use a Cloudflare Tunnel.")
        print(f"See docs/NETWORKING_AND_IP_GUIDE.md for more info.")
    else:
        print("\n[INFO] You appear to be using a Public IP Address.")

if __name__ == "__main__":
    main()
