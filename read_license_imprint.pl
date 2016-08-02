#!/usr/bin/env perl
use warnings;
use strict;
use Crypt::CBC;
use Crypt::Rijndael;
use File::Slurp;

my $key_file = './key.lic';
my $imprint_file = './imprint.lic';

unless(-f $key_file) {
    print "Key file does not exit\n";
    exit(1);
}

unless(-f $imprint_file) {
    print "License imprint file is missing.\n";
    exit(1);
}

my $key = File::Slurp::read_file($key_file);

my $cipher   = Crypt::CBC->new(
    -key    => $key,
    -cipher => "Crypt::Rijndael"
);


my $imprint = File::Slurp::read_file($imprint_file,binmode=>':raw');
my $dec = $cipher->decrypt($imprint);
print $dec;
