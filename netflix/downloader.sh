#!/bin/bash

# https://github.com/Loyalsoldier/geoip/blob/release/text/netflix.txt

set -euo pipefail
set -x


# get from public ranges
curl -s "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/text/netflix.txt" > /tmp/netflix.txt


# save ipv4
grep -v ':' /tmp/netflix.txt > /tmp/netflix-ipv4.txt

# save ipv6
grep ':' /tmp/netflix.txt > /tmp/netflix-ipv6.txt


# sort & uniq
sort -V /tmp/netflix-ipv4.txt | uniq > netflix/ipv4.txt
sort -V /tmp/netflix-ipv6.txt | uniq > netflix/ipv6.txt
