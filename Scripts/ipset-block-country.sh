#! /bin/bash

echo "Blocking Israel"

# Check if the file exists, in the current directory
# if yes, remove it
if [ -f "il-aggregated.zone" ]
then
        rm il-aggregated.zone
fi

# Download the aggregate zone file for Israel
wget http://www.ipdeny.com/ipblocks/data/aggregated/il-aggregated.zone

# check if there was an error
if [ $? -eq 0 ]
then
        echo "Download completed successfully."
else
        echo "Download Failed! Exiting..."
        exit 1
fi

# Creating a new set called Israel of type hash:net (nethash)
ipset -N israel hash:net -exist

# Flushing the set
ipset -F israel

# Iterate over the Networks from the file and add them to the set
echo "Adding Networks to set..."
for i in $(cat il-aggregated.zone)
do
        ipset -A israel $i
done

# Flushing iptables to begin a new
iptables -F

# Adding a rule that references the set
# and drops based  on source IP address
echo -n  "Blocking Israel with iptables..."
iptables -I INPUT -m set --match-set israel src -j DROP

echo "Done"