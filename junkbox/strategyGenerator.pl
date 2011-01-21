#!/opt/local/bin/perl
use strict;
use warnings;
use YAML::XS qw(LoadFile);
#use YAML::Tiny qw(LoadFile);

my $file = $ARGV[0];

my $strategy = LoadFile($file);
use Data::Dumper;
print Dumper($strategy);
