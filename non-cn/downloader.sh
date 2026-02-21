#!/bin/bash

set -euo pipefail
set -x

mkdir -p non-cn

if [ "${IPRANGES_SKIP_CN_REFRESH:-0}" != "1" ]; then
  bash cn/downloader_authoritative.sh
fi

python3 utils/subtract_ipv4.py \
  --deny-source cn/ipv4_authoritative.txt non-cn/ipv4_reserved_denylist.txt \
  | sort -V \
  | uniq \
  > non-cn/ipv4.txt
