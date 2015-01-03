package Net::Subnet_Calculator;
our $VERSION = 1.0;

use strict;
use warnings;
use 5.010;

use Regexp::Common;
use JSON::XS;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->_initialize(@_);
    return $self;
}

sub _initialize {
    my ( $self, $ip, $network_size ) = @_;
    $self->_validate_input( $ip, $network_size );
    $self->{ip}           = $ip;
    $self->{network_size} = $network_size;
    $self->{quads}        = [ split /[.]/, $ip ];
    $self->{subnet_mask}  = 0xFFFFFFFF << ( 32 - $network_size );
}

sub _validate_input {
    my ( $self, $ip, $network_size ) = @_;
    die "$ip is not a valid IPv4 address." unless $ip =~ m/$RE{net}{IPv4}/;
    die "$network_size is not a valid network size." unless ( ( $network_size > 0 ) && ( $network_size <= 32 ) );
}

sub get_ip_address {
    my $self = shift;
    return $self->{ip};
}

sub get_network_size {
    my $self = shift;
    return $self->{network_size};
}

sub get_number_ip_addresses {
    my $self = shift;
    return 2**( 32 - $self->{network_size} );
}

sub get_number_addressable_hosts {
    my $self = shift;
    return 1 if $self->{network_size} == 32;
    return 2 if $self->{network_size} == 31;
    return $self->get_number_ip_addresses() - 2;
}

sub get_ip_address_range {
    my $self = shift;
    return ( $self->get_network_portion(), $self->get_broadcast_address() );
}

sub get_broadcast_address {
    my $self                = shift;
    my @network_quads       = $self->get_network_portion_quads();
    my $number_ip_addresses = $self->get_number_ip_addresses();
    return join q{.}, map {
        sprintf( '%d',
            ( $network_quads[$_] & ( $self->{subnet_mask} >> ( 24 - ( 8 * $_ ) ) ) ) +
            ( ( ( $number_ip_addresses - 1 ) >> ( 24 - ( 8 * $_ ) ) ) & 0xFF )
        )
    } 0 .. 3;
}

sub get_ip_address_quads {
    my $self = shift;
    return @{ $self->{quads} };
}

sub get_ip_address_hex {
    my $self = shift;
    return join q{}, map { sprintf '%02X', $_ } @{ $self->{quads} };
}

sub get_ip_address_binary {
    my $self = shift;
    return join q{}, map { sprintf '%08b', $_ } @{ $self->{quads} };
}

sub get_subnet_mask {
    my $self = shift;
    return join q{.}, $self->_subnet_calculation('%d');
}

sub get_subnet_mask_quads {
    my $self = shift;
    return split /[.]/, $self->get_subnet_mask();
}

sub get_subnet_mask_hex {
    my $self = shift;
    return join q{}, $self->_subnet_calculation('%02X');
}

sub get_subnet_mask_binary {
    my $self = shift;
    return join q{}, $self->_subnet_calculation('%08b');
}

sub get_network_portion {
    my $self = shift;
    return join q{.}, $self->_network_calculation('%d');
}

sub get_network_portion_quads {
    my $self = shift;
    return split /[.]/, $self->get_network_portion();
}

sub get_network_portion_hex {
    my $self = shift;
    return join q{}, $self->_network_calculation('%02X');
}

sub get_network_portion_binary {
    my $self = shift;
    return join q{}, $self->_network_calculation('%08b');
}

sub get_host_portion {
    my $self = shift;
    return join q{.}, $self->_host_calculation('%d');
}

sub get_host_portion_quads {
    my $self = shift;
    return split /[.]/, $self->get_host_portion();
}

sub get_host_portion_hex {
    my $self = shift;
    return join q{}, $self->_host_calculation('%02X');
}

sub get_host_portion_binary {
    my $self = shift;
    return join q{}, $self->_host_calculation('%08b');
}

sub get_subnet_hash_report {
    my $self = shift;
    return {
        ip_address_with_network_size => $self->get_ip_address() . q{/} . $self->get_network_size(),
        ip_address                   => {
            quads  => $self->get_ip_address(),
            hex    => $self->get_ip_address_hex(),
            binary => $self->get_ip_address_binary(),
        },
        subnet_mask => {
            quads  => $self->get_subnet_mask(),
            hex    => $self->get_subnet_mask_hex(),
            binary => $self->get_subnet_mask_binary(),
        },
        network_portion => {
            quads  => $self->get_network_portion(),
            hex    => $self->get_network_portion_hex(),
            binary => $self->get_network_portion_binary(),
        },
        host_portion => {
            quads  => $self->get_host_portion(),
            hex    => $self->get_host_portion_hex(),
            binary => $self->get_host_portion_binary(),
        },
        network_size                => $self->get_network_size(),
        number_of_ip_addresses      => $self->get_number_ip_addresses(),
        number_of_addressable_hosts => $self->get_number_addressable_hosts(),
        ip_address_range            => ( join q{-}, $self->get_ip_address_range() ),
        broadcast_address           => $self->get_broadcast_address(),
    };
}

sub get_subnet_json_report {
    my $self = shift;
    return encode_json( $self->get_subnet_hash_report() );
}

sub get_printable_report {
    my $self = shift;
    return $self->_to_string();
}

sub print_subnet_report {
    my $self = shift;
    print $self->_to_string();
    return;
}

sub _subnet_calculation {
    my ( $self, $format ) = @_;
    return map { sprintf $format, ( ( $self->{subnet_mask} >> $_ ) & 0xFF ) } qw( 24 16 8 0 );
}

sub _network_calculation {
    my ( $self, $format ) = @_;
    return map { sprintf $format, ( $self->{quads}->[$_] & ( $self->{subnet_mask} >> 24 - ( 8 * $_ ) ) ) } 0 .. 3;
}

sub _host_calculation {
    my ( $self, $format ) = @_;
    return map { sprintf $format, ( $self->{quads}->[$_] & ~( $self->{subnet_mask} >> 24 - ( 8 * $_ ) ) ) } 0 .. 3;
}

sub _to_string {
    my $self = shift;
    my $string;
    $string .= sprintf( "%-18s %15s %8s %32s\n", "$self->{ip}/$self->{network_size}", 'Quads',                      'Hex',                            'Binary' );
    $string .= sprintf( "%-18s %15s %8s %32s\n", '------------------',                '---------------',            '--------',                       '--------------------------------' );
    $string .= sprintf( "%-18s %15s %8s %32s\n", 'IP Address:',                       $self->get_ip_address(),      $self->get_ip_address_hex(),      $self->get_ip_address_binary() );
    $string .= sprintf( "%-18s %15s %8s %32s\n", 'Subnet Mask:',                      $self->get_subnet_mask(),     $self->get_subnet_mask_hex(),     $self->get_subnet_mask_binary() );
    $string .= sprintf( "%-18s %15s %8s %32s\n", 'Network Portion:',                  $self->get_network_portion(), $self->get_network_portion_hex(), $self->get_network_portion_binary() );
    $string .= sprintf( "%-18s %15s %8s %32s\n", 'Host Portion:',                     $self->get_host_portion(),    $self->get_host_portion_hex(),    $self->get_host_portion_binary() );
    $string .= "\n";
    $string .= sprintf( "%-28s %d\n", 'Number of IP Addresses:',      $self->get_number_ip_addresses() );
    $string .= sprintf( "%-28s %d\n", 'Number of Addressable Hosts:', $self->get_number_addressable_hosts() );
    $string .= sprintf( "%-28s %s\n", 'IP Address Range:',            join q{-}, $self->get_ip_address_range() );
    $string .= sprintf( "%-28s %s\n", 'Broadcast Address:',           $self->get_broadcast_address() );
    return $string;
}

1;
__END__

=head1 NAME

Net::Subnet_Calculator - IPv4 Network calculator for subnet mask and other classless (CIDR) network information.

=head1 SYNOPSIS

    use Net::Subnet_Calculator
    
    # Constructor takes two arguments: IP address and network wize.
    my $sub = Net::Subnet_Calculator->new( '192.168.112.203', '23' );
    
    # General IPv4 network information.
    my $num_ips   = $sub->get_number_ip_addresses();
    my $num_hosts = $sub->get_number_addressable_hosts();
    my $broadcast_address = $sub->get_broadcast_address();
    my ( $first_ip, $last_ip ) = $sub->get_ip_address_range();
    
    # IP address calculations.
    my $ip        = $sub->get_ip_address();
    my @ip_quads  = $sub->get_ip_address_quads
    my $ip_hex    = $sub->get_ip_address_hex();
    my $ip_binary = $sub->get_ip_address_binary();
    
    # Subnet mask calculations.
    my $subnet        = $sub->get_subnet_mask();
    my @subnet_quads  = $sub->get_subnet_mask_quads();
    my $subnet_hex    = $sub->get_subnet_mask_hex();
    my $subnet_binary = $sub->get_subnet_mask_binary();
    
    # Network calulations.
    my $network        = $sub->get_network_portion();
    my @network_quads  = $sub->get_network_portion_quads();
    my $network_hex    = $sub->get_network_portion_hex();
    my $network_binary = $sub->get_network_portion_binary();
    
    # Host calculations.
    my $host        = $sub->get_host_portion();
    my @host_quads  = $sub->get_host_portion_quads();
    my $host_hex    = $sub->get_host_portion_hex();
    my $host_binary = $sub->get_host_portion_binary();
    
    # Reports
    my $hash_report      = $sub->get_subnet_hash_report();
    my $json_report      = $sub->get_subnet_json_report();
    my $printable_report = $sub->get_printable_report();
    $sub->print_subnet_report();

=head1 DESCRIPTION

Given an IP address and size of network, you can calculate the number of IP addresses, number of hosts, 
broadcast address, address range, and subnet masks, the network portion, host portion, IP address in 
dotted quads, hex, binary, and array formats.

Reports available in printable, JSON, and hash formats.

=head2 Methods

=over 4

=item C<new>

Returns a new Net::Subnet_Calculator object.

=item C<get_ip_address>

Returns the IP address as a dotted quad string.

=item C<get_network_size>

Returns the network size.

=item C<get_number_ip_addresses>

Returns the number of IP addresses.

=item C<get_number_addressable_hosts>

Returns the number of addressable hosts.

=item C<get_ip_address_range>

Returns a two element list containing the start and end of the range of IP addresses.

=item C<get_broadcast_address>

Returns the IP address of the broadcast address in the network.

=item C<get_ip_address_quads>

Returns a four-element array containing each of the dotted quads of the IP address.

=item C<get_ip_address_hex>

Returns the IP address as a hex string.

=item C<get_ip_address_binary>

Returns the IP address as a binary number string.

=item C<get_subnet_mask>

Returns the subnet mask as a dotted quads string.

=item C<get_subnet_mask_quads>

Returns a four-element array containing each of the dotted quads of the subnet mask.

=item C<get_subnet_mask_hex>

Returns the subnet mask as a hex string.

=item C<get_subnet_mask_binary>

Returns the subnet mask as a binary number string.

=item C<get_network_portion>

Returns the network portion as a dotted quads string.

=item C<get_network_portion_quads>

Returns a four-element array containing each of the dotted quads of the network portion.

=item C<get_network_portion_hex>

Returns the network portion as a hex string.

=item C<get_network_portion_binary>

Returns the network portion as a binary number string.

=item C<get_subnet_hash_report>

Returns a hash of all the subnet calculations that this class provides.

=item C<get_subnet_json_report>

Returns a JSON string of all the subnet calculations that this class provides.

=item C<get_printable_report>

Returns a string containing all the subnet calculations that this class provides.

=item C<print_subnet_report>

Prints a nicely formatted report containing all the subnet calculations that this class provides.

=back

=head1 AUTHOR

Mark Rogoyski - L<http://markrogoyski.com>

=cut