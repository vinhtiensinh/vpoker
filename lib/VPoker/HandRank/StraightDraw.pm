package VPoker::HandRank::StraightDraw;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

## ----------------------------------------------------------------------------
sub is_open_ended {
    my $self = shift;
    return $self->is_connected && ( not $self->has('A') );
}

## ----------------------------------------------------------------------------
sub is_gut_shot {
    my $self = shift;
    if ( $self->complete_cards->size == 4 ) {
        return 1;
    }
    else {
        return 0;
    }
}

## ----------------------------------------------------------------------------
sub is_busted_belly {
    my $self = shift;
    if ( ( not $self->is_open_ended )
        && $self->complete_cards->size == 8 )
    {
        return 1;
    }
    else {
        return 0;
    }
}

## ----------------------------------------------------------------------------
sub complete_cards {
    my $self           = shift;
    my $complete_cards = VPoker::CardSet->new;

    foreach my $cardRank ( 2 .. 14 ) {
        my $tmpCard = VPoker::Card->new(
            rank => $cardRank,
            suit => 'x',
        );

        my $tmpCardSet = VPoker::CardSet->new( $self->cards, $tmpCard );

        if ( $tmpCardSet->_any_straight ) {
            foreach my $suit ( 1 .. 4 ) {
                $complete_cards->add(
                    VPoker::Card->new(
                        rank => $tmpCard->rank,
                        suit => $suit,
                    )
                );
            }
        }
    }

    return $complete_cards;
}

## ----------------------------------------------------------------------------
sub is_straight_draw {
    return 1;
}

1;
