package VPoker::HandRank::Flush;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

## ----------------------------------------------------------------------------
sub suit {
    my $self = shift;
    return $self->card(1)->suit;
}

## ----------------------------------------------------------------------------
sub is_straight_flush {
    return shift->is_straight;
}

## ----------------------------------------------------------------------------
sub is_flush {
    return 1;
}

sub is_straight {
    my $self = shift;
    return $self->is_connected;
}

1;
