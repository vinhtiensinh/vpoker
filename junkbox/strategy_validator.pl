#!/usr/bin/perl
use lib '../lib';
use lib '../vendor';

use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::Strategy::RuleBased::RuleTable;

my $id = $ARGV[0];

eval {
  my $strategy  = VPoker::Holdem::Strategy::RuleBased->new;
  $strategy->decisions_from_db($id);
};

if ($@) {
  print "ERROR: $@";
}

exit(0);
