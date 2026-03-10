<h1 style="background-color: red;color:lime;">Iptables examples</h1>

<h3>project introduction</h3>

<p>
This project looks at a few basic use cases for Iptables in securing a Linux machine.<br>
The iptables commands are organised into scripts that perform specific tasks.<br>
These scripts can then be either ran at boot or ran once and saved with iptables-persistent (Recommended)<br>
which will load the iptables rules into memory at boot.
</p>

<h3>Scripts:</h3>

<ol>
<li> 
<strong>auto-block-ip.sh</strong><br>
<a href="https://github.com/ManunEbo/Iptables/blob/master/auto-block-ip.sh">auto-block-ip.sh</a><br>
<p>
This server isn't running a webserver. Thus no HTTP or HTTPS traffic is expected.<br>
As a result the script appends the source IP address to an ipset that is used in a rule that<br>
blocks IP addresses if HTTP or HTTPS packets received.<br>
</p>
<div>
<code>
iptables -I INPUT -p tcp -m multiport --dports 80,443 -j SET --add-set auto_blocked src<br>
iptables -I INPUT -m set --match-set auto_blocked src -j DROP
</code>
</div>
</li><br>

<li>
<strong>filter-by-mac.sh</strong><br>
<p>
This script allows communication within the local area network only if it is coming<br>
from desired MAC addresses.<br>
A default policy is used to ensure all other communication is dropped.<br>
</p>
<div>
<code>
iptables -A FORWARD -m mac --mac-source $MAC -j ACCEPT
</code>
</div>
</li><br>

<li>
<strong>ipset-block-country.sh</strong><br>
<p>
This script downloads a file that contains a list of country network IP ranges.<br>
Creates an ipset and then creates an iptables rule to block members of that set.<br>
In this instance we're blocking Israel.
</p>
<div>
<code>
iptables -I INPUT -m set --match-set israel src -j DROP
</code>
</div>
</li><br>

<li>
<strong>ipset-block-from-file.sh</strong><br>
<p>
This script reads IP addresses from a file and creates an ipset.<br>
It then creates a iptables rule to block that set.<br>
</p>
<div>
<code>
iptables -I INPUT -m set --match-set bad_hosts src -j DROP
</code>
</div>
</li><br>

<li>
<strong>limit-packets-per-second.sh</strong><br>
<p>
This script limits the number of ICMP (Ping requests) packets per second to just one.<br>
It also limits the number of HTTPS connections per second to 5; note this is for<br>
demonstration only, it is not a sensible approach for production.
</p>
<div>
<code>
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/sec --limit-burst 3 -j ACCEPT
</code>
</div>
</li><br>

<li>
<strong>load-balance-nat-ports.sh</strong><br>
<p>
This script uses one interfaces to redirect traffic destined for certain ports<br>
and another interface for all other traffics.
</p>
<div>
<code>
iptables -t nat -A POSTROUTING -p tcp --dport $port -o eth1 -j MASQUERADE<br>
iptables -t nat -A POSTROUTING -o eth2 -j MASQUERADE
</code>
</div>
</li><br>

<li>
<strong>match-by-time-interval.sh</strong><br>
<p>
This script restricts SSH access between 08:00 to 18:00.<br>
This also restricts HTTP access to a website on weekdays between 08:00 to 18:00.<br>
All traffic outside of the time intervals are dropped.
</p>
<div>
<code>
iptables -A INPUT -p tcp --dport 22 -m time --kerneltz --timestart 8:00 --timestop 18:00 -j ACCEPT<br>
iptables -A FORWARD -p tcp --dport 80 -d www.ubuntu.com -m time --kerneltz \<br>
 --weekdays Mon,Tue,Wed,Thu,Fri --timestart 8:00 --timestop 18:00 -j ACCEPT
</code>
</div>
</li><br>

<li>
<strong>max-quota.sh</strong><br>
<p>
This script sets different max quotas for HTTP and HTTPS.
</p>
<div>
<code>
iptables -A FORWARD -o $INT -p $PROTOCOL --sport $PORT -m quota --quota $QUOTA1 -j ACCEPT
</code>
</div>
</li><br>

<li>
<strong>nat-masquerade.sh</strong><br>
<p>
This script redirects traffic from a given network to a known public IP of an interface, Nating.<br>
Alternatives are presented with the MASQUERADE and SNAT.
</p>
<div>
<code>
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j NAT --to-source 80.0.0.1<br>
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o enp0s3 -j MASQUERADE<br>
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -p tcp -o enp0s3 -j SNAT --to-source 80.0.0.1
</code>
</div>
</li><br>

<li>
<strong>port-forward-DNAT-loadbalance.sh</strong><br>
<p>
This script forwards all packets headed to the public IP address of a router on a given port,<br>
to a destination IP address.<br>
An alternative is presented where clients connect via one port and then redirected to another port<br>
on the destination IP address.<br>
Lastly, the script demonstrate simple loadbalancing within an IP range, 5 IP addresses.
</p>
<div>
<code>
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.0.20<br>
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20:80<br>
iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.0.20-192.168.0.24
</code>
</div>
</li><br>

<li>
<strong>stateful.sh</strong><br>
<p>
This script allows initiating new connections out of the system while accepting the respective<br>
return communication using the state information.
</p>
<div>
<code>
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT<br>
iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
</code>
</div>
</li><br>

<li>
<strong>user-defined-chain-with-macs.sh</strong><br>
<p>
This script restricts incoming traffic to specified MAC addresses while allowing outgoing<br>
traffic to any destination.<br>
The script then has a default policy to drop all else.
</p>
<div>
<code>
iptables -A ACCEPTED_MAC -m mac --mac-source $MAC -j ACCEPT
</code>
</div>
</li><br>
</ol>