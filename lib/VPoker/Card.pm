package VPoker::Card;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

use constant CLUB    => 1;
use constant DIAMOND => 2;
use constant HEART   => 3;
use constant SPADE   => 4;

use constant T => 10;
use constant J => 11;
use constant Q => 12;
use constant K => 13;
use constant A => 14;

## array index start with 0 while card face start with 1 so
## we put a pad 'X' at the start.
use constant RANK_FACE  => [qw(X A 2 3 4 5 6 7 8 9 T J Q K A)];
use constant SUIT_FACE  => [qw(x c d h s)];
use constant SUIT_VALUE => {
    c  => 1,
    d  => 2,
    h  => 3,
    s  => 4,
    1  => 1,
    2  => 2,
    3  => 3,
    4  => 4,
    x  => 0,
    0  => 0,
};

use constant RANK_VALUE => {
    1  => 14,
    2  => 2,
    3  => 3,
    4  => 4,
    5  => 5,
    6  => 6,
    7  => 7,
    8  => 8,
    9  => 9,
    T  => 10,
    10 => 10,
    J  => 11,
    11 => 11,
    Q  => 12,
    12 => 12,
    K  => 13,
    13 => 13,
    A  => 14,
    14 => 14,
    X  => 0,
    0  => 0,
};

use overload (
    '<=>'    => 'compare',
    'cmp'    => 'compare',
    fallback => 1,
);

__PACKAGE__->has_attributes( 'rank', 'suit' );

## ----------------------------------------------------------------------------
sub new {
    my ( $class, @args ) = @_;
    my ( $rank, $suit );

    if ( scalar @args == 1 ) {
        my $cardFace = $args[0];
        if ( $cardFace =~ /^([23456789TJQKAX])([cdhsx]*)$/ ) {
            $rank = $1;
            $suit = $2 || 'x';
        }
        else {
          confess("Invalid card face $cardFace");
        }
    }
    else {
        my (%args) = @args;
        $rank = RANK_VALUE->{ $args{'rank'} };
        $suit = SUIT_VALUE->{ $args{'suit'} };
    }

    my $self = {};
    bless $self, $class;
    $self->init(
        rank => RANK_VALUE->{$rank},
        suit => SUIT_VALUE->{$suit},
    );

    return $self;
}

sub rank_face {
    my $self = shift;
    return RANK_FACE->[ $self->rank ];
}

sub suit_face {
    my $self = shift;
    return SUIT_FACE->[ $self->suit ];
}

## ----------------------------------------------------------------------------
sub face {
    my $self = shift;
    return $self->rank_face . $self->suit_face;
}

## ----------------------------------------------------------------------------
sub compare {
    my ( $self, $card ) = @_;
    if ( !ref($card) or $card->not_isa('VPoker::Card') ) {
        $card = VPoker::Card->new($card);
    }

    return $self->rank <=> $card->rank;
}

## ----------------------------------------------------------------------------
sub is {
    my ( $self, $card ) = @_;
    if ( ref($card) && $card->isa('VPoker::Card') ) {
      return $self->is($card->face);
    }

    my $face = $card;

    if ( length($face) == 1 ) {
        return RANK_FACE->[ $self->rank ] eq $face;
    }
    if ( $face =~ /([A23456789TJQK])([cdhsx]?)/ ) {
        my ( $rank, $suit ) = ( $1, $2 );

        my $sameRank = RANK_FACE->[ $self->rank ] eq $1;

        return $sameRank if !$suit || $suit eq 'x';

        return $sameRank
          && SUIT_FACE->[ $self->suit ] eq $2;
    }
    else {
        confess("Invalid card face $face");
    }
}

sub validate_card_face {
    my ($self, $face) = @_;
    confess('calling validate_card_face without value') unless $face;
    return $face =~ /^([A23456789TJQKX])([cdhsx]?$)/;
}

1;
