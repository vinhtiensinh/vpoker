package VPoker::HandRank::FlushDraw;
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
sub is_flush_draw {
    return 1;
}

## ----------------------------------------------------------------------------
sub is_nut_flush_draw {
    my $self = shift;
    return $self->high_card->is('A');
}

1;
