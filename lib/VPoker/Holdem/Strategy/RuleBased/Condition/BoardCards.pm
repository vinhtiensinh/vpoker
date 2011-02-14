package VPoker::Holdem::Strategy::RuleBased::Condition::BoardCards;
use strict;
use warnings;

use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::HandRank);
use VPoker::CardSet;

## ----------------------------------------------------------------------------
sub condition_value {
    my $self = shift;
    return $self->strategy->board;
}

## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(

        'possible flush'    => sub {
            my ($self) = @_;
            my %suitedHash = ();
            my @cards  = $self->condition_value->sort;
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
                return $self->TRUE if ( $value->size >= 3 );
            }

            return $self->FALSE;
        },

        'possible straight' => sub {
            my ($self)    = @_;
            my @cards    = ();
            foreach my $card ($self->condition_value->sort) {
                if (scalar @cards == 0 ) {
                    push @cards, $card;
                }
                elsif ($card > $cards[-1]) {
                    push @cards, $card;
                }
            }

            for(my $i = 2; $i < scalar @cards; $i++) {
                return $self->TRUE if ($cards[$i]->rank - $cards[$i - 2]->rank <= 4);
            }

            return $self->TRUE if $cards[-1]->is('A') && $cards[1] <= 5;

            return $self->FALSE;

        },

        '$>|<|<=|>=$[opt] $int$[opt] over $card|cards$' => sub {
            my ($self,$compare, $number) = @_;
            my $numberOfOverCard = 0;

            my @hole_cards  = @{$self->strategy->hole_cards->cards};
            my @board_cards = @{$self->condition_value->cards};
            foreach my $card (@board_cards) {
                $numberOfOverCard++ if $card > $self->strategy->hole_cards->high_card;
            }

            if ($compare) {
                return eval "$numberOfOverCard $compare $number";
            }
            elsif ($number) {
                return $numberOfOverCard == $number;
            }
            else {
                return $numberOfOverCard;
            }
        },

        '$1|one$ card flush' => sub {
            my ($self, $one) = @_;
            return ref($self->condition_value->has_flush_draw) ? $self->TRUE : $self->FALSE;

        },

        '$1|one$ card straight $<|>|<=|>=$[opt] $card$[opt]' => sub {
            my ($self, $one, $compare, $card) = @_;
            my $straight_draw = $self->condition_value->has_straight_draw;
            return $self->FALSE unless $straight_draw;

            if($compare) {
                my $compare_card_rank = VPoker::Card::RANK_VALUE->{$card};
                foreach my $complete_card (@{$straight_draw->complete_cards->cards}) {
                    my $complete_card_rank = $complete_card->rank;
                    return $self->FALSE unless eval "$complete_card_rank $compare $compare_card_rank";
                }
            }

            return $self->TRUE;

        },

        'rainbow' => sub {
            my ($self) = @_;
            my @cards = @{$self->condition_value->cards};
            my $suited = {
                VPoker::Card::CLUB()    => VPoker::CardSet->new,
                VPoker::Card::DIAMOND() => VPoker::CardSet->new,
                VPoker::Card::HEART()   => VPoker::CardSet->new,
                VPoker::Card::SPADE()   => VPoker::CardSet->new,
            };

            for ( my $i = 0 ; $i < scalar @cards ; $i++ ) {
                $suited->{ $cards[$i]->suit }->add( $cards[$i] );
            }

            foreach my $suit (values %$suited) {
                return $self->FALSE if $suit->size > 1;
            }

            return $self->TRUE;
        },

        'possible flush draw' => sub {
            my ($self) = @_;
            return $self->_check('not rainbow');
        },

        'possible straight draw' => sub {
            my ($self) = @_;
            my @cards = $self->condition_value->sort;

            for ( my $i = 1 ; $i < scalar @cards ; $i++ ) {
                return $self->TRUE if ($cards[$i]->rank - $cards[$i - 1]->rank <= 4);
                return $self->TRUE if ($self->condition_value->has('A') && $cards[$i]->rank <= 5);
            }

            return $self->FALSE;
        },

        'different cards $<|>|<=|>=$ $card$' => sub {
            my ($self, $compare, $card) = @_;
            return $self->FALSE if $self->_check('pair') || $self->_check('trip') || $self->_check('quad');
            my $low_card_rank     = $self->condition_value->low_card->rank;
            my $compare_card_rank = VPoker::Card::RANK_VALUE->{$card};
            return eval "$low_card_rank $compare $compare_card_rank";
        },

        '$less|more$[opt] than[opt] $int$ cards $<|>|<=|>=$ $card$' => sub {
            my ($self, $compare, $than, $number, $card_comparision, $compare_card) = @_;
            my $numberOfCard = 0;

            my @cards = $self->condition_value->sort;
            foreach my $card (@cards) {
                my $card_rank = $card->rank;
                my $compare_card_rank = VPoker::Card::RANK_VALUE->{$compare_card};

                $numberOfCard++ if eval "$card_rank $card_comparision $compare_card_rank";
            }

            $compare = $compare || '==';
            $compare = '>' if $compare eq 'more';
            $compare = '<' if $compare eq 'less';
            return eval "$numberOfCard $compare $number";
        },

        '$number$ cards connected' => sub {
            my ($self, $number) = @_;
            my @cards = $self->condition_value->sort;

            for ( my $i = 2 ; $i < scalar @cards ; $i++ ) {
                return $self->TRUE if VPoker::CardSet->new(
                    $cards[ $i - 2 ], $cards[ $i - 1 ], $cards[$i]
                )->is_connected;
            }
            return $self->TRUE if $self->condition_value->has('A23');

            return $self->FALSE;

        },

        '$cardset$' => sub {
            my ($self, $cards) = @_;
            return $self->condition_value->has($cards);
        },

        'over pair'  => sub {
            my $self = shift;
            my $pair = $self->strategy->board->strength;
            return $self->FALSE unless $pair->is_pair;
            my $hole_card_high = $self->strategy->hole_cards->high_card;
            return $pair->pair_card->rank > $hole_card_high->rank;
        },

        '$int$ cards suited'  => sub {
            my ($self, $number)  = @_;

            my %suitedHash = ();
            my @cards  = $self->condition_value->sort;
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
                return $self->TRUE if  $value->size == $number ;
            }

            return $self->FALSE;
        },
    );
}

1;
