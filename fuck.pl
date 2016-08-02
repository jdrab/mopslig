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

use Crypt::PBKDF2;
use File::Slurp;
use Crypt::PBKDF2::Hash::HMACSHA2;
use Getopt::Long;

my $hash_class = 'HMACSHA2';
my $sha_size   = 512;
my $salt_len   = 10;
my @balik_data;
my $prefix = '{X-PBKDF2}HMACSHA2+512:AAAD6A:';

my $pbkdf2 = Crypt::PBKDF2->new(
    hash_class => $hash_class,
    hash_args  => { sha_size => $sha_size },
    salt_len   => $salt_len
);
use Data::Dumper;

print Dumper(
    $pbkdf2->validate(
        "{X-PBKDF2}HMACSHA2+512:AAAD6A:5I/XEEV3fpmz1Q==:2RM2pQcojelJuV5OIyrSwJMX+9HSCCipux22WxgCM4o/FyNn8WprooBd3mNIviziL+3Mz09vuwZXk+7OrDBxcw==",
        "PREMIUM-KN5W-77DX-C4FG-KT5Z"
    )
);

