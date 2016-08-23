#!/usr/bin/env perl
use strict ;
use warnings ;
use IO::Compress::Zip qw(zip $ZipError) ;

use Path::Tiny qw(path);

my $build_dir = '../build';

#FIXME getopt for "data" directory
my $full_txt = '../data/full.txt';

my $build_id_file = '../data/build-id';
my @binary_files = qw(client-lic imprint-lic validate-lic verify-key);
#FIXME getopt for "export" directory
my $export_dir = '../export';

# customer_zip name is build from $customer_zip $build_id $zip_postfix
my $customer_zip = $export_dir.'/customer'; 
# backup_zip name is build from $backup_zip $build_id $zip_postfix
my $backup_zip = $export_dir.'/backup';
my $zip_postfix; #later

unless( -f $build_id_file ) { 
	print "Missing build-id file, can not continue.\n";
	exit(2);
}

my $build_id = path($build_id_file)->slurp_utf8;
# just in case i do this by hand for an unknown reason
chomp($build_id);
$zip_postfix = "_$build_id.zip";

$customer_zip .= $zip_postfix;
$backup_zip .= $zip_postfix;

unless ( -f $full_txt ) {
	print "File containing (keys,verify hashes,extraction keys and extraction hashes is required (data/full.txt)\n";
	exit(2);
}

unless ( -d $export_dir ) { 
	system("mkdir","-p", $export_dir);
	print "export dir $export_dir was created\n";
}
chomp($build_id);
print "build-id:\t\t$build_id\n";

#
# get build-id from binaries, it must be the same or it will not work -> they contain
# different hashes.
#
my @_build_ids;

foreach my $b_file (@binary_files) {
	$b_file = $build_dir.'/'.$b_file;
	unless( -f $b_file ) {
		print "$b_file is missing, run ./build-$b_file.pl\n"
	}

	my $b_id = `./$b_file --build-id`;
	print "$b_file build-id:\t".$b_id;
	if( $build_id != $b_id ) {
		print "Build id for $b_file is different than build-id from build-id file\n";
		exit(3);
	}
}


my (@full_customer_zip, @full_backup_zip);

push(@full_customer_zip,@binary_files);

push(@full_backup_zip, @binary_files);
push(@full_backup_zip,$full_txt);

print "Zipping customer files to $customer_zip\n";
zip \@full_customer_zip => $customer_zip or die "zip failed $ZipError\n";
print "Zipping backup files to $backup_zip\n";
zip \@full_backup_zip => $backup_zip or die "zip failed $ZipError\n";

exit;


sub usage {
    print <<EOL;

Validate license key

Usage:

$0\t--validate\nrequried parameter for license validation process
\t\t--key\tkey to verify
\t\t--license\tpath to license file or client.lic will be used
\t\t--build-id \tdisplay build-id
\t\t--help\tdisplay this help

Exit codes:

0   - Export success full
1   - Export failed
2   - Error: Missing files: data/build-id or full.txt
3   - Error: Build ids are different
4   - Error: Key file does not exists
EOL
}
