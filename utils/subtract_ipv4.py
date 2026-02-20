import argparse
import ipaddress


def read_networks(path):
    with open(path, 'r', encoding='utf-8') as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line or line.startswith('#'):
                continue

            network = ipaddress.ip_network(line, strict=False)
            if network.version == 4:
                yield network


def subtract_networks(allow_networks, deny_networks):
    current = list(ipaddress.collapse_addresses(allow_networks))

    for deny in deny_networks:
        next_current = []

        for allow in current:
            if not allow.overlaps(deny):
                next_current.append(allow)
                continue

            if allow.subnet_of(deny):
                continue

            if deny.subnet_of(allow):
                next_current.extend(allow.address_exclude(deny))
                continue

            next_current.append(allow)

        current = list(ipaddress.collapse_addresses(next_current))

    return current


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Subtract IPv4 CIDRs from allowed IPv4 space.')
    parser.add_argument(
        '--allow-source',
        nargs='*',
        default=[],
        help='Optional files containing allowed IPv4 CIDRs. If omitted, defaults to 0.0.0.0/0',
    )
    parser.add_argument(
        '--deny-source',
        nargs='+',
        required=True,
        help='Files containing IPv4 CIDRs to exclude',
    )
    args = parser.parse_args()

    allow_networks = []
    if args.allow_source:
        for source in args.allow_source:
            allow_networks.extend(read_networks(source))
    else:
        allow_networks = [ipaddress.IPv4Network('0.0.0.0/0')]

    deny_networks = []
    for source in args.deny_source:
        deny_networks.extend(read_networks(source))

    result = subtract_networks(allow_networks, deny_networks)
    for network in sorted(result, key=lambda n: (int(n.network_address), n.prefixlen)):
        print(network)
