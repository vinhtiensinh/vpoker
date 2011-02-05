package VPoker::Holdem::Strategy::RuleBased::Condition::Hand;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::HandRank);
use strict;
use warnings;
## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;
    return
    $self->SUPER::_validate($value)
    || $self->_is_high_card_value($value)
    || $self->validator->is_any_of(
        $value,
        'bottom 2 pairs',
        'top 2 pairs',
        'over pair',
        'top pair',
        'top kicker',
    );
}
## ----------------------------------------------------------------------------
sub condition_value {
    my $self = shift;
    return $self->strategy->all_cards;
}

## ----------------------------------------------------------------------------
sub _is_high_card_value {
    my ($self, $value) = @_;
    my ($high, $card, $check, @arguments) = $self->_parse_value($value);

    foreach my $argument (@arguments) {
        return $self->FALSE unless $self->validator->is_any_of(
            $argument,
            qw(2 3 4 5 6 7 8 9 T J Q K A),
        );
    }

    return ($high  eq 'high') and ($card eq 'card') and (
        ( $check eq 'greater' && scalar @arguments == 1 )
            or ( $check eq 'less'    && scalar @arguments == 1 )
            or ( $check eq 'is'      && scalar @arguments == 1 )
            or ( $check eq 'between' && scalar @arguments == 2 )
    );
}

## ----------------------------------------------------------------------------
sub _check_bottom_2_pairs {
    my ($self) = @_;
    return (
        $self->_strength->is_two_pairs
        && $self->strategy->board->high_card != $self->_strength->high_pair_card
        && $self->strategy->board->high_card != $self->_strength->low_pair_card
    );
}
## ----------------------------------------------------------------------------
sub _check_top_2_pairs {
    my ($self) = @_;
    return (
        $self->_strength->is_two_pairs
        && $self->strategy->board->high_card == $self->_strength->high_pair_card
        && $self->strategy->board->high_card(2) == $self->_strength->low_pair_card
    );
}



## ----------------------------------------------------------------------------
sub _check_top_kicker {
    my $self = shift;
    if($self->_strength->is_pair or $self->_strength->is_two_pair) {
        return $self->_strength->top_kicker;
    }
    else {
        return $self->_kicker == 'A';
    }
}

sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        'pair $card$[opt]' => sub {
            my ($self, $card) = @_;
            my $strength = $self->_strength;
            return $self->FALSE if $strength->is_not_pair;

            if ($strength && $card) {
                return $strength->pair_card->rank == VPoker::Card::RANK_VALUE->{$card};
            }
            return $strength;
        },
        'pair on turn' => sub {
            my ($self) = @_;
            my $strength = $self->_strength;
            return $self->FALSE if $strength->is_not_pair;
            return $self->TRUE  if $strength->pair_card == $self->strategy->hand->turn_card;
        },

        'over pair' => sub {
            my $self = shift;
            return (
                $self->strategy->hole_cards->is_pair
                && $self->strategy->hole_cards->high_card > $self->strategy->board->high_card
            );
        },

        'bottom straight' => sub {
            my ($self) = @_;

            my $strength = $self->_strength;
            return $self->FALSE if $strength->is_not_straight;
            if (
                $self->strategy->hole_cards->has($strength->low) &&
                $self->strategy->board->has(VPoker::Card->new(
                        'rank' => $strength->high->rank,
                        'suit' => 'x',
                    ))) 
            {
                return $self->TRUE;
            }

            return $self->FALSE;
        },

        'nut straight' => sub {
            my ($self) = @_;

            my $hole_cards = $self->strategy->hole_cards;
            my $strength= $self->_strength;

            return $self->FALSE if $strength->is_not_straight;
            return $self->TRUE if $strength->high->is('A');

            if (
                $strength->high_card->is($hole_cards->high_card) &&
                $strength->high_card(2)->is($hole_cards->high_card(2)) &&
                $self->strategy->board->not_has($hole_cards->card(1)->rank_face) &&
                $self->strategy->board->not_has($hole_cards->card(2)->rank_face)
            ) { return $self->TRUE }

            return $self->FALSE;
        },

        'top pair $<|>|<=|>=$[opt] $card$[opt]' => sub {
            my ($self, $compare, $card) = @_;
            my $is_top_pair = (
                $self->_strength->is_pair
                && $self->_strength->pair_card == $self->strategy->board->high_card
            );

            if ($is_top_pair && $card) {
                my $pair_rank = $self->_strength->pair_card->rank;
                my $compare_card_rank = VPoker::Card::RANK_VALUE->{$card};
                $compare = $compare || '==';

                return eval "$pair_rank $compare $compare_card_rank";
            }
            return $is_top_pair;

        },
        'second pair' => sub {
            my $self = shift;
            my $strength = $self->_strength;

            return $self->FALSE unless $strength->is_pair;

            return $self->TRUE if $strength->pair_card >= $self->strategy->board->high_card(2);
            return $self->FALSE;
        },
        'nut flush draw' => sub {
            my $self = shift;
            my $flush_draw = $self->condition_value->has_flush_draw;
            return $self->FALSE unless $flush_draw;
            my $flush_suit = $flush_draw->high_card->suit;

            foreach(my $rank = 14; $rank >= 11; $rank--) {

                my $next_high_card = VPoker::Card->new(
                    rank => $rank,
                    suit => $flush_suit,
                );

                next if $self->strategy->board->has($next_high_card);
                return $self->strategy->hole_cards->has($next_high_card);
            }
            return $self->FALSE;
        },

        'flush draw $>=|>|<|<=$[opt] $card$ high[opt]' => sub {
            my ($self, $compare, $card) = @_;
            my $flush_draw = $self->condition_value->has_flush_draw;
            $compare = $compare || '==';
            return $self->FALSE unless $flush_draw;
            my $flush_draw_high_rank = $flush_draw->high_card->rank;
            my $compare_card_rank    = VPoker::Card::RANK_VALUE->{$card};
            return eval "$flush_draw_high_rank $compare $compare_card_rank";
        },
        'back door flush draw $>=|>|<|<=$[opt] $card$[opt] high[opt]' => sub {
            my ($self, $compare, $card) = @_;
            return $self->FALSE if $self->strategy->board->is_suited;

            my @cards = @{$self->strategy->all_cards->cards};

            my $back_door_flush_draw = undef;

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
                if ( $value->size >= 3 ) {
                    $back_door_flush_draw = $value;
                    last;
                }
            }

            return $self->FALSE unless $back_door_flush_draw;
            return $self->TRUE unless $card;

            
            my $flush_draw_high_rank = $back_door_flush_draw->high_card->rank;
            my $compare_card_rank    = VPoker::Card::RANK_VALUE->{$card};
            return eval "$flush_draw_high_rank $compare $compare_card_rank";
        },
        'nut flush' => sub {
            my $self = shift;
            my $flush = $self->_strength;
            return $self->FALSE unless $flush->is_flush;
            my $flush_suit = $flush->high_card->suit;

            foreach(my $rank = 14; $rank >= 11; $rank--) {

                my $next_high_card = VPoker::Card->new(
                    rank => $rank,
                    suit => $flush_suit,
                );

                next if $self->strategy->board->has($next_high_card);
                return $self->strategy->hole_cards->has($next_high_card);
            }
            return $self->FALSE;
        },

        'second best flush' => sub {
            my $self = shift;
            my $flush = $self->_strength;
            my $missing_high_card_count = 0;

            return $self->FALSE unless $flush->is_flush;
            my $flush_suit = $flush->high_card->suit;

            foreach(my $rank = 14; $rank >= 11; $rank--) {

                my $next_high_card = VPoker::Card->new(
                    rank => $rank,
                    suit => $flush_suit,
                );

                next if $self->strategy->board->has($next_high_card);
                $missing_high_card_count++ if $self->strategy->hole_cards->not_has($next_high_card);
            }

            return $missing_high_card_count == 1;
        },
        'kicker $<|>|<=|>=$[opt] $card$' => sub {
            my ($self, $compare, $card) = @_;

            my $kicker_rank = $self->_kicker->rank;
            my $card_rank   = VPoker::Card::RANK_VALUE->{$card};
            $compare = $compare || '==';
            return eval "$kicker_rank $compare $card_rank";
        },
        'top set' => sub {
            my ($self) = @_;
            my $strength = $self->_strength;
            return $strength->is_trip &&
                   $strength->trip_card->rank == $self->strategy->board->high_card->rank;
        },
        '$int$[opt] over $card|cards$' => sub {
            my ($self, $number) = @_;

            my $over_cards = 0;

            $over_cards++ if $self->strategy->hole_cards->high_card > $self->strategy->board->high_card;
            $over_cards++ if $self->strategy->hole_cards->high_card(2) > $self->strategy->board->high_card;

            if ($number) {
                return eval "$over_cards == $number";
            }
            else {
                return $over_cards;
            }
              
        },
        'two way straight draw'  => sub {
            my ($self) = @_;
            return $self->validate('open ended straight draw') ||
                  $self->validate('busted belly straight draw')
            ;
        }
    );
}

## ----------------------------------------------------------------------------
## high card only make sense for
## straight draw
## flush draw
## straight
## flush
## for any other type it simply return the highest card.
sub _high_card {
    my $self = shift;
    return $self->_strength->high_card;
}
## ----------------------------------------------------------------------------
## kicker is bested for
## one pair,
## two pair,
sub _kicker {
    my $self = shift;

    my $strength = $self->_strength;
    my $hole_cards = $self->strategy->hole_cards;

    if ($strength->is_pair) {
        return $hole_cards->high_card(2) if ($strength->pair_card == $hole_cards->high_card);
        return $hole_cards->high_card(1) if ($strength->pair_card == $hole_cards->high_card(2));
        return $hole_cards->high_card(1);
    }

    if ($strength->is_two_pairs) {
        return $strength->kicker if $strength->has($hole_cards);
        my $pair_cards = VPoker::CardSet->new($strength->high_pair_card, $strength->low_pair_card);
        return $hole_cards->high_card(2) if ($pair_cards->has($hole_cards->high_card->rank_face));
        return $hole_cards->high_card(1) if ($pair_cards->has($hole_cards->high_card(2)->rank_face));
        return $hole_cards->high_card(1);
    }

    if($self->_strength->can('kicker')) {
        return $self->_strength->kicker;
    }
    else {
        return $self->_strength->high_card;
    }
}

1;
