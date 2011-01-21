package VPoker::Holdem::Strategy;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;

use Carp;
__PACKAGE__->has_attributes( 'player' ); 
__PACKAGE__->delegate(
    'hole_cards'     => [ 'player',    'hole_cards' ],
    'balance'        => [ 'player',    'balance' ],
    'current_bet'    => [ 'player',    'current_bet' ],
    'table'          => [ 'player',    'table' ],
    'seat'           => [ 'player',    'seat' ],
    'post'           => [ 'player',    'post' ],
    'bet'            => [ 'player',    'bet' ],
    'call'           => [ 'player',    'call' ],
    'raise'          => [ 'player',    'raise' ],
    'fold'           => [ 'player',    'fold' ],
    'allin'          => [ 'player',    'allin' ],
    'check'          => [ 'player',    'check' ],
    'to_call'        => [ 'player',    'to_call' ],
    'check_or_fold'  => [ 'player',    'check_or_fold' ],
    'hand'           => [ 'table',     'current_hand' ],
    'hand_bet'       => [ 'hand',      'current_bet' ],
    'board'          => [ 'hand',      'board' ],
    'bet_round'      => [ 'hand',      'bet_round' ],
    'preflop'        => [ 'hand',      'preflop'],
    'flop'           => [ 'hand',      'flop'],
    'flop_cards'     => [ 'hand',      'flop_cards'],
    'turn'           => [ 'hand',      'turn'],
    'turn_card'      => [ 'hand',      'turn_card'],
    'river'          => [ 'hand',      'river'],
    'river_card'     => [ 'hand',      'river_card'],
    'total_pot'      => [ 'hand',      'total_pot'],
    'players_remain' => [ 'bet_round', 'players_remain' ],
);

sub play_all {
    my $self = shift;
    return $self->fold;
}

## ----------------------------------------------------------------------------
sub position {
    my $self = shift;
    return $self->bet_round->position_of( $self->player );
}
## ----------------------------------------------------------------------------
## Position methods
sub bet_position_any_of {
    my ( $self, @positions ) = @_;
    foreach my $position (@positions) {
        return 1 if $self->position == $position;
    }
    return 0;
}


sub all_cards {
    my $self = shift;
    return VPoker::CardSet->new( $self->hole_cards, $self->board );
}

sub strength {
    my $self = shift;
    return $self->all_cards->strength;
}

sub players_behind {
    my $self = shift;
    return $self->bet_round->players_behind($self->player);
}

sub players_before {
    my $self = shift;
    return $self->bet_round->players_before($self->player);
}

sub evaluator {
    my $self = shift;
    return VPoker::ChipEvaluator->new($self->table);
}

1;
