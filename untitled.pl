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

my $products = File::Slurp::read_file('./config.json');
my $product_data = JSON::XS->new->utf8->decode($products);
use Data::Dumper;

# license key - default START-DE12-FA34-UL56-T789
my $key_lic = File::Slurp::read_file('./key.lic');

my $lic = $product_data->{licenses}{types}{lc((split('-',$key_lic))[0])};
print Dumper($lic);die;
# my $licensing_object = Mopslig::Licensing::Core::create_lic_object($lic,
# 	'START-DE12-FA34-UL56-T789',
# 	$lic->{valid_since},$lic->{valid_until});


#create default license
#my $licensing_object = Mopslig::Licensing::Core::create_lic_object(
#	$lic,
	#)