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
use Path::Tiny qw(path);
use JSON::XS;

my $default_key     = 'START-DE12-FA34-UL56-T789';
my $key_file       = '../tmp/key.lic';
my $imprint_file 	= '../tmp/imprint.lic';

my $verify_key_bin = '../build/verify-key';
my $imprint_lic_bin = '../build/imprint-lic';
my $client_lic_bin      = '../build/client-lic';
my $client_license_file = '../tmp/client.lic';

my $validate_lic_bin = '../build/validate-lic';

unless( -f $key_file ) {
	#print "Missing key.lic file, plese fix it\n";
    print qq($key_file does not exist, creating default key $default_key\n);
	path($key_file)->spew_utf8($default_key);
}

my $key = path($key_file)->slurp_utf8;
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
    '--imprint-output',$imprint_file,
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
