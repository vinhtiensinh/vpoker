package VPoker::Holdem::BetRound;
use base qw(VPoker::Base);
use strict;
use warnings;
use diagnostics;

use Carp;
use VPoker::ActionSet;
use VPoker::Action;
use VPoker::Debugger;
use VPoker::Holdem::Player;

__PACKAGE__->has_attributes( '_positions', 'actions', 'round', 'hand');
__PACKAGE__->delegate(
    'player_actions' => [ 'actions', 'player_actions' ],
    'bet'            => [ 'actions', 'max_bet'        ],
    'bet_of'         => [ 'actions', 'bet_of'         ],
    'last_action_of' => [ 'actions', 'last_action_of' ],
    'raise_actions'  => [ 'actions', 'raises'         ],
    'active_callers' => [ 'actions', 'active_callers' ],
);

use constant BET_ROUND_PREFLOP => 1;
use constant BET_ROUND_FLOP    => 2;
use constant BET_ROUND_TURN    => 3;
use constant BET_ROUND_RIVER   => 4;

## ----------------------------------------------------------------------------
sub new {
    my ( $class, @args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init(@args);
    $self->actions( VPoker::ActionSet->new ) if not $self->actions;
    $self->_positions( [] );
    return $self;
}

sub previous {
    my $self = shift;
    die 'calling previous on a preflop betround' if $self->is_preflop;
    return $self->hand->preflop if $self->is_flop;
    return $self->hand->flop if $self->is_turn;
    return $self->hand->turn if $self->is_river;
}

sub next {
    my $self = shift;
    die 'calling next on a river betround' if $self->is_river;
    return $self->hand->flop if $self->is_preflop;
    return $self->hand->turn if $self->is_flop;
    return $self->hand->river if $self->is_turn;
}
## ----------------------------------------------------------------------------
sub position_of {
    my ( $self, $player, $position ) = @_;
    if ( defined $position ) {
        $self->_positions->[ $position - 1 ] = $player;
    }
    else {
        my $tmpPosition = 0;
        foreach my $positionPlayer ( @{ $self->_positions } ) {
            $tmpPosition++;
            if ( $positionPlayer == $player ) {
                return $tmpPosition;
            }
        }
        return undef;
    }
}

sub players {
  my $self = shift;
  return $self->_positions;
}

## ----------------------------------------------------------------------------
sub player_at_position {
    my ( $self, $position ) = @_;
    return $self->_positions->[ $position - 1 ];
}

## ----------------------------------------------------------------------------
sub players_before {
    my ( $self, $player ) = @_;
    my @players = ();
    foreach my $tmpPlayer ( @{ $self->_positions } ) {
        if ( $tmpPlayer != $player && $tmpPlayer->in_play ) {
            push @players, $tmpPlayer;
        }
        else {
            last;
        }
    }

    return @players;

}
## ----------------------------------------------------------------------------
sub players_behind {
    my ( $self, $player ) = @_;
    my @players = ();

    my $startAdding = 0;

    foreach my $tmpPlayer ( @{ $self->_positions } ) {
        $startAdding = 1 if $tmpPlayer == $player;

        if ( $tmpPlayer != $player && $tmpPlayer->in_play && $startAdding ) {
            push @players, $tmpPlayer;
        }
    }

    return @players;

}

## ----------------------------------------------------------------------------
sub players_remain {
    my $self    = shift;
    my @players = ();
    foreach my $player ( @{ $self->_positions } ) {
        push @players, $player if $player->in_play;
    }
    return @players;

}

## -----------------------------------------------------------------------------
## action round started from 1 (means have not act)
sub action_round {
    my $self = shift;
    my $playerToAct   = $self->hand->to_act;

    if(not defined $playerToAct) {
    debug_message('---------------------------');
        foreach my $action (@{$self->actions->actions}) {
            debug_message($action->player->name . ' ' . $action->action . ' ' . $action->amount);
        }

        my $lastAction = $self->actions->last;
        debug_message($self->hand->dealer_chair->player->name . ' name on dealer');
        debug_message($lastAction->player->name . ' last action name ' . $lastAction->action);
        debug_message(' next playing ' . $lastAction->player->next_playing->name);
        debug_message('next playing has turn to act ' . $lastAction->player->next_playing->has_turn_to_act);
        debug_message('inplay ' . $lastAction->player->next_playing->in_play);
        debug_message('balance ' . $lastAction->player->next_playing->balance);

        debug_message('---------------------------');

    }
    
    my $playerActions = $self->actions->player_actions($playerToAct);

    if(
         $playerActions->total  == 0
      || ($playerActions->total == 1 && $playerActions->action(1)->is_post)
    ) {
        return 1;
    }
    else {
        return $playerActions->total + 1;
    }
}

## ----------------------------------------------------------------------------
sub new_preflop {
    return shift->new( @_, 'round', BET_ROUND_PREFLOP );
}
## ----------------------------------------------------------------------------
sub new_flop {
    return shift->new( @_, 'round', BET_ROUND_FLOP );
}
## ----------------------------------------------------------------------------
sub new_turn {
    return shift->new( @_, 'round', BET_ROUND_TURN );
}
## ----------------------------------------------------------------------------
sub new_river {
    return shift->new( @_, 'round', BET_ROUND_RIVER );
}

## ----------------------------------------------------------------------------
sub is_preflop {
    return shift->_is_bet_round(BET_ROUND_PREFLOP);
}

## ----------------------------------------------------------------------------
sub is_flop {
    return shift->_is_bet_round(BET_ROUND_FLOP);
}

## ----------------------------------------------------------------------------
sub is_turn {
    return shift->_is_bet_round(BET_ROUND_TURN);
}

## ----------------------------------------------------------------------------
sub is_river {
    return shift->_is_bet_round(BET_ROUND_RIVER);
}

## ----------------------------------------------------------------------------
sub new_action {
    my ( $self, $player, $action, $amount ) = @_;
    $self->actions->add(
        VPoker::Action->new(
            player => $player,
            action => lc($action),
            amount => $amount,
        )
    );
}

## ----------------------------------------------------------------------------
sub _is_bet_round {
    my ( $self, $round ) = @_;
    return $self->round == $round;
}

sub last_raise {
    my $self   = shift;
    my @raises = $self->raise_actions;
    if (@raises) {
        return pop @raises;
    }
    else {
        return undef;
    }

}

sub name {
    my $self = shift;
    return 'preflop' if $self->is_preflop;
    return 'flop'    if $self->is_flop;
    return 'turn'    if $self->is_turn;
    return 'river'   if $self->is_river;
}

1;
