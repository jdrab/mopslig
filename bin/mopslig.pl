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

use Data::Dumper;
use JSON::XS;
use Getopt::Long;

use Path::Tiny qw(path);
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname( abs_path $0) . '/lib';

use Mopslig::Generator;
use Mopslig::Helper;

#FIXME: merge with config or create another or maybe just use getopts
my $_dir                    = 'data';
my $_file_full              = $_dir . '/full.txt';
my $_serials_full           = $_dir . '/serials.txt';
my $_verify_hashes_full     = $_dir . '/verify-hashes.txt';
my $_extraction_keys_full   = $_dir . '/extraction-keys.txt';
my $_extraction_hashes_full = $_dir . '/extraction-hashes.txt';

my $_product_prefix  = $_dir . '/';
my $_product_postfix = '-full.txt';

my $default_license_key = 'START-DE12-FA34-UL56-T789';

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

=head2 debug

Kind of retarded "debug" or verbose mode

=cut

sub _debug {
    print "\nDebug: @_\n" if $debug;
}

unless ( $ARGV[0] && $ARGV[0] eq 'sure' ) {
    print
        qq(\nAre you sure?\n\nYour files will be OVERWRITEN.\nSettings are read from ./config.json file.\nIf you're really sure you want to generate NEW serial numbers and hashes, please say 'sure'.\n);

    usage();
    exit 1;
}

# Create directory where generated files will be stored
unless ( -d $_dir ) {
    system( "mkdir", "-p", $_dir );
}


# Print usage
sub usage {
    print "\nUsage:\t $0 sure \t--no-dots\t--debug\n\n";
}

# read license packages config
my $products     = path('./config.json')->slurp_utf8;
my $product_data = JSON::XS->new->utf8->decode($products);

my $amount_of_keys = 0;

# get amount of license keys in each 'package'
map { $amount_of_keys = $amount_of_keys + $_ }
    values( %{ $product_data->{licenses}{amounts} } );

_debug("Will generate hashes for $amount_of_keys keys");

my @all_serials;

my $cycle        = 0;
my $in_one_cycle = 1;
my $counter      = 1;

while ( $counter < $amount_of_keys ) {
    $cycle++;
    push( @all_serials,
        Mopslig::Generator::generate_keys( $in_one_cycle, 16, $nodots ) );
    @all_serials = Mopslig::Helper::uniq(@all_serials);

    # check if there is already enough unique keys
    $counter = scalar(@all_serials);
}

my %data;
my @full;
my @full_serials;
my @full_verify_hashes;
my @full_extraction_keys;
my @full_extraction_hashes;

foreach my $key ( keys( %{ $product_data->{licenses}{types} } ) ) {

    # get generated keys for this package
    my @serials_for_package
        = splice( @all_serials, 0, $product_data->{licenses}{amounts}{$key} );

    _debug("Generating hashes for package $key");
    my @package_data = Mopslig::Generator::generate_hashes_for_package(
        \@serials_for_package, uc "$key-", $nodots );

    my ( @serials, @verify_hashes, @extraction_keys, @extraction_hashes );
    map {
        my ( $s, $h, $ek, $eh ) = split( "\t", $_ );
        push( @serials,           $s );
        push( @verify_hashes,     $h );
        push( @extraction_keys,   $ek );
        push( @extraction_hashes, $eh );
    } @package_data;

    if ($debug) {
        $data{$key}{serials}           = \@serials;
        $data{$key}{verify_hashes}     = \@verify_hashes;
        $data{$key}{extraction_keys}   = \@extraction_keys;
        $data{$key}{extraction_hashes} = \@extraction_hashes;
    }

    _debug(
        "Writing to file " . $_product_prefix . $key . $_product_postfix );

    path( $_product_prefix . $key . $_product_postfix )
        ->spew_utf8( join( "\n", @package_data ) );

    push( @full,                   @package_data );
    push( @full_serials,           @serials );
    push( @full_verify_hashes,     @verify_hashes );
    push( @full_extraction_keys,   @extraction_keys );
    push( @full_extraction_hashes, @extraction_hashes );
}

my @splited_default = split( '-', $default_license_key );
my @default_key = ( join( '-', splice( @splited_default, 1 ) ) );
my @default_package_data
    = Mopslig::Generator::generate_hashes_for_package( \@default_key,
    $splited_default[0] . "-" );

my ( @d_serials, @d_verify_hashes, @d_extraction_keys, @d_extraction_hashes );
map {
    my ( $s, $h, $ek, $eh ) = split( "\t", $_ );
    push( @d_serials,           $s );
    push( @d_verify_hashes,     $h );
    push( @d_extraction_keys,   $ek );
    push( @d_extraction_hashes, $eh );
} @default_package_data;

push( @full,                   @default_package_data );
push( @full_verify_hashes,     @d_verify_hashes );
push( @full_extraction_keys,   @d_extraction_keys );
push( @full_extraction_hashes, @d_extraction_hashes );

print "\n" unless $nodots;

path($_file_full)->spew_utf8( join( "\n", @full ) );

path($_serials_full)->spew_utf8( join( "\n", @full_serials ) );

@full_verify_hashes = shuffle(@full_verify_hashes);

path($_verify_hashes_full)->spew_utf8( join( "\n", @full_verify_hashes ) );

@full_extraction_keys = shuffle(@full_extraction_keys);
path($_extraction_keys_full)
    ->spew_utf8( join( "\n", @full_extraction_keys ) );

@full_extraction_hashes = shuffle(@full_extraction_hashes);
path($_extraction_hashes_full)
    ->spew_utf8( join( "\n", @full_extraction_hashes ) );

path( $_dir . '/build-id' )->spew_utf8(localtime);

_debug( "Data:\n" . Dumper( \%data ) );
exit(0);
