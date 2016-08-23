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
use File::Slurp;
use JSON::XS;

my $key_file       = './key.lic';
my $imprint_file 	= './imprint.lic';

my $verify_key_bin = './verify-key';
my $imprint_lic_bin = './imprint-lic';
my $client_lic_bin      = './client-lic';
my $client_license_file = './client.lic';

my $validate_lic_bin = './validate-lic';

unless( -f $key_file ) {
	print "Missing key.lic file, plese fix it\n";
	exit;
}

#unless( -f $imprint_file) {
#	print "Missing imprint.lic file.\nPlease run\n./validate-lic --validate";
#	exit;
#}

my $key = File::Slurp::read_file($key_file);

chomp($key);

system( $verify_key_bin, "--key", $key ) == 0
    or die( "KEY WAS NOT VERIFIED -- error code: " . ( $? >> 8 ) . " \n" );
print "KEY VERIFIED -- $key\n";

system( $client_lic_bin, '--key', $key, '--generate', '--output',
    $client_license_file ) == 0
    or die(
    "LICENSE FILE WAS NOT GENERATED -- error code: " . ( $? >> 8 ) . " \n" );
print "LICENSE FILE GENERATED -- $client_license_file\n";


system( $validate_lic_bin, '--key', $key, '--license', $client_license_file,
    '--validate' ) == 0
    or die( "CLIENT LICENSE WAS NOT VALIDATED -- error code: "
        . ( $? >> 8 )
        . " \n" );
print
    "CLIENT LICENSE VALIDATED -- $client_license_file validated against key $key \n";

unless( -f $imprint_file) {
	print "Missing imprint.lic file.\nPlease run\n./validate-lic --validate";
	exit;
}

system( $imprint_lic_bin, "--key", $key, '--imprint-file', $imprint_file) == 0
	or die("UNABLE TO READ LICENSE IMPRINT");

print "\nDone\n";
