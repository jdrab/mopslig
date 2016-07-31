#!/usr/bin/env perl
#
#    This file is part of Mopslig.
#
#    Mopslig is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Mopslig is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Mopslig.  If not, see <http://www.gnu.org/licenses/>.
#

use warnings;
use strict;

use List::Util qw/shuffle/;
use Crypt::PBKDF2;
use Crypt::PBKDF2::Hash::HMACSHA2;
use File::Slurp;
use Data::Dumper;
use JSON::XS;
use Getopt::Long;
use Digest::SHA1  qw(sha1_hex);


#FIXME: merge with config or create another or maybe just use getopts
my $_dir                    = 'data';
my $_file_full              = $_dir.'/full.txt';
my $_serials_full           = $_dir.'/serials.txt';
my $_verify_hashes_full     = $_dir.'/verify-hashes.txt';
my $_extraction_keys_full = $_dir.'/extraction-keys.txt';

my $_product_prefix     = $_dir.'/';
my $_product_postfix    = '-full.txt';

=pod
 
=head1 DESCRIPTION
 
Script for generating keys and hashes

=head1 Usage

Usage: $0 
            --no-dots   - dont print progress as dots while generating 
                          keys & hashes
            --debug     - print debug messages

=cut

GetOptions(
    'no-dots' => \my $nodots,
    'debug'   => \my $debug
);

=pod
Kind of retarded "debug" or verbose mode
=cut
sub _debug {
    print "\nDebug: @_\n" if $debug;
}

=pod
Print info how to use this script if user is not "sure" :D
=cut
unless ( $ARGV[0] && $ARGV[0] eq 'sure' ) {
    print
        qq(\nAre you sure?\n\nYour files will be OVERWRITEN.\nSettings are read from ./config.json file.\nIf you're really sure you want to generate NEW serial numbers and hashes, please say 'sure'.\n);

    usage();
    exit 1;
}

=pod
Create directory where generated files will be stored
=cut
unless ( -d $_dir ) {
    system( "mkdir", "-p", $_dir );
}

=pod
Print usage
=cut
sub usage {
    print "\nUsage:\t $0 sure \t--no-dots\t--debug\n\n";
}

=pod
Generate random string - used for keys generation
=cut
sub gimme_random_string {
    my $length = shift || 6;
    my $chars = shift || [ "A" .. "Z", "a" .. "z", "0" .. "9" ];

    my $string;
    $string .= $chars->[ int rand scalar @{$chars} ] for 1 .. $length;
    return $string;
}

=pod
Generate product keys
=cut
sub generate_keys {
    my $amount         = shift || 1;
    my $how_many_chars = shift || 16;

    # By default I don't want to generate keys with
    # charactes 1 l O 0 - keys might be unreadable for users
    my @range
        = ( 2, 3, 4, 5, 6, 7, 8, 9, "A" .. "H", "J" .. "N", "P" .. "Z" );
    my @customer_serial_numbers;
    $| = 1;

    # I don't care if generated strings are unique
    foreach my $i ( 1 .. $amount ) {
        print "." unless $nodots;
        my $k = gimme_random_string( $how_many_chars, \@range );
        push( @customer_serial_numbers, join( "-", unpack( "(A4)*", $k ) ) );
    }
    return @customer_serial_numbers;
}
=pod
Create key for lic file extraction
key format: 12345-12345-12345
=cut

sub create_key_for_lic_extraction {
    my $serial = shift || croak("Missing serial number");
    ( my $shan = sha1_hex($serial) ) =~ s/[a-z]//gi;
    return join( "-", ( unpack( "(A5)*", $shan ) )[ 0 .. 2 ] );
}

=pod
What the name says
=cut
sub uniq {
    my %seen;
    return grep { !$seen{$_}++ } @_;
}
=pod
Generate hashes for license 'package'
=cut
sub generate_hashes_for_package {
    my $serials = shift || die("Need serial numbers");
    my $prefix  = shift || '';

    # don't forget to escape prehash value for regex
    my $prehash    = shift || '{X-PBKDF2}HMACSHA2\+512:AAAD6A:';
    my $hash_class = shift || 'HMACSHA2';
    my $sha_size   = shift || 512;
    my $salt_len   = shift || 10;

    my @pkg_data;

    foreach my $serial ( @{$serials} ) {
        $| = 1;
        my $pbkdf2 = Crypt::PBKDF2->new(
            hash_class => $hash_class,
            hash_args  => { sha_size => $sha_size },
            salt_len   => $salt_len
        );

        my $full = $prefix . $serial;
        my $hash = $pbkdf2->generate($full);

        $hash =~ s/^$prehash//g;
        # add hash for license extraction
        my $extractor = create_key_for_lic_extraction($serial);

        push( @pkg_data, ( $full . "\t" . $hash ."\t". $extractor) );

        print "." unless $nodots;
    }
    return @pkg_data;
}


# read license packages config
my $products = File::Slurp::read_file('./config.json');
my $product_data = JSON::XS->new->utf8->decode($products);

my $amount_of_keys = 0;
# get amount of license keys in each 'package'
map { $amount_of_keys = $amount_of_keys + $_ } values( %{ $product_data->{licenses}{amounts} } );

_debug("Will generate hashes for $amount_of_keys keys");

my @all_serials;

my $cycle          = 0;
my $in_one_cycle   = 1;
my $counter        = 1;

while ( $counter < $amount_of_keys ) {
    $cycle++;
    push( @all_serials, generate_keys( $in_one_cycle, 16 ) );
    @all_serials = uniq(@all_serials);
    # check if there is already enough unique keys
    $counter = scalar(@all_serials);
}

my %data;
my @full;
my @full_serials;
my @full_verify_hashes;
my @full_extraction_keys;
foreach my $key ( keys( %{ $product_data->{licenses}{types} } ) ) {

    # get generated keys for this package
    my @serials_for_package = splice( @all_serials, 0, $product_data->{licenses}{amounts}{$key});

    _debug("Generating hashes for package $key");
    my @package_data = generate_hashes_for_package(\@serials_for_package, uc "$key-");

    my (@serials,@verify_hashes,@extraction_keys);
    map {
        my ($s,$h,$e) = split("\t",$_);
        push(@serials,$s);
        push(@verify_hashes, $h);
        push(@extraction_keys, $e);
    } @package_data;
    
    if( $debug ) {
        $data{$key}{serials} = \@serials;
        $data{$key}{verify_hashes} = \@verify_hashes;
        $data{$key}{extraction_keys} = \@extraction_keys;
    }

    _debug( "Writing to file ".$_product_prefix.$key.$_product_postfix);
    File::Slurp::write_file($_product_prefix.$key.$_product_postfix, join("\n",@package_data));

    push(@full, @package_data);
    push(@full_serials, @serials);
    push(@full_verify_hashes, @verify_hashes);
    push(@full_extraction_keys, @extraction_keys);
}

print "\n" unless $nodots;
File::Slurp::write_file( $_file_full,    join( "\n", @full ) );
File::Slurp::write_file( $_serials_full, join( "\n", @full_serials ) );

@full_verify_hashes = shuffle(@full_verify_hashes);
File::Slurp::write_file( $_verify_hashes_full, join( "\n", @full_verify_hashes ) );

@full_extraction_keys = shuffle(@full_extraction_keys);
File::Slurp::write_file( $_extraction_keys_full, join( "\n", @full_extraction_keys ) );

File::Slurp::write_file( $_dir.'/build-id',localtime);
_debug( "CELE DATA:\n" . Dumper( \%data ) );
exit(0);
