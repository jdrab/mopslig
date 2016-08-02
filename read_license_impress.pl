#!/usr/bin/perl env
use warnings;
use strict;
use Crypt::CBC;
use Crypt::Rijndael;

my $key_file = './key.lic';
my $impress_file = './impress.lic';

my $cipher   = Crypt::CBC->new(
    -key    => $key,
    -cipher => "Crypt::Rijndael"
);

unless ($license_file) {
    unless ( -f $lic_file ) {
        exit(3);
    }
    $license_file = $lic_file;
}

my $enc_lic = File::Slurp::read_file( $license_file, binmode => ':raw' );

my $dec = $cipher->decrypt($enc_lic);
