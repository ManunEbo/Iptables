#! /bin/bash

echo "Block all IPs and Networks from file"

# A file called bad_hosts.txt exists in the same directory as the scrip
# It contains IPs and Networks, one per line like:
# 11.0.0.16
# 8.8.8.8
# 1.2.3.4
# 192.0.0.0/16  <---- This is an entire network range

# File that contains the IPs and Nets to block
FILE="bad_hosts.txt"

# Creating a new set
ipset -N bad_hosts iphash -exist

# Flushing the set if it exists
ipset -F bad_hosts

echo "Adding IPs from $FILE to bad_hosts set:"
for ip in $(cat $FILE)
do
	ipset -A bad_hosts $ip
	echo -n "$ip"
done

# Flush iptables if you run this script more than once to avoid duplicate rules
# iptables -F

# Adding the iptables rule that references the set and drops all ips and nets

echo -e -n "\nDroppingwith iptables..."
iptables -I INPUT -m set --match-set bad_hosts src -j DROP

echo "Done"