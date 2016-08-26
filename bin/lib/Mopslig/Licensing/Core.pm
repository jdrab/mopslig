package Mopslig::Licensing::Core;
use warnings;
use strict;

use Carp;
# use POSIX qw(ceil);
use Time::Piece;
use Digest::SHA qw(hmac_sha256_hex);

use MIME::Base64 qw(encode_base64 decode_base64);
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

use Mopslig::Generator;
use Mopslig::Licensing::Server;
use Mopslig::Helper;

sub create_lic_object {
    my ( $data_hash_ref, $client_public_key, $start_date, $end_date ) = @_;
    unless ( @_ == 4 ) {
        croak(
            "Creating license object requries 4arguments (data,key,start_date, end_date"
        );
    }

    my $client_private_key
        = Mopslig::Client::get_private_key($client_public_key);

    return save_lic_file(
        #$client_public_key . ".lic",
        "object.lic",
        Mopslig::Licensing::Server::generate_lic_hash(
            $start_date, $end_date, $client_private_key, $data_hash_ref
        )
    );

}

sub save_lic_file {
    my ( $filename, $data ) = @_;
    unless ( @_ == 2 ) {
        croak("save_lic_file requires two arugments");
    }

    open( my $fh, '>:raw', $filename )
        or die "Could not open file '$filename' $!";
    print $fh $data;
    close $fh;
    return $filename;
}


sub generate_lic_hash {
    my ( $start_date, $end_date, $data, $private_key ) = @_;
    unless ( @_ == 4 ) {
        croak("generate_lic_hash requires 4 arguments");
    }

    my $lic_date = Time::Piece->strptime( $start_date, "%Y-%m" );
    my $global = hmac_sha256_hex( 'License', $private_key );

    #my $global = Licensing::Core::get_hw_info();
    foreach ( 1 .. Mopslig::Helper::date_diff( $start_date, $end_date ) ) {

        #incremenet license month
        $lic_date->add_months($_);

        #generate digest for month
        $global .= hmac_sha256_hex( $lic_date->date . $data, $private_key );

    }
    return compress($global);
}



sub compress {
    my $data = shift || die('Data for compression required');

    my $ret;
    gzip \$data => \$ret or die "gzip failed: $GzipError\n";
    return $ret;
}

sub decompress {
    my $data = shift || die('Data for decompression required');

    my $ret;
    gunzip \$data => \$ret or die "gunzip failed: $GunzipError\n";
    return $ret;
}
42;