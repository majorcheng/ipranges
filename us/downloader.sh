#!/bin/bash

# https://github.com/Loyalsoldier/geoip/blob/release/text/us.txt

set -euo pipefail
set -x


# get from public ranges
curl -s "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/text/us.txt" > /tmp/us.txt


# save ipv4
grep -v ':' /tmp/us.txt > /tmp/us-ipv4.txt

# save ipv6
grep ':' /tmp/us.txt > /tmp/us-ipv6.txt


# sort & uniq
sort -V /tmp/us-ipv4.txt | uniq > us/ipv4.txt
sort -V /tmp/us-ipv6.txt | uniq > us/ipv6.txt
