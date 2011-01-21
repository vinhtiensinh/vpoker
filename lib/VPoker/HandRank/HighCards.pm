package VPoker::HandRank::HighCards;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

sub is_high_cards {
    return 1;
}

1;
