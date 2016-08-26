package Mopslig::Licensing::Server;
use warnings;
use strict;

use Carp;
use Data::Dumper;
use Digest::SHA qw(hmac_sha256_hex);
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

use Mopslig::Licensing::Core;
use Mopslig::Licensing::Registry;

our $VERSION = '0.0.1';

sub extract {
    my $hashed = shift || die('Empty data for license extraction');

    # mrdnut prec mac adresu 64 znakov a "odlozit"
    #
    my $hashed_mac = substr( $hashed, 0, 17 );
    return ( substr( $hashed, 0, 17 ), substr( $hashed, 17 ) );

}

sub generate_lic_hash {
    my ( $start_date, $end_date, $data, $private_key ) = @_;
    return Mopslig::Licensing::Core::generate_lic_hash( $start_date, $end_date, $data,
        $private_key );

}

sub get_lic_object {
	my $client_public_key = shift || die("Missing client public key");
	return Mopslig::Licensing::Registry::get_lic_object($client_public_key);
}

sub get_client_private_key {
    my $public = shift || die('Client public key is required');

    return Mopslig::Licensing::Registry::get_private_key($public);
}
42;
__END__
