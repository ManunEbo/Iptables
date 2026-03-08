#! /bin/bash

# Firewall for a desktop operating system

# Flush filter table from all chains
iptables -F

# Allow loopback interface traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Drop invalid packages on INPUT and OUTPUT chains
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP

# Optional, uncomment the line if you want to allow incoming connections
# from  the network.

# iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT

# Optional, uncomment the line if you want to allow incoming SSH connections
# from a specific IP address
#iptables -A INPUT -p tcp --dport 22 --syn -s 80.0.0.1 -j ACCEPT


# Allow only ESTABLISHED and related packets on INPUT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


# Allow also new packets on OUTPUT (packages that initialize connections)
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# Set default policy to DROP on INPUT and OUTPUT chains
# This will drop all packages that have not been handled any rule above
iptables -P INPUT DROP
iptables -P OUTPUT DROP