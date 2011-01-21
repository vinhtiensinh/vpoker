package VPoker::Holdem::BoardCards;
use base qw(VPoker::CardSet);

use strict;
use warnings;
use diagnostics;
use VPoker::Card;

sub flop {
    my $self = shift;
    if ( scalar @{ $self->cards } >= 3 ) {
        return VPoker::CardSet->new( $self->card(1), $self->card(2),
            $self->card(3) );
    }
    else {
        return undef;
    }
}

sub turn {
    return shift->card(4);
}

sub river {
    return shift->card(5);
}

sub possible_straight {
    my $self     = shift;
    my $strength = $self->strength;
    return 0
      if ( $self->size == 3 && ( $strength->is_pair || $strength->is_trip ) );
    return 0 if ( $self->size == 4 && $strength->is_trip );
    return 0 if ( $self->size == 5 && $strength->is_quad );

    return ( $self->high_card->rank - $self->low_card->rank <= 4
          || ( $self->high_card == 'A' && $self->high_card(2) <= 5 ) );

}

1;
