package VPoker::Holdem::HoleCards;
use base qw(VPoker::CardSet);

use strict;
use warnings;
use diagnostics;

use VPoker::Card;

use overload (
    '<'      => 'less_than',
    '>'      => 'greater_than',
    '=='     => 'equal',
    '>='     => sub {
        my ($self, $cards) = @_;
        return $self->greater_than($cards) || $self->equal($cards) ;
    },
    '<='     => sub {
        my ($self, $cards) = @_;
        return $self->less_than($cards) || $self->equal($cards);
    },
    'bool'   => sub {return 1;},
    fallback => undef,
);

sub is_suited_connectors {
    my $self = shift;
    return $self->is_suited && $self->is_connected;
}

sub card1 {
    my $self = shift;
    return $self->card(1);
}

sub card2 {
    my $self = shift;
    return $self->card(2);
}
## ----------------------------------------------------------------------------
sub is_pair {
    my $self = shift;
    return $self->card1->rank == $self->card2->rank;
}

## ----------------------------------------------------------------------------
sub is_gap1 {
    my $self = shift;
    return (
        $self->high_card->rank - $self->high_card(2)->rank == 2
        or
        $self->is('A3')
    );
}

## ----------------------------------------------------------------------------
sub is_gap2 {
    my $self = shift;
    return (
        $self->high_card->rank - $self->high_card(2)->rank == 3
        or
        $self->is('A4')
    );
}

## ----------------------------------------------------------------------------
sub is_gap3 {
    my $self = shift;
    return (
        $self->high_card->rank - $self->high_card(2)->rank == 4
        or
        $self->is('A5')
    );
}
## ----------------------------------------------------------------------------
sub is {
    my ( $self, $face ) = @_;
    if ( $face =~ /([A23456789TJQK])([A23456789TJQKX])([s])?/ ) {
        my $face1          = $1;
        my $face2          = $2;
        my $suitedRequired = $3;
        my $cardCheck      = $self->has( $face1, $face2 );

        if ($cardCheck) {
            return $self->is_suited if $suitedRequired;
            return 1;
        }
        else {
            return 0;
        }

    }
    else {
        die("invalid parameter for card faces $face");
    }
}

## ---------------------------------------------------------------------------
sub is_any_of {
    my ( $self, @faces ) = @_;
    foreach my $face (@faces) {
        return 1 if $self->is($face);
    }
    return 0;
}

sub validate_card_faces {
    my ($self, $face) = @_;
    return ($face =~ /^([A23456789TJQK])([A23456789TJQKX])[s]?$/);
}

sub _compare {
    my ( $self, $cards ) = @_;
    my $highCard;
    my $lowCard;
    my $additionalCheck;
    
    if(ref($cards) && $cards->isa('VPoker::Holdem::HoleCards')) {
        $highCard = $cards->high_card;
        $lowCard  = $cards->high_card(2);
    }
    elsif ( $cards =~ /([A23456789TJQK])([A23456789TJQKX])([pscg123]*)?/ ) {
        my $card1 = VPoker::Card->new($1);
        my $card2 = VPoker::Card->new($2);
        $highCard = $card1 >= $card2 ? $card1 : $card2;
        $lowCard  = $card1 <= $card2 ? $card1 : $card2;

        $additionalCheck = $3;
    }
    else {
        die('Invalid argument in hole cards comparision' . $self->to_string($cards));
    }

    if($additionalCheck) {
        
        return -2 if (
            ( $additionalCheck =~ /c/  && $self->is_not_connected )
            or
            ( $additionalCheck =~ /s/  && $self->is_not_suited )
            or
            ( $additionalCheck =~ /p/ && $self->is_not_pair )
            or
            ( $additionalCheck =~ /g1/ && $self->is_not_gap1 )
            or
            ( $additionalCheck =~ /g2/ && $self->is_not_gap2 )
            or
            ( $additionalCheck =~ /g3/ && $self->is_not_gap3 )
        );

    }

    return  0 if (
        $self->high_card(1) == $highCard && $self->high_card(2) == $lowCard
    );

    return  -1 if (
        ( $self->high_card(1) < $highCard && $self->high_card(2) <= $lowCard )
        or
        ( $self->high_card(1) <= $highCard && $self->high_card(2) < $lowCard )
    );

    return  1 if (
        ( $self->high_card(1) > $highCard && $self->high_card(2) >= $lowCard )
        or
        ( $self->high_card(1) >= $highCard && $self->high_card(2) > $lowCard )
    );

    return -2;

}

sub greater_than {
    my ($self, $cards) = @_;
    return $self->_compare($cards) == 1;
}

sub less_than {
    my ($self, $cards) = @_;
    return $self->_compare($cards) == -1;
}

sub equal {
    my ($self, $cards) = @_;
    return $self->_compare($cards) == 0 ;
}
1;
