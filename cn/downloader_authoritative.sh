#!/bin/bash

set -euo pipefail
set -x

mkdir -p cn

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

RIR_URLS=(
  "https://ftp.apnic.net/stats/apnic/delegated-apnic-latest"
  "https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
  "https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest"
  "https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest"
  "https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest"
)

for idx in "${!RIR_URLS[@]}"; do
  curl -fsSL "${RIR_URLS[$idx]}" > "$TMP_DIR/rir_${idx}.txt"
done

python3 utils/rir_delegated_to_cidr.py \
  --sources "$TMP_DIR"/rir_*.txt \
  --country CN \
  --statuses allocated,assigned \
  | sort -V \
  | uniq \
  > cn/ipv4_authoritative.txt

cp cn/ipv4_authoritative.txt cn/ipv4.txt

NRO_URL="https://ftp.ripe.net/pub/stats/ripencc/nro-stats/latest/nro-delegated-stats"
curl -fsSL "$NRO_URL" > "$TMP_DIR/nro_delegated.txt"

python3 utils/rir_delegated_to_cidr.py \
  --sources "$TMP_DIR/nro_delegated.txt" \
  --country CN \
  --statuses allocated,assigned \
  | sort -V \
  | uniq \
  > "$TMP_DIR/nro_cn_ipv4.txt"

echo "RIR_CN_IPV4_CIDR_COUNT=$(wc -l < cn/ipv4_authoritative.txt)"
echo "NRO_CN_IPV4_CIDR_COUNT=$(wc -l < "$TMP_DIR/nro_cn_ipv4.txt")"

sort cn/ipv4_authoritative.txt > "$TMP_DIR/rir_sorted.txt"
sort "$TMP_DIR/nro_cn_ipv4.txt" > "$TMP_DIR/nro_sorted.txt"

echo "ONLY_IN_RIR_COUNT=$(comm -23 "$TMP_DIR/rir_sorted.txt" "$TMP_DIR/nro_sorted.txt" | wc -l)"
echo "ONLY_IN_NRO_COUNT=$(comm -13 "$TMP_DIR/rir_sorted.txt" "$TMP_DIR/nro_sorted.txt" | wc -l)"
