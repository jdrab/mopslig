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

my $build_id_file = '../data/build-id';
unless ( -f $build_id_file ) {
    print "Missing build-id file\n";
    exit(1);
}

my $extraction_hashes_file = '../data/extraction-hashes.txt';

my $validate_template_file = '../templates/validate-lic.template';
my $validate_file          = '../tmp/validate-lic.tmp';
my $validate_binary        = '../build/validate-lic';

unless ( -f $validate_template_file || -f $extraction_hashes_file ) {
    print "Missing validate-lic.template or extraction-hashes file.\n";
    exit(1);
}

my $validate_content = path($validate_template_file)->slurp_utf8;
my $extraction_hashes = path($extraction_hashes_file)->slurp_utf8;

my $build_id = path($build_id_file)->slurp_utf8;

$validate_content =~ s/"MOPSLIG_BUILD_ID"/"$build_id"/g;
$validate_content =~ s/MOPSLIG_EXTRACTION_HASHES/$extraction_hashes/g;

path($validate_file)->spew_utf8( $validate_content );

my @build_args = (
    "pp", "-a=./lib/", "-f=PodStrip", "./" . $validate_file,
    "--output=$validate_binary", "-z=9"
);

unless ( system(@build_args) == 0 ) {
    print "Unable to build: $? \n";
    exit(1);
}
exit(0);
