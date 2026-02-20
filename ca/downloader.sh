#!/bin/bash

# https://github.com/Loyalsoldier/geoip/blob/release/text/ca.txt

set -euo pipefail
set -x


# get from public ranges
curl -s "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/text/ca.txt" > /tmp/ca.txt


# save ipv4
grep -v ':' /tmp/ca.txt > /tmp/ca-ipv4.txt

# save ipv6
grep ':' /tmp/ca.txt > /tmp/ca-ipv6.txt


# sort & uniq
sort -V /tmp/ca-ipv4.txt | uniq > ca/ipv4.txt
sort -V /tmp/ca-ipv6.txt | uniq > ca/ipv6.txt
