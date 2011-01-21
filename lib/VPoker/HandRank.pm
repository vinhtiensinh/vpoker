package VPoker::HandRank;
use base qw(VPoker::Base);

use strict;
use warnings;
no warnings 'redefine';

use diagnostics;
use Carp qw(confess);

## ----------------------------------------------------------------------------
sub is_straight_flush { return 0 }
sub is_quad           { return 0 }
sub is_fullhouse      { return 0 }
sub is_flush          { return 0 }
sub is_straight       { return 0 }
sub is_trip           { return 0 }
sub is_two_pairs      { return 0 }
sub is_pair           { return 0 }
sub is_straight_draw  { return 0 }
sub is_flush_draw     { return 0 }
sub is_high_cards     { return 0 }

1;
