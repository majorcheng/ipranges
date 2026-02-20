import argparse
import ipaddress


def parse_networks(source, country, allowed_statuses):
    for raw_line in source:
        line = raw_line.strip()
        if not line or line.startswith('#'):
            continue

        fields = line.split('|')
        if len(fields) < 7:
            continue

        cc = fields[1].upper()
        record_type = fields[2].lower()
        start = fields[3]
        value = fields[4]
        status = fields[6].lower()

        if cc != country:
            continue
        if record_type != 'ipv4':
            continue
        if status not in allowed_statuses:
            continue

        try:
            start_ip = ipaddress.IPv4Address(start)
            size = int(value)
        except ValueError:
            continue

        if size <= 0:
            continue

        end_int = int(start_ip) + size - 1
        if end_int > (2**32 - 1):
            continue

        end_ip = ipaddress.IPv4Address(end_int)
        for network in ipaddress.summarize_address_range(start_ip, end_ip):
            yield network


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Convert delegated RIR records to IPv4 CIDRs for a specific country.'
    )
    parser.add_argument(
        '--sources',
        nargs='+',
        type=argparse.FileType('r'),
        required=True,
        help='Source delegated files',
    )
    parser.add_argument(
        '--country',
        type=str,
        default='CN',
        help='Two-letter country code (default: CN)',
    )
    parser.add_argument(
        '--statuses',
        type=str,
        default='allocated,assigned',
        help='Comma-separated statuses to include',
    )
    parser.add_argument(
        '--no-collapse',
        action='store_true',
        help='Disable global collapse of generated CIDRs',
    )
    args = parser.parse_args()

    country = args.country.upper()
    allowed_statuses = {item.strip().lower() for item in args.statuses.split(',') if item.strip()}

    networks = []
    for source in args.sources:
        networks.extend(parse_networks(source, country, allowed_statuses))

    if not args.no_collapse:
        networks = list(ipaddress.collapse_addresses(networks))

    for network in sorted(set(networks), key=lambda n: (int(n.network_address), n.prefixlen)):
        print(network)
