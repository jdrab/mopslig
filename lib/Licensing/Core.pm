package Licensing::Core;
use warnings;
use strict;

# use Licensing::Database;

use Carp;
# use POSIX qw(ceil);
use Time::Piece;
use Digest::SHA qw(hmac_sha256_hex);

use MIME::Base64 qw(encode_base64 decode_base64);
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);


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
42;