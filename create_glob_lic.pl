#!/usr/bin/env perl
use warnings;
use strict;

# START-DE12-FA34-UL56-T789       
# YsYhjMUYzmTb4g==:iw2LwKQlSQvNUdfgpnTd5WGjMWpO9SFfWFuriRi3lR+ti1+1sUhJQCFQsBbnC+8oGLsMles6ZxJjLgEP7Z7enA==       
# 75529-65793-84237

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname( abs_path $0) . '/lib';
use File::Slurp;
use JSON::XS;

use Mopslig::Licensing::Core;
use Mopslig::Licensing::Client;

my $products = File::Slurp::read_file('./config.json');
my $product_data = JSON::XS->new->utf8->decode($products);
use Data::Dumper;

#######################################################
# vytvorenie global.lic suboru
# license key - default START-DE12-FA34-UL56-T789
my $key_lic = File::Slurp::read_file('./key.lic');

my $lic = $product_data->{licenses}{types};
use Data::Dumper;
print Dumper($lic);
my $gl = Mopslig::Licensing::Core::generate_lic_hash($lic->{valid_since},$lic->{valid_until},$lic,
	Mopslig::Licensing::Client::get_private_key($key_lic));
File::Slurp::write_file('global.lic', {binmode => ':raw'},$gl);
#######################################################

# citanie global lic suboru
my $client_private_key = Mopslig::Licensing::Client::get_private_key($key_lic);

open( my $fh, '<:raw', 'global.lic' ) or die($!);
my $buff;
{
    local $/;
    $buff = <$fh>;
    close $fh;
}

# server dekomprimuje buffer od klienta
my $data = Mopslig::Licensing::Core::decompress($buff);


print "DATA:\n".Dumper($data);
# extrahuje info pre hashnute hw_info a hashnuty lic_objekt
my ( $client_hw_info, $license ) = Mopslig::Licensing::Server::extract($data);
print Dumper($client_hw_info);
# # obsahuje to, co poslal klient bez mac adresy, 
# # toto treba porovnat voci na serveri vypocitanemu hashu
# print "LIC OD KLIENTA:".Dumper($license);

# # az nasledne treba riesit klientsku informaciu, odkial sa pripaja, 
# # ci ma validne a podobne
# my $client_lic_object  = Mopslig::Licensing::Server::get_lic_object($key_lic);

# print "\nCLIENT_LIC_OBJECT:".Dumper($client_lic_object);
# print "\nPRIVATE_KEY:".Dumper($client_private_key);
# print "\nPUBLIC_KEY:".Dumper($key_lic);

#use MIME::Base64;
#my @hw_info = ($client_hw_info,decode_base64($client_hw_info));
#print "\nCLIENT HW INFO:".Dumper(\@hw_info);

