#! /bin/bash

# Lets flush the iptables to remove any rules using ipsets
# because we can't destroy an ipset that is referenced by a rule
iptables -F

# Destroying all ipsets
ipset -X

# Lets create a new ipset
ipset -N auto_blocked iphash -exist

# Lets add an iptable rule that adds IP addresses to the set auto_blocked
# if the packet comes to either port 80 or 443

iptables -I INPUT -p tcp -m multiport --dports 80,443 -j SET --add-set auto_blocked src

# Lets add an iptables rule that blocks members of the set auto_blocked
iptables -I INPUT -m set --match-set auto_blocked src -j DROP