package Mopslig::Helper;
use warnings;
use strict;

our $VERSION = '0.0.1';


=pod
Generate random string - used for keys generation
=cut
sub gimme_random_string {
    my $length = shift || 6;
    my $chars = shift || [ "A" .. "Z", "a" .. "z", "0" .. "9" ];

    my $string;
    $string .= $chars->[ int rand scalar @{$chars} ] for 1 .. $length;
    return $string;
}
=pod
What the name says
=cut
sub uniq {
    my %seen;
    return grep { !$seen{$_}++ } @_;
}

sub date_diff {

    my $start_date = shift;
    croak("Invalid start date, format YYYY-MM required.")
        unless ( $start_date =~ /^\d{4}\-\d{2}$/ );
    my $end_date = shift;
    croak("Invalid end date, format YYYY-MM required.")
        unless ( $end_date =~ /^\d{4}\-\d{2}$/ );

    my $start = Time::Piece->strptime( $start_date, "%Y-%m" );
    my $end   = Time::Piece->strptime( $end_date,   "%Y-%m" );

    my $diff = $end - $start;

    return POSIX::ceil( $diff->months );

}

42
__END__