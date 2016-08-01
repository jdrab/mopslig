#!/usr/bin/perl env
use warnings;
use strict;
use Getopt::Long;
use File::Slurp;
use Digest::SHA1;

use Crypt::PBKDF2;
use Crypt::PBKDF2::Hash::HMACSHA2;
use Crypt::CBC;
use Crypt::Rijndael;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname( abs_path $0) . '/lib';

use Mopslig::Generator;
use Data::Dumper;

use JSON::XS;

my $key_file = './key.lic';
my $lic_file = './client.lic';

GetOptions(
    'serial'      => \my $serial,
    'for-module'  => \my $module,
    'get-amount'  => \my $get_amount,
    'valid_until' => \my $valid_until,
    'valid-since' => \my $valid_since,
    'amount'      => \my $amount,

    #'output=s'=> \my $output,
    'build-id' => \my $build_id
);

my $build_id_val = "MOPSLIG_BUILD_ID";

if ($build_id) {
    print $build_id_val. "\n";
    exit;
}
######
#
#	EXIT CODES
# 2 	key file does not exist
# 3 	license file doest not exits
#
######

unless ($serial) {
    unless ( -e $key_file ) {
        exit(2);
    }
    $serial = File::Slurp::read_file($key_file);
}

chomp($serial);

#FIXME: print usage

my @hashes = qw(
    MOPSLIG_EXTRACTION_HASHES
);

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

sub validate {
    my $key = shift;
    my $i   = 0;
    my $sum = scalar(@hashes);

    foreach my $b1 (@hashes) {
    	print ".";
        if ( $pbkdf2->validate( $prefix . $b1, $key ) ) {
            return $key;
        }
    }
    return 0;
}
print "Serial: $serial\n";
# zo $serialu potrebujem extraction kluc vygenerovat
my $extraction = Mopslig::Generator::generate_key_for_lic_extraction($serial);
if ( validate($extraction) ) {
    my $cipher = Crypt::CBC->new(
        -key    => $extraction,
        -cipher => "Crypt::Rijndael"
    );
    unless( -f $lic_file) { 
    	exit(3);
    }

	my $enc_lic = File::Slurp::read_file($lic_file, binmode => ':raw');

    my $dec = $cipher->decrypt($enc_lic);

    print $dec;
# {
#           'valid_since' => '2016-08',
#           'kbsusers' => {
#                           'valid_since' => '2016-08',
#                           'valid_until' => '2017-07',
#                           'license_amount' => 5
#                         },
#           'valid_until' => '2017-07',
#           'key' => 'START-DE12-FA34-UL56-T789'
#         };

}
else {
    print "INVALID\n";
    exit(1);
}

exit;

# my $products     = qq(MOPSLIG_LICSENSE_CONFIG);
# my $product_data = JSON::XS->new->utf8->decode($products);

# my $key_lic = -e $key_file ? File::Slurp::read_file($key_file);

# my $lic
#     = $product_data->{licenses}{types}{ lc( ( split( '-', $key_lic ) )[0] ) };

# if ($refresh) {
#     my ( undef, undef, undef, undef, $month, $year ) = localtime;
#     $month += 1; # lebo mesiace oznacuje od 0 do 11
#     $year += 1900;

#     my $valid_until = $lic->{valid_until};

#     my ( $valid_year, $valid_month ) = split( "-", $valid_until );

#     if ( $valid_year >= $year && $valid_month >= $month ) {
#         exit(0);
#     }
# }

# $lic->{key} = $key_lic;

# my $ekey = Mopslig::Generator::generate_key_for_lic_extraction($key_lic);

# my $lic_json = JSON::XS->new->encode($lic);

# use Crypt::CBC;
# use Crypt::Rijndael;

# my $cipher = Crypt::CBC->new(
#     -key    => $ekey,
#     -cipher => "Crypt::Rijndael"
# );

# my $enc = $cipher->encrypt($lic_json);
