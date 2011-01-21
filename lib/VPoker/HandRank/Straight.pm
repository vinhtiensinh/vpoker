package VPoker::HandRank::Straight;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

## ----------------------------------------------------------------------------
sub is_straight_flush {
    my $self = shift;
    return $self->is_suited;
}

## ----------------------------------------------------------------------------
sub is_straight {
    return 1;
}

## ----------------------------------------------------------------------------
sub high {
    my $self = shift;
    if ( $self->has( 'A', '2', '3', '4', '5' ) ) {
        return $self->SUPER::high_card(2);
    }
    else {
        return $self->SUPER::high_card;
    }
}

## ----------------------------------------------------------------------------
sub low {
    my $self = shift;
    if ( $self->has( 'A', '2', '3', '4', '5' ) ) {
        return $self->SUPER::high_card(1);
    }
    else {
        return $self->SUPER::low_card;
    }
}

1;
