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
my $build_id_file = 'data/build-id';
my $extraction_hashes_file = 'data/extraction-hashes.txt';

my $validate_template_file = 'validate-lic.pl';
my $validate_file = 'validate.pl';
my $validate_binary = 'validate-lic';


my $build_id = File::Slurp::read_file($build_id_file);
my $validate_content = File::Slurp::read_file($validate_template_file);

my $extraction_hashes = File::Slurp::read_file($extraction_hashes_file);

$validate_content =~ s/"MOPSLIG_BUILD_ID"/"$build_id"/g;
$validate_content =~ s/MOPSLIG_EXTRACTION_HASHES/$extraction_hashes/g;

 File::Slurp::write_file($validate_file,$validate_content);

my @build_args = ("pp","./".$validate_file, "--output=$validate_binary");

unless ( system(@build_args) == 0 ) {
 	print "Unable to build: $? \n";
 	exit(1);
  }
  print "Done\n";
  exit(0);
