package VPoker::Holdem::Strategy::RuleBased::Condition::HandRank;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Pattern);

use strict;
use warnings;
## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;
    return $self->TRUE if $self->SUPER::_validate($value);
    return $self->validator->is_any_of(
        $value,
        'straight flush',
        'four of a kind',
        'quad',
        'fullhouse',
        'flush',
        'straight',
        'trip',
        'set',
        'two pairs',                  '2 pairs',
        'pair',                       '1 pair', 'a pair', 'one pair',
        'high cards',                 'nothing',
        'flush draw',
        'straight draw',
        'gut shot straight draw',
        'open ended straight draw',
        'busted belly straight draw',
        'suited',
        'connected',
    );
}

## ----------------------------------------------------------------------------
## condition value should be a CardSet
sub condition_value {
    die('sub class should implement this method');
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;
    if ($self->can(join('_', '_check', $self->_parse_value($value)))) {

      return $self->SUPER::_check(join('_', $self->_parse_value($value)));
    }
    else {
      return $self->SUPER::_check($value);
    }
}

sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        'gut shot straight draw' => sub {
            my ($self) = @_;
            my $straightDraw = $self->condition_value->has_straight_draw;
            return($straightDraw && $straightDraw->is_gut_shot);
        },
        'open ended straight draw' => sub {
            my ($self) = @_;
            my $straightDraw = $self->condition_value->has_straight_draw;
            return($straightDraw && $straightDraw->is_open_ended);
        },
        'busted belly straight draw' => sub {
            my ($self) = @_;
            my $straightDraw = $self->condition_value->has_straight_draw;
            return($straightDraw && $straightDraw->is_busted_belly);
        },
        'pair $>|<|>=|<=$ $card$' => sub {
            my ($self, $compare, $value) = @_;
            my $strength = $self->_strength;
            return $self->FALSE unless $strength->is_pair;

            if($compare eq '>') {
                return $strength->pair_card > $value;
            }
            elsif($compare eq '<') {
                return $strength->pair_card < $value;
            }
            elsif($compare eq '>=') {
                return $strength->pair_card >= $value;
            }
            elsif($compare eq '<=') {
                return $strength->pair_card <= $value;
            }
        },
        '$2|two$ $pair|pairs$ $>|<|>=|<=$ $card$' => sub {
            my ($self, $two, $pair, $compare, $value) = @_;
            my $strength = $self->_strength;
            return $self->FALSE unless $strength->is_two_pairs;

            if($compare eq '>') {
                return (
                  $strength->low_pair_card > $value &&
                  $strength->high_pair_card > $value
                );

            }
            elsif($compare eq '<') {
                return (
                  $strength->low_pair_card < $value &&
                  $strength->high_pair_card < $value
                );
            }
            elsif($compare eq '>=') {
                return (
                  $strength->low_pair_card >= $value &&
                  $strength->high_pair_card >= $value
                );
            }
            elsif($compare eq '<=') {
                return (
                  $strength->low_pair_card <= $value &&
                  $strength->high_pair_card <= $value
                );
            }
        },

        'straight $card$ high' => sub {
            my ($self, $card) = @_;
            return $self->FALSE unless $self->_check('straight');
            return $self->_strength->high->is($card);
        },

        'flush $card$ high[opt]' => sub {
            my ($self, $high_card) = @_;
            my $strength = $self->_strength;

            if ($strength->is_flush && $high_card) {
                return $strength->high_card->rank == VPoker::Card::RANK_VALUE->{$high_card};
            }
            else {
                return $strength->is_flush;
            }
        },

        'flush $>|>=$ $card$' => sub {
            my ($self, $compare, $card) = @_;
            my $strength = $self->_strength;

            my $card_high = VPoker::Card::RANK_VALUE->{$card};
            my $strength_high = $strength->high_card->rank;

            return eval "$strength_high $compare $card_high";
        },

    );
} 

__PACKAGE__->delegate(
    '_strength'             => [ 'condition_value', 'strength'          ],
    '_check_straight_flush' => [ '_strength',       'is_straight_flush' ],
    '_check_quad'           => [ '_strength',       'is_quad'           ],
    '_check_fullhouse'      => [ '_strength',       'is_fullhouse'      ],
    '_check_flush'          => [ '_strength',       'is_flush'          ],
    '_check_straight'       => [ '_strength',       'is_straight'       ],
    '_check_trip'           => [ '_strength',       'is_trip'           ],
    '_check_two_pairs'      => [ '_strength',       'is_two_pairs'      ],
    '_check_pair'           => [ '_strength',       'is_pair'           ],
    '_check_high_cards'     => [ '_strength',       'is_high_cards'     ],
    '_check_flush_draw'     => [ 'condition_value', 'has_flush_draw'    ],
    '_check_straight_draw'  => [ 'condition_value', 'has_straight_draw' ],
    '_check_suited'         => [ 'condition_value', 'is_suited'         ],
    '_check_connected'      => [ 'condition_value', 'is_connected'      ],
    '_check_high_cards'     => [ '_strength',       'is_high_cards'     ],
);

__PACKAGE__->alias(
    '_check_quad'           => '_check_four_of_a_kind',
    '_check_trip'           => '_check_set',
    '_check_two_pairs'      => '_check_2_pairs',
    '_check_pair'           => [ '_check_one_pair', '_check_1_pair', '_check_a_pair' ],
    '_check_high_cards'        => [ '_check_nothing' ],
);

1;
