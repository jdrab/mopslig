#!/usr/bin/env perl
use warnings;
use strict;

my $key_file = './key.lic';
my $verify_key_bin = './verify-key';

my $client_lic_bin = './client-lic';
my $client_license_file = './client.lic';

my $validate_lic_bin = './validate-lic';

use File::Slurp;
use Data::Dumper;

my $key = File::Slurp::read_file($key_file);

chomp($key);
# my @verify_args = qw($verify_key_bin --key $key);
system($verify_key_bin,"--key",$key) == 0 or  die("KEY was not verified, it is invalid. error_code: ".($? >>8)." \n");
print "key $key is verified\n";
#my @client_lic = ($client_lic_bin,'--key',$key,'--generate','--output',$client_license_file);
#print join(" ",@client_lic)."\n";

system($client_lic_bin,'--key',$key,'--generate','--output',$client_license_file) == 0 or die("Error by generating client license file error_code: ".($? >>8)." \n");
print "license file $client_license_file generated\n";
#my @validate_lic = ($validate_lic_bin,'--key',$key,'--license',$client_license_file,'--validate');
#print join(" ",@validate_lic)."\n";

system($validate_lic_bin,'--key',$key,'--license',$client_license_file,'--validate') == 0 or die("License validation failed with error code: ".($? >>8)." \n");
print "client license $client_license_file validated against key $key \n";
print "\nDone\n";
# # Postup
# ./mopslig.pl sure 

# zvalidovat cez ./validate-lic --serial
# napchat do key.lic nejake seriove cislo 
# potom ak skonci validate-lic s exit kodom 0
