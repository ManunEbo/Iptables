#! /bin/bash

# Load balance NAT traffic over 2 internet connections with dynamic IP address

# Traffic that goes over the first connection
# web: 80 443
# email: 25 465 143 993 110 995
# ssh: 22
 
ISP1="22 25 80 110 143 443 465 993 995"

# Flushing nat table and POSTROUTING chain
iptables -t nat -F POSTROUTING

# enable routing
echo "1" > /proc/sys/net/ipv4/ip_forward

# Port forwarding via a specific interface allows us to narrow down
# the analysis of specific types of traffic on the given interface
# We can then use tools such as wireshark to capture and analyze traffic

for port in $ISP1
do
	iptables -t nat -A POSTROUTING -p tcp --dport $port -o eth1 -j MASQUERADE
done

# Traffic not NATed goes over the 2nd connection
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE