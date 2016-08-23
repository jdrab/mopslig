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

my $verify_file_tpl = 'verify-key.template';
unless ( -f $verify_file_tpl ) {
    print "Missing veirify.template\n";
    exit(1);
}

my $verify_file   = 'verify-key.tmp';
my $verify_binary = 'verify-key';
my $build_id_file = 'data/build-id';
unless ( -f $build_id_file ) {
    print "Missing build id file\n";
    exit(1);
}

my $verify_hashes_file = 'data/verify-hashes.txt';

unless ( -f $verify_hashes_file ) {
    print "Missing verify hashes or extraction keys file.\n";
    exit(1);
}

my $build_id       = File::Slurp::read_file($build_id_file);
my $verify_content = File::Slurp::read_file($verify_file_tpl);
my $verify_hashes  = File::Slurp::read_file($verify_hashes_file);

$verify_content =~ s/"MOPSLIG_BUILD_ID"/"$build_id"/g;
$verify_content =~ s/MOPSLIG_VERIFY_HASHES/$verify_hashes/g;

File::Slurp::write_file( $verify_file, $verify_content );

my @build_args = (
    "pp",                      "-a=lib/",
    "-f=PodStrip",             "./" . $verify_file,
    "--output=$verify_binary", "-z=9"
);

unless ( system(@build_args) == 0 ) {
    print "Unable to build: $? \n";
    exit(1);
}
exit(0);