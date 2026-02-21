# ipranges

IP range downloaders by provider/country, plus generated aggregates.

## CN authoritative IPv4

- Script: `cn/downloader_authoritative.sh`
- Primary sources (official delegated stats):
  - `https://ftp.apnic.net/stats/apnic/delegated-apnic-latest`
  - `https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest`
  - `https://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-latest`
  - `https://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-latest`
  - `https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest`
- Optional consistency source:
  - `https://ftp.ripe.net/pub/stats/ripencc/nro-stats/latest/nro-delegated-stats`
- Outputs:
  - `cn/ipv4_authoritative.txt`
  - `cn/ipv4.txt` (same content for compatibility)

## non-CN IPv4

- Script: `non-cn/downloader.sh`
- Method:
  1. Refresh authoritative CN IPv4 list.
  2. Compute `0.0.0.0/0 - CN - reserved/private` using `utils/subtract_ipv4.py`.
  3. Reserved/private deny list is maintained in `non-cn/ipv4_reserved_denylist.txt`.
- Output:
  - `non-cn/ipv4.txt`
