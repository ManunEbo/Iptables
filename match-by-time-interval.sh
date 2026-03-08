#! /bin/bash

# Match by date and time

# See the help: iptables -m time --help

# Flushing the filter table
iptables -F

# Time is UTC and not system time

# Accepting incoming tcp port 22 (SSH) packets daily only between 8:00-18:00
# Use --kerneltz for local system time
iptables -A INPUT -p tcp --dport 22 -m time --kerneltz --timestart 8:00 --timestop 18:00 -j ACCEPT

iptables -A INPUT -p tcp --dport 22 -j DROP

# Accepting forwarded traffic (this is the router) to www.ubuntu.com on workdays between 18:00-08:00
# Use --kerneltz for local system time
iptables -A FORWARD -p tcp --dport 80 -d www.ubuntu.com -m time --kerneltz --weekdays Mon,Tue,Wed,Thu,Fri --timestart 8:00 --timestop 18:00 -j ACCEPT

# Packets to www.ubuntu.com are dropped between 18:01 - 7:59 
iptables -A FORWARD -p tcp --dport 80 -d www.ubuntu.com -j DROP