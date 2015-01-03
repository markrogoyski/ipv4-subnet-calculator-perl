ipv4-subnet-calculator-perl
===========================

Network calculator for subnet mask and other classless (CIDR) network information.

Features
--------
Given an IP address and CIDR network size, it calculates the network information and provides all-in-one aggregated reports.

### Calculations
 * IP address network subnet masks, network and host portions, and provides aggregated reports.
 * Subnet mask 
 * Network portion
 * Host portion
 * Number of IP addresses in the network
 * Number of addressable hosts in the network
 * IP address range
 * Broadcast address
Provides each data in dotted quads, hexadecimal, and binary formats, as well as array of quads.

### Aggregated Network Calculation Reports
 * Hash
 * JSON
 * String
 * Printed to STDOUT

Usage
-----

### Create New Net::Subnet_Calculator Object
```perl
# For network 192.168.112.203/23
my $sub = Net::Subnet_Calculator->new( '192.168.112.203', 23 );
```

### Get Various Network Information
```perl
my $number_ip_addrssses = $sub->get_number_ip_addresses();    # 512
my $number_hosts = $sub->get_number_addressable_hosts();    # 510
my ( $lower, $upper ) = $sub->get_ip_address_range();    # ( 192.168.112.0, 192.168.113.255 )
my $network_size = $sub->get_network_size();    # 23
my $broadcast_address = $sub->get_broadcast_address();    # 192.168.113.255
```

### Get IP Address
```perl
my $ip_address = $sub->get_io_address();    # 192.168.112.203
my @ip_address_quads = $sub->get_ip_address_quads();    # ( 192, 168, 112, 203 )
my $ip_address_hex = $sub->get_ip_address_hex();    # C0A870CB
my $ip_address_binary = $sub->get_ip_address_binary();    # 11000000101010000111000011001011
```

### Get Subnet Mask
```perl
my $subnet_mask = $sub->get_subnet_mask();    # 255.255.254.0
my @subnet_mask_quads = $sub->get_subnet_mask_quads();    # ( 255, 255, 254, 0 )
my $subnet_mask_hex = $sub->get_subnet_mask_hex();    # FFFFFE00
my $subnet_mask_binary = $sub->get_subnet_mask_binary();    # 11111111111111111111111000000000
```

### Get Network Portion
```perl
my $network = $sub->get_network_portion();    # 192.168.112.0
my @network_quads = $sub->get_network_portion_quads();    # ( 192, 168, 112, 0 )
my $network_hex = $sub->get_network_portion_hex();    # C0A87000
my $network_binary = $sub->get_network_portion_binary();    # 11000000101010000111000000000000
```

### Get Host Portion
```perl
my $host = $sub->get_host_portion();    # 0.0.0.203
my @host_quads = $sub->get_host_portion_quads();    # ( 0, 0, 0, 203 )
my $host_hex = $sub->get_host_portion_hex();    # 000000CB
my $host_binary = $sub->get_host_portion_binary();    # 00000000000000000000000011001011
```

### Reports
```perl
# Hash Report
$sub->get_subnet_hash_report();
# {
#     'network_portion' => {
#                            'quads' => '192.168.112.0',
#                            'binary' => '11000000101010000111000000000000',
#                            'hex' => 'C0A87000'
#                          },
#     'subnet_mask' => {
#                        'hex' => 'FFFFFE00',
#                        'binary' => '11111111111111111111111000000000',
#                        'quads' => '255.255.254.0'
#                      },
#     'ip_address' => {
#                       'binary' => '11000000101010000111000011001011',
#                       'quads' => '192.168.112.203',
#                       'hex' => 'C0A870CB'
#                     },
#     'ip_address_range'             => '192.168.112.0-192.168.113.255',
#     'network_size'                 => 23,
#     'number_of_ip_addresses'       => '512',
#     'broadcast_address'            => '192.168.113.255',
#     'ip_address_with_network_size' => '192.168.112.203/23',
#     'host_portion' => {
#                         'hex' => '000000CB',
#                         'quads' => '0.0.0.203',
#                         'binary' => '00000000000000000000000011001011'
#                       },
#     'number_of_addressable_hosts' => 510
# };

# JSON Report
$sub->get_subnet_json_report();
# {
#     "ip_address_with_network_size": "192.168.112.203/23",
#     "ip_address": {
#         "quads": "192.168.112.203",
#         "hex": "C0A870CB",
#         "binary": "11000000101010000111000011001011"
#     },
#     "subnet_mask": {
#         "quads": "255.255.254.0",
#         "hex": "FFFFFE00",
#         "binary": "11111111111111111111111000000000"
#     },
#     "network_portion": {
#         "quads": "192.168.112.0",
#         "hex": "C0A87000",
#         "binary": "11000000101010000111000000000000"
#     },
#     "host_portion": {
#         "quads": "0.0.0.203",
#         "hex": "000000CB",
#         "binary": "00000000000000000000000011001011"
#     },
#     "network_size": 23,
#     "number_of_ip_addresses": 512,
#     "number_of_addressable_hosts": 510,
#     "ip_address_range": [
#         "192.168.112.0",
#         "192.168.113.255"
#     ],
#     "broadcast_address": "192.168.113.255"
# }

# String Report
$printable_report = $sub->get_printable_report();
# 192.168.112.203/23           Quads      Hex                           Binary
# ------------------ --------------- -------- --------------------------------
# IP Address:        192.168.112.203 C0A870CB 11000000101010000111000011001011
# Subnet Mask:         255.255.254.0 FFFFFE00 11111111111111111111111000000000
# Network Portion:     192.168.112.0 C0A87000 11000000101010000111000000000000
# Host Portion:            0.0.0.203 000000CB 00000000000000000000000011001011
# 
# Number of IP Addresses:      512
# Number of Addressable Hosts: 510
# IP Address Range:            192.168.112.0 - 192.168.113.255
# Broadcast Address:           192.168.113.255

# Printing report to STDOUT.
$sub->print_subnet_report();
# 192.168.112.203/23           Quads      Hex                           Binary
# ------------------ --------------- -------- --------------------------------
# IP Address:        192.168.112.203 C0A870CB 11000000101010000111000011001011
# Subnet Mask:         255.255.254.0 FFFFFE00 11111111111111111111111000000000
# Network Portion:     192.168.112.0 C0A87000 11000000101010000111000000000000
# Host Portion:            0.0.0.203 000000CB 00000000000000000000000011001011
# 
# Number of IP Addresses:      512
# Number of Addressable Hosts: 510
# IP Address Range:            192.168.112.0 - 192.168.113.255
# Broadcast Address:           192.168.113.255
```