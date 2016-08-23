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
my $build_id = path($build_id_file)->slurp_utf8;
chomp($build_id);

my $lic_generator_template = '../templates/client-lic.template';
my $lic_generator_binary   = '../build/client-lic';
my $lic_generator_file     = '../tmp/client-lic.tmp';
my $config                 = '../config.json';

unless ( -f $config || -f $lic_generator_template ) {
    print "Missing config file or client license template file.\n";
    exit(1);
}

my $config_content = path($config)->slurp_utf8;
my $lic_content    = path($lic_generator_template)->slurp_utf8;

$lic_content =~ s/"MOPSLIG_BUILD_ID"/"$build_id"/g;
$lic_content =~ s/MOPSLIG_LICSENSE_CONFIG/$config_content/g;

path($lic_generator_file)->spew_utf8($lic_content);

my @build_args = (
    "pp", "-a=../lib/", "-f=PodStrip",
    "./" . $lic_generator_file,
    "--output=$lic_generator_binary", "-z=9"
);

unless ( system(@build_args) == 0 ) {
    print "Unable to build: $? \n";
    exit(1);
}
exit(0);
