package Mopslig::Generator;
use warnings;
use strict;
our @EXPORT_OK = qw(generate_keys generate_hashes_for_package generate_key_for_lic_extraction);

use Mopslig::Helper qw(gimme_random_string);
use Digest::SHA1  qw(sha1_hex);
use Crypt::PBKDF2;
use Crypt::PBKDF2::Hash::HMACSHA2;


=pod
Create key for lic file extraction
key format: 12345-12345-12345
=cut

sub generate_key_for_lic_extraction {
    my $serial = shift || croak("Missing serial number");
    ( my $shan = sha1_hex($serial) ) =~ s/[a-z]//gi;
    return join( "-", ( unpack( "(A5)*", $shan ) )[ 0 .. 2 ] );
}

=pod
Generate product keys
=cut
sub generate_keys {
    my $amount         = shift || 1;
    my $how_many_chars = shift || 16;
    my $nodots = shift;

    # By default I don't want to generate keys with
    # charactes 1 l O 0 - keys might be unreadable for users
    my @range
        = ( 2, 3, 4, 5, 6, 7, 8, 9, "A" .. "H", "J" .. "N", "P" .. "Z" );
    my @customer_serial_numbers;
    $| = 1;

    # I don't care if generated strings are unique
    foreach my $i ( 1 .. $amount ) {
        print "." unless $nodots;
        my $k = Mopslig::Helper::gimme_random_string( $how_many_chars, \@range );
        push( @customer_serial_numbers, join( "-", unpack( "(A4)*", $k ) ) );
    }
    return @customer_serial_numbers;
}

=pod
Generate hashes for license 'package'
=cut
sub generate_hashes_for_package {
    my $serials = shift || die("Need serial numbers");
    my $prefix  = shift || '';
    my $nodots = shift;

    # don't forget to escape prehash value for regex
    my $prehash    = shift || '{X-PBKDF2}HMACSHA2\+512:AAAD6A:';
    my $hash_class = shift || 'HMACSHA2';
    my $sha_size   = shift || 512;
    my $salt_len   = shift || 10;

    my @pkg_data;

    foreach my $serial ( @{$serials} ) {
        $| = 1;
        my $pbkdf2 = Crypt::PBKDF2->new(
            hash_class => $hash_class,
            hash_args  => { sha_size => $sha_size },
            salt_len   => $salt_len
        );

        my $full = $prefix . $serial;
        my $hash = $pbkdf2->generate($full);
        # my $extraction_hash = $pbkdf2->generate()
        
        $hash =~ s/^$prehash//g;
        # add hash for license extraction
        # print "Serial ktory ide do generate_key_for_lic_extraction: $serial\n";
        my $extraction_key = generate_key_for_lic_extraction($full);
        # print "Extraction_key pred: $extraction_key\n";
        my $extraction_hash = $pbkdf2->generate($extraction_key);
        
        $extraction_hash =~ s/^$prehash//g;
        # print "Extraction_key po: $extraction_key\n".
        
        # print "Key: $full\nHash pre key: $hash\nExtraction key: $extraction_key\nExtarction key hash: $extraction_hash\n===================\n";
        push( @pkg_data, ( $full . "\t" . $hash ."\t". $extraction_key."\t".$extraction_hash) );

        print "." unless $nodots;
    }
    return @pkg_data;
}

42
__END__
