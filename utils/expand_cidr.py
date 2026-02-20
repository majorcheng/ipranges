import argparse
import ipaddress


def expand_network(cidr: str, target_prefix: int):
    network = ipaddress.ip_network(cidr, strict=False)

    if network.version == 4:
        if network.prefixlen < target_prefix:
            return network.subnets(new_prefix=target_prefix)
        return [network]

    return [network]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Expand IPv4 CIDRs to a target prefix.')
    parser.add_argument('--source', nargs='?', type=argparse.FileType('r'), required=True, help='Source file path')
    parser.add_argument('--target-prefix', type=int, default=24, help='Target prefix for IPv4 expansion')
    args = parser.parse_args()

    seen = set()

    for line in args.source:
        cidr = line.strip()
        if not cidr:
            continue

        for network in expand_network(cidr, args.target_prefix):
            value = str(network)
            if value not in seen:
                seen.add(value)
                print(value)
