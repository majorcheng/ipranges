#!/bin/bash

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses

set -euo pipefail
set -x


# get from public ranges
curl -s https://api.github.com/meta > /tmp/github.json


# get all CIDR prefixes
jq -r '.. | strings | select(test("^[0-9A-Fa-f:.]+/[0-9]+$"))' /tmp/github.json > /tmp/github-all.txt


# save ipv4
grep -v ':' /tmp/github-all.txt > /tmp/github-ipv4.txt

# save ipv6
grep ':' /tmp/github-all.txt > /tmp/github-ipv6.txt


# sort & uniq
sort -V /tmp/github-ipv4.txt | uniq > github/ipv4.txt
sort -V /tmp/github-ipv6.txt | uniq > github/ipv6.txt
