use strict;
use warnings;

BEGIN { push @INC, q{../../}; }

use Readonly;
use English ( -no_match_vars );
use Test::More tests => 42;

# #############################################################################
# Precalculated constants for testing network 192.168.112.203/23.
# #############################################################################

Readonly my $IP_ADDRESS               => '192.168.112.203';
Readonly my $NETWORK_SIZE             => 23;
Readonly my $NUMBER_IP_ADDRESSES      => 512;
Readonly my $NUMBER_ADDRESSABLE_HOSTS => 510;
Readonly my $LOWER_IP_ADDRESS_RANGE   => '192.168.112.0';
Readonly my $UPPER_IP_ADDRESS_RANGE   => '192.168.113.255';
Readonly my $BROADCAST_ADDRESS        => '192.168.113.255';
Readonly my $IP_ADDRESS_HEX           => 'C0A870CB';
Readonly my $IP_ADDRESS_BINARY        => '11000000101010000111000011001011';
Readonly my $SUBNET_MASK              => '255.255.254.0';
Readonly my $SUBNET_MASK_HEX          => 'FFFFFE00';
Readonly my $SUBNET_MASK_BINARY       => '11111111111111111111111000000000';
Readonly my $NETWORK                  => '192.168.112.0';
Readonly my $NETWORK_HEX              => 'C0A87000';
Readonly my $NETWORK_BINARY           => '11000000101010000111000000000000';
Readonly my $HOST                     => '0.0.0.203';
Readonly my $HOST_HEX                 => '000000CB';
Readonly my $HOST_BINARY              => '00000000000000000000000011001011';

# #############################################################################
# Test package.
# #############################################################################

require_ok('Net::Subnet_Calculator');
can_ok(
    'Net::Subnet_Calculator', qw(
      new
      get_ip_address
      get_network_size
      get_number_ip_addresses
      get_number_addressable_hosts
      get_ip_address_range
      get_broadcast_address
      get_ip_address_quads
      get_ip_address_hex
      get_ip_address_binary
      get_subnet_mask
      get_subnet_mask_quads
      get_subnet_mask_hex
      get_subnet_mask_binary
      get_network_portion
      get_network_portion_quads
      get_network_portion_hex
      get_network_portion_binary
      get_host_portion
      get_host_portion_quads
      get_host_portion_hex
      get_host_portion_binary
      get_subnet_hash_report
      get_subnet_json_report
      get_printable_report
      print_subnet_report
    )
);

# #############################################################################
# Test class.
# #############################################################################

my $sub = Net::Subnet_Calculator->new( $IP_ADDRESS, $NETWORK_SIZE );
isa_ok( $sub, 'Net::Subnet_Calculator' );

# #############################################################################
# Test exceptions from validation of bad input parameters.
# #############################################################################

eval { my $sub2 = Net::Subnet_Calculator->new( '555.444.333.222', 23 ) };
like( $EVAL_ERROR, qr/is not a valid IPv4 address/ms, 'Exception (died) on bad IP address input parameter.' );
eval { my $sub2 = Net::Subnet_Calculator->new( '192.168.112.203', 40 ) };
like( $EVAL_ERROR, qr/is not a valid network size/ms, 'Exception (died) on bad network size input parameter.' );

# #############################################################################
# Test input parameters.
# #############################################################################

is( $sub->get_ip_address(),   $IP_ADDRESS,   'IP address.' );
is( $sub->get_network_size(), $NETWORK_SIZE, 'Network size.' );

# #############################################################################
# Test various IPv4 calculations.
# #############################################################################

is( $sub->get_number_ip_addresses,      $NUMBER_IP_ADDRESSES,      'Number of IP addresses.' );
is( $sub->get_number_addressable_hosts, $NUMBER_ADDRESSABLE_HOSTS, 'Number of addressable hosts.' );
is( ( $sub->get_ip_address_range() )[0], $LOWER_IP_ADDRESS_RANGE, 'Lower IP address range.' );
is( ( $sub->get_ip_address_range() )[1], $UPPER_IP_ADDRESS_RANGE, 'Upper IP address range.' );
is( $sub->get_broadcast_address(), $BROADCAST_ADDRESS, 'Broadcast address.' );

# #############################################################################
# Test IP address calculations.
# #############################################################################

foreach ( 0 .. 3 ) {
    is( ( $sub->get_ip_address_quads() )[$_], ( split /[.]/, $IP_ADDRESS )[$_], 'IP address as dotted quads section ' . ( $_ + 1 ) . q{.} );
}
is( $sub->get_ip_address_hex,    $IP_ADDRESS_HEX,    'IP address as hex.' );
is( $sub->get_ip_address_binary, $IP_ADDRESS_BINARY, 'IP address as binary.' );

# #############################################################################
# Test subnet calculations.
# #############################################################################

foreach ( 0 .. 3 ) {
    is( ( $sub->get_subnet_mask_quads() )[$_], ( split /[.]/, $SUBNET_MASK )[$_], 'Subnet mask as dotted quads section ' . ( $_ + 1 ) . q{.} );
}
is( $sub->get_subnet_mask,        $SUBNET_MASK,        'Subnet mask.' );
is( $sub->get_subnet_mask_hex,    $SUBNET_MASK_HEX,    'Subnet mask as hex.' );
is( $sub->get_subnet_mask_binary, $SUBNET_MASK_BINARY, 'Subnet mask as binary' );

# #############################################################################
# Test network portion calculations.
# #############################################################################

foreach ( 0 .. 3 ) {
    is( ( $sub->get_network_portion_quads() )[$_], ( split /[.]/, $NETWORK )[$_], 'Network portion as dotted quads section ' . ( $_ + 1 ) . q{.} );
}
is( $sub->get_network_portion,        $NETWORK,        'Network portion.' );
is( $sub->get_network_portion_hex,    $NETWORK_HEX,    'Network portion as hex.' );
is( $sub->get_network_portion_binary, $NETWORK_BINARY, 'Network portion as binary.' );

# #############################################################################
# Test host portion calculations.
# #############################################################################

foreach ( 0 .. 3 ) {
    is( ( $sub->get_host_portion_quads() )[$_], ( split /[.]/, $HOST )[$_], 'Host portion as dotted quads section ' . ( $_ + 1 ) . q{.} );
}
is( $sub->get_host_portion,        $HOST,        'Host portion.' );
is( $sub->get_host_portion_hex,    $HOST_HEX,    'Host portion as hex.' );
is( $sub->get_host_portion_binary, $HOST_BINARY, 'Host portion as binary.' );

# #############################################################################
# Test reports.
# #############################################################################

is( ref $sub->get_subnet_hash_report(),  'HASH',   'Subnet has report is a hash.' );
is( ref \$sub->get_subnet_json_report(), 'SCALAR', 'Subnet JSON report is a string.' );
is( ref \$sub->get_printable_report(),   'SCALAR', 'Printable report is a string.' );