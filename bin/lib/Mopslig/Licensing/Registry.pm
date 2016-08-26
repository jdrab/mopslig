package Mopslig::Licensing::Registry;
use warnings;
use strict;

use Carp;
use Data::Dumper;
use Digest::SHA qw(hmac_sha256_hex);

our $VERSION = '0.0.1';

sub get_lic_object {
    # die('toto nacitat z config.jsonu a do .lic suboru narvat cez defaultny kluc ak neexistuje subor');
    my $key = shift || die("Public key is required");

    my %json_objects = (
        'key1' =>
            '{"version":"1.0","services":{"mail":{"amount":"30","expire":"2016-12-01"}}}',
        'key2' =>
            '{"version":"1.0","services":{"dhcp":{"amount":"30","expire":"2016-12-01"},"mail":{"amount":"30","expire":"2016-12-01"},"vpn":{"amount":"5","expire":"2016-12-01"}}}',
        'key3' =>
            '{"version":"1.0","start_date":"2015-10","expire_date":"2017-01"-services":{"dhcp":{"amount":"50","expire":"2016-12-01"},"mail":{"amount":"30","expire":"2016-12-01"},"vpn":{"amount":"5","expire":"2016-12-01"}}}'
    );
    my $obj = $json_objects{$key};
    chomp($obj);
    return $obj;
}

42
__END__