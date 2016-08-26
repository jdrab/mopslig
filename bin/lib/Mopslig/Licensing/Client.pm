package Mopslig::Licensing::Client;
use warnings;
use strict;

use Time::Piece;
use Data::Dumper;

use Mopslig::Generator;

sub get_private_key {
    my $key = shift
        || die('Client public key is required for fetching his private key');
    #temporary retarded solution
    return Mopslig::Generator::generate_key_for_lic_extraction($key);
}

42;
__END__
