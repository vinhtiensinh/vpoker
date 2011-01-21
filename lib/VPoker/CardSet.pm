package VPoker::CardSet;
use base qw(VPoker::Base);

use strict;
use warnings;
no warnings 'redefine';

use diagnostics;
use Carp qw(confess);

use VPoker::Card;
use VPoker::HandRank;
use VPoker::HandRank::Flush;
use VPoker::HandRank::Quad;
use VPoker::HandRank::FullHouse;
use VPoker::HandRank::Straight;
use VPoker::HandRank::Trip;
use VPoker::HandRank::TwoPairs;
use VPoker::HandRank::OnePair;
use VPoker::HandRank::HighCards;
use VPoker::HandRank::FlushDraw;
use VPoker::HandRank::StraightDraw;

__PACKAGE__->has_attributes('cards');

## These attribute are private and used to calculate the hand strength
sub new {
    my ( $class, @cards ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init( cards => [] );
    $self->add(@cards);
    return $self;
}

## ----------------------------------------------------------------------------
sub size {
    my $self = shift;
    return scalar @{ $self->cards };
}

## ----------------------------------------------------------------------------
## Note that if the CardSet already have the card. We will not allow
## two same card in the set.
sub add {
    my ( $self, @cards ) = @_;

    foreach my $item (@cards) {
        if ( ref($item) ) {
            if ( ref($item) eq 'ARRAY' ) {
                $self->add(@$item);
            }
            elsif ( $item->isa('VPoker::CardSet') ) {
                $self->add( $item->cards );
            }
            elsif ( $item->isa('VPoker::Card') ) {
                push @{ $self->cards }, $item unless $self->has($item);
            }
            else {
                die( 'cannot add to cardset ' . @cards );
            }
        }
        else {
            push @{ $self->cards }, VPoker::Card->new($item)
              unless $self->has($item);
        }

    }
    return 1;
}

## ----------------------------------------------------------------------------
sub is_suited {
    my $self      = shift;
    my $firstCard = $self->card(0);
    foreach my $card ( @{ $self->cards } ) {
        return 0 if $card->suit != $firstCard->suit;
    }
    return 1;

}

## ----------------------------------------------------------------------------
sub is_connected {
    my $self = shift;
    my $previousCard;
    my $connected   = 1;
    my @sortedCards = $self->sort;

    foreach my $card (@sortedCards) {
        if ( defined $previousCard ) {
            $connected = $card->rank - $previousCard->rank == 1;
        }

        $previousCard = $card;
        last if ( not $connected );
    }

    if ($connected) {
        return 1;
    }
    elsif ( $previousCard->is('A') && $sortedCards[0]->is('2') ) {
        return 1;
    }
    else {
        return 0;
    }
}

## ----------------------------------------------------------------------------
sub has {
    my ( $self, @cards ) = @_;

     if ( scalar @cards == 1 && !VPoker::Card->validate_card_face($cards[0]) && !ref($cards[0]) ) {
       return $self->_has_card_faces($cards[0]);
     }
    return $self->_has_cards(@cards);
}

sub _has_card_faces {
    my ($self, $cards) = @_;
    confess("Invalid CardSet face $cards") unless $cards =~ /^([23456789TJQKA]+)([s])?$/;
    my @cards  = split('', $1);
    my $suited = $2;
  
    if ($suited) {
        my $suits = {
            VPoker::Card::CLUB()    => VPoker::CardSet->new,
            VPoker::Card::DIAMOND() => VPoker::CardSet->new,
            VPoker::Card::HEART()   => VPoker::CardSet->new,
            VPoker::Card::SPADE()   => VPoker::CardSet->new,
        };
  
        foreach my $card (@{$self->cards}) {
            $suits->{ $card->suit }->add($card);
        }
  
        my @cards  = split('', $1);
        while ( my ( $key, $suit ) = each %$suits ) {
            return $self->TRUE if $suit->_has_cards(@cards);
        }

        return $self->FALSE;
    }
    else {
        return $self->_has_cards(@cards);
    }
}

sub _has_cards {
    my ( $self, @cards ) = @_;

    my @cardFaces = ();
    foreach my $card (@cards) {
        if ( ref($card) && $card->isa('VPoker::Card') ) {
            push @cardFaces, $card->face;
        }
        elsif (ref($card) && $card->isa('VPoker::CardSet')) {
            push @cardFaces, @{$card->cards};
        }
        else {
            push @cardFaces, $card;
        }
    }

    @cardFaces = sort { length($b) cmp length($a) } @cardFaces;

    my @copiedCards = @{ $self->cards };
    return 0 if ( scalar @cardFaces > $self->size );

    my $match;
    foreach my $cardFace (@cardFaces) {
        $match = 0;
        
        if($cardFace eq 'X') {
            $match  = 1;
            next;
        }
        
        for ( my $index = 0 ; $index < scalar @copiedCards ; $index++ ) {
            my $card = $copiedCards[$index];
            if ( defined $card && $card->is($cardFace) ) {
                delete $copiedCards[$index];
                $match = 1;
                last;
            }
        }

        return 0 if ( not $match );
    }

    return 1;
}

## ----------------------------------------------------------------------------
sub card {
    my ( $self, $index ) = @_;
    return $self->cards->[ $index - 1 ];
}

## ----------------------------------------------------------------------------
sub face {
    my $self = shift;
    my $face;
    foreach my $card ( @{ $self->cards } ) {
        $face = $face . $card->face;
    }
    return $face;
}

###############################################################################
## Method that defind the hand strength                                      ##
###############################################################################
sub high_card {
    my ( $self, $order ) = @_;
    $order = $order || 1;
    return [ $self->sort( 'desc' => 1 ) ]->[ $order - 1 ];
}

## -----------------------------------------------------------------------------
sub low_card {
    my ($self, $order) = @_;
    $order = $order || 1;
    return [ $self->sort ]->[$order - 1];
}

## -----------------------------------------------------------------------------
sub _any_pair {
    my $self  = shift;
    my @cards = $self->sort;

    my $previousCard;
    my $sameCardCount = 0;
    my @pairs         = ();
    my $i;

    for ( $i = 1 ; $i < scalar @cards ; $i++ ) {
        if ( $cards[$i] == $cards[ $i - 1 ] ) {
            $sameCardCount++;
        }
        else {
            if ( $sameCardCount == 1 ) {
                push @pairs,
                  VPoker::CardSet->new( $cards[ $i - 1 ], $cards[ $i - 2 ] );
            }
            ## reset $sameCardCount
            $sameCardCount = 0;
        }
    }

    ## Do this incase the pair is top 2 cards.
    if ( $sameCardCount == 1 ) {
        push @pairs, VPoker::CardSet->new( $cards[ $i - 1 ], $cards[ $i - 2 ] );
    }

    return @pairs;
}

## -----------------------------------------------------------------------------
sub _any_trip {
    my $self  = shift;
    my @cards = $self->sort;

    my $previousCard;
    my $sameCardCount = 0;
    my @trips         = ();
    my $i;

    for ( $i = 1 ; $i < scalar @cards ; $i++ ) {
        if ( $cards[$i] == $cards[ $i - 1 ] ) {
            $sameCardCount++;
        }
        else {
            if ( $sameCardCount == 2 ) {
                push @trips,
                  VPoker::CardSet->new(
                    $cards[$i],
                    $cards[ $i - 1 ],
                    $cards[ $i - 2 ]
                  );
            }
            ## reset $sameCardCount
            $sameCardCount = 0;
        }

    }

    ## Do this incase the trip is top 3 cards.
    if ( $sameCardCount == 2 ) {
        push @trips,
          VPoker::CardSet->new(
            $cards[ $i - 1 ],
            $cards[ $i - 2 ],
            $cards[ $i - 3 ]
          );
    }

    return @trips;
}

## -----------------------------------------------------------------------------
sub _any_quad {
    my $self  = shift;
    my @cards = $self->sort;

    my $previousCard;
    my $sameCardCount = 0;
    my $quad          = undef;
    my $i;

    for ( $i = 1 ; $i < scalar @cards ; $i++ ) {
        if ( $cards[$i] == $cards[ $i - 1 ] ) {
            $sameCardCount++;
        }
        else {
            if ( $sameCardCount == 3 ) {
                $quad = VPoker::CardSet->new(
                    $cards[$i],
                    $cards[ $i - 1 ],
                    $cards[ $i - 2 ],
                    $cards[ $i - 3 ]
                );
                last;
            }
            ## reset $sameCardCount
            $sameCardCount = 0;
        }

    }

    ## Do this incase the trip is top 3 cards.
    if ( $sameCardCount == 3 ) {
        $quad = VPoker::CardSet->new(
            $cards[ $i - 1 ],
            $cards[ $i - 2 ],
            $cards[ $i - 3 ],
            $cards[ $i - 4 ]
        );
    }

    return $quad;
}

## ----------------------------------------------------------------------------
sub _any_flush {
    my $self   = shift;
    my @cards  = $self->sort;
    my $suited = {
        VPoker::Card::CLUB()    => VPoker::CardSet->new,
        VPoker::Card::DIAMOND() => VPoker::CardSet->new,
        VPoker::Card::HEART()   => VPoker::CardSet->new,
        VPoker::Card::SPADE()   => VPoker::CardSet->new,
    };

    for ( my $i = 0 ; $i < scalar @cards ; $i++ ) {
        $suited->{ $cards[$i]->suit }->add( $cards[$i] );
    }

    while ( my ( $key, $value ) = each %$suited ) {
        return $value if ( $value->size >= 5 );
    }

    return undef;
}

## -----------------------------------------------------------------------------
sub _any_straight {
    my $self     = shift;
    my @cards    = $self->sort;
    my $straight = VPoker::CardSet->new($cards[0]);

    for ( my $i = 1 ; $i < scalar @cards ; $i++ ) {
        if ( $cards[$i]->rank == $cards[$i - 1]->rank ) {
            next;
        }
        elsif ( $cards[$i]->rank == $cards[ $i - 1 ]->rank + 1 ) {
            $straight->add( $cards[$i] );
        }
        elsif ($straight->size >= 5) {
            return $straight;
        }
        else {
            $straight = VPoker::CardSet->new($cards[$i]);
        }
    }

    if ($straight->size >= 5) {
      return $straight;
    }
    elsif($self->has('A', '2', '3', '4', '5')) {

      $straight = VPoker::CardSet::->new;
      foreach my $card (@{$self->cards}) {
        if (
          $card->is('A') or $card->is('2') or
          $card->is('3') or $card->is('4') or
          $card->is('5')) {

          $straight->add($card) if $straight->not_has(VPoker::Card::RANK_FACE->[$card->rank]);
        }
      }

      return $straight;
    }
    else {
      return undef;
    }
}

## -----------------------------------------------------------------------------
sub strength {
    my $self  = shift;
    my $flush = $self->_any_flush;

    ## ---------------------------
    ## Checking for straight flush
    if ( defined $flush ) {
        $flush = VPoker::HandRank::Flush->new($flush);
        if ( $flush->_any_straight ) {
            return VPoker::HandRank::Flush->new( $flush->_any_straight );
        }
    }

    ## -----------------------
    ## Checking for quad
    my $quad = $self->_any_quad;
    if ( defined $quad ) {
        return VPoker::HandRank::Quad->new(
            quad   => $quad,
            kicker => $self->_find_kicker($quad),
        );
    }

    my @trip = $self->_any_trip;
    my $trip;
    my @pairs = $self->_any_pair;

    ## ---------------------
    ## Checking for fullhouse;
    if (@trip) {
        if ( scalar @trip == 2 ) {
            if ( $trip[0]->card(1) > $trip[1]->card(1) ) {
                return VPoker::HandRank::FullHouse->new(
                    trip => $trip[0],
                    pair => [ $trip[1]->card(1), $trip[1]->card(2) ],
                );
            }
            else {
                return VPoker::HandRank::FullHouse->new(
                    trip => $trip[1],
                    pair => [ $trip[0]->card(1), $trip[0]->card(2) ],
                );
            }
        }
        else {
            $trip = $trip[0];
        }

        if (@pairs) {
            if ( defined $pairs[1] && $pairs[1]->card(1) > $pairs[0]->card(1) )
            {
                return VPoker::HandRank::FullHouse->new(
                    trip => $trip,
                    pair => $pairs[1],
                );
            }
            return VPoker::HandRank::FullHouse->new(
                trip => $trip,
                pair => $pairs[0],
            );
        }

    }

    ## ---------------------
    ## Checking for flush
    return VPoker::HandRank::Flush->new($flush) if ( defined $flush );

    ## ---------------------
    ## Checking for straight
    my $straight = $self->_any_straight;
    return VPoker::HandRank::Straight->new($straight) if defined $straight;

    ## --------------------
    ## Checking for trip
    if ( defined $trip ) {
        return VPoker::HandRank::Trip->new(
            trip    => $trip,
            kickers => $self->_find_kicker( $trip, 2 ),
        );
    }

    ## -------------------
    ## Checking for two pair
    if ( scalar @pairs == 2 ) {
        return VPoker::HandRank::TwoPairs->new(
            pair1  => $pairs[0],
            pair2  => $pairs[1],
            kicker => $self->_find_kicker( VPoker::CardSet->new(@pairs) ),
        );
    }
    elsif ( scalar @pairs == 1 ) {
        return VPoker::HandRank::OnePair->new(
            pair    => $pairs[0],
            kickers => $self->_find_kicker( $pairs[0], 3 ),
        );
    }

    ## OK Having nothing here return high cards
    return VPoker::HandRank::HighCards->new( $self->_find_kicker( undef, 5 ) );

}

## ----------------------------------------------------------------------------
sub has_flush_draw {
    my $self   = shift;
    my @cards  = $self->sort;
    my $suited = {
        VPoker::Card::CLUB()    => VPoker::CardSet->new,
        VPoker::Card::DIAMOND() => VPoker::CardSet->new,
        VPoker::Card::HEART()   => VPoker::CardSet->new,
        VPoker::Card::SPADE()   => VPoker::CardSet->new,
    };

    for ( my $i = 0 ; $i < scalar @cards ; $i++ ) {
        $suited->{ $cards[$i]->suit }->add( $cards[$i] );
    }

    while ( my ( $key, $value ) = each %$suited ) {
        return VPoker::HandRank::FlushDraw->new($value)
          if ( $value->size == 4 );
    }

    return undef;
}

## ----------------------------------------------------------------------------
## currently this work for a set of max 6 cards - for holdem only
sub has_straight_draw {
    my $self        = shift;
    my @sortedCards = $self->sort;
    my @cards       = ();
    my $previousCard;

    foreach my $card (@sortedCards) {
        if ( defined $previousCard && $previousCard == $card ) {
            next;
        }
        else {
            push @cards, $card;
        }
        $previousCard = $card;

    }

    return undef if scalar @cards < 4;

    unshift @cards, $self->high_card if ( $self->has('A') );

    my @set1 = ( $cards[0], $cards[1], $cards[2], $cards[3] );
    my @set2;
    @set2 = ( $cards[1], $cards[2], $cards[3], $cards[4] )
      if ( defined $cards[4] );
    my @set3;
    @set3 = ( $cards[2], $cards[3], $cards[4], $cards[5] )
      if ( defined $cards[5] );

    my $straightDraw = VPoker::CardSet->new;
    $straightDraw->add(@set1) if $self->_is_straight_draw(@set1);
    $straightDraw->add(@set2) if $self->_is_straight_draw(@set2);
    $straightDraw->add(@set3) if $self->_is_straight_draw(@set3);

    if ( $straightDraw->size > 0 ) {
        return VPoker::HandRank::StraightDraw->new($straightDraw);
    }
    else {
        return undef;
    }

}

## ----------------------------------------------------------------------------
sub _is_straight_draw {
    my ( $class, @cards ) = @_;
    my $cardSet = VPoker::CardSet->new(@cards);
    return 0 if ( $cardSet->size < 4 );
    return 1 if ( $cardSet->is_connected );

    my @sortedCards = $cardSet->sort;
    my $lowCard     = $cardSet->low_card;
    my $highCard    = $cardSet->high_card;
    my $tmpCard     = $lowCard;
    while ( $tmpCard < $highCard ) {
        my $tmpCardSet = VPoker::CardSet->new(@cards);
        $tmpCardSet->add($tmpCard);
        return 1 if ( $tmpCardSet->_any_straight );

        $tmpCard = VPoker::Card->new(
            rank => $tmpCard->rank + 1,
            suit => 'x',
        );
    }
    return 0;

}

## ----------------------------------------------------------------------------
sub _find_kicker {
    my ( $self, $cardSet, $kickerNumber ) = @_;
    $kickerNumber = $kickerNumber || 1;
    $cardSet = VPoker::CardSet->new if not defined $cardSet;
    my $kickers = VPoker::CardSet->new;
    my @sortedCards = $self->sort( 'desc' => 1 );
    for ( my $i = 0 ; $i < $kickerNumber ; $i++ ) {
        foreach my $card (@sortedCards) {
            if (   ( not $cardSet->has($card) )
                && ( not $kickers->has($card) ) )
            {
                $kickers->add($card);
            }
        }
    }

    if ( $kickerNumber == 1 ) {
        return $kickers->card(1);
    }
    else {
        return $kickers;
    }
}

## ----------------------------------------------------------------------------
sub sort {
    my ( $self, %options ) = @_;
    if ( exists $options{'desc'} && $options{'desc'} ) {
        return sort { $b <=> $a } @{ $self->cards };
    }
    else {
        return sort @{ $self->cards };
    }
}

## -----------------------------------------------------------------------------
sub validate_card_faces {
    my ($self, $cards) = @_;
    return $cards =~ /^([23456789TJQKA]+)([s])?$/;
}

1;
