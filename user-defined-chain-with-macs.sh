#! /bin/bash

# Flushing all chains
iptables -F

# Deleting all user-defined chains
iptables -X

# Allow all outgoing traffic (except invalid packets)
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT


# Create a new chain named ACCEPTED_MAC
iptables -N ACCEPTED_MAC

# Variable to hold MAC addresses
MACS="B8:81:98:22:C7:6B B8:81:98:22:C6:7C B8:81:98:22:23:AB B8:81:98:22:67:AA"

# Loop through the MACS and add rules to the user defined-chain
# Accept traffic from specific mac addresses

for MAC in $MACS
do
	iptables -A ACCEPTED_MAC -m mac --mac-source $MAC -j ACCEPT
done

# Jump from the INPUT chain to the user-defined chain
# Now packets traverse the iptables rules in the user-defined chain
iptables -A INPUT -j ACCEPTED_MAC

# Allow incoming SSH packets only from the specified MAC addresses
# this is the case because the rule above will take precedence
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# If not dropped or accepted (terminating targets) packets continue
# traversing the INPUT chain
# i.e. Further scrutinize the packets coming from the allowed MAC addresses
# Allow only ICMP packets in and out
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT


# Policy to DROP all packets if they haven't met a termination rule yet
iptables -P OUTPUT DROP
iptables -P INPUT DROP
