#! /bin/bash

# Flush the NAT table of all chains
iptables -t nat -F

# Enable routing process
echo "1" > /proc/sys/net/ipv4/ip_forward

# Define rules that match traffic that should be NATed
# We perform NAT for the entire subnetwork
# enp0s3 is the external interface
# 80.0.0.1 is the public & static ip address
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j NAT --to-source 80.0.0.1

# If the public IP address is dynamic we use MASQUERADE instead of SNAT
# iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j MASQUERADE

# it's not mandatory to perform NAT for entire subnet. We could perform
# NAT only for some protocols
# Example: we perform NAT only for TCP
# iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -p tcp -o enp0s3 -j SNAT --to-source 80.0.0.1