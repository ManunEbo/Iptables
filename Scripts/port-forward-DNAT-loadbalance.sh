#! /bin/bash

# Port Forwarding (DNAT)

# Flushing nat filter of PREROUTING chain
iptables -t nat -F PREROUTING

# All the packets coming to the public IP address of the router and port 80
# will be port forwarded to 192.168.0.20 on port 80

iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.20

#------------------------------------------------------------------------
#			        Variant - port redirection

# 1. Redirect port 8080 to port 80
# Internet clients connect to the public IP address of the router and port 8080
# and the packets are redirected to the private server with 192.168.0.20 on port 80

# iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20:80

#------------------------------------------------------------------------
#			        Load-Balancing

# Lets say we have 5 private servers within the ip range (192.168.0.20-192.168.0.24)
# On all 5 private servers (192.168.0.20-192.168.0.24) run the same service (e.g. HTTPS)
# We can load-balance traffic to these servers
# The router will pick-up a random private ip from the range and then translate and send
# port-forward the packet to that IP

iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20-192.168.0.24