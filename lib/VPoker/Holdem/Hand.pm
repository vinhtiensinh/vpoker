package VPoker::Holdem::Hand;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;

use VPoker::Holdem::BetRound;
use VPoker::Holdem::BoardCards;
use VPoker::Debugger;
use VPoker::Table;

##
## preflop, flop, turn and river are betting round (VPoker::Holdem::BetRound objects)
## for a specific cards on a certain betting round use board->flop, turn, river
__PACKAGE__->has_attributes(
    'table',             'board',
    'players',           'dealer_chair',
    'small_blind_chair', 'big_blind_chair',
    'preflop',           'flop',
    'turn',              'river',
    'winner',            'winning_hand',
    'pot',               'small_blind',
    'big_blind'
);

## ----------------------------------------------------------------------------
## sub new_action # delegate to bet_round, create new action for the hand
__PACKAGE__->delegate(
    'new_action'     => [ 'bet_round', 'new_action' ],
    'current_bet'    => [ 'bet_round', 'bet' ],
    'current_bet_of' => [ 'bet_round', 'bet_of' ],
    'last_action_of' => [ 'bet_round', 'last_action_of' ],
);

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init(%args);
    $self->preflop( VPoker::Holdem::BetRound->new_preflop(hand => $self) );
    $self->board( VPoker::Holdem::BoardCards->new );
    $self->pot(0);
    return $self;
}

## ----------------------------------------------------------------------------
sub bet_round {
    my $self = shift;
    return $self->river if ( $self->river );
    return $self->turn  if ( $self->turn );
    return $self->flop  if ( $self->flop );
    return $self->preflop;
}

## ----------------------------------------------------------------------------
sub deal {
    my ( $self, @cards ) = @_;

    $self->pot( $self->total_pot );

    if ( $self->bet_round->is_preflop ) {
        $self->flop( VPoker::Holdem::BetRound->new_flop(hand => $self) );
    }
    elsif ( $self->bet_round->is_flop ) {
        $self->turn( VPoker::Holdem::BetRound->new_turn(hand => $self) );
    }
    elsif ( $self->bet_round->is_turn ) {
        $self->river( VPoker::Holdem::BetRound->new_river(hand => $self) );
    }
    else {
        die('river card is already dealt cant accept more card');
    }

    $self->update_bet_position;
    $self->board->add(@cards);
}

## ----------------------------------------------------------------------------
sub actions {
    my $self    = shift;
    my $actions = VPoker::ActionSet->new;
    $actions->add( $self->preflop->actions ) if $self->preflop;
    $actions->add( $self->flop->actions )    if $self->flop;
    $actions->add( $self->turn->actions )    if $self->turn;
    $actions->add( $self->river->actions )   if $self->river;
    return $actions;
}

## ---------------------------------------------------------------------------
sub flop_cards {
    my $self = shift;
    return VPoker::CardSet->new(
        $self->board->card(1),
        $self->board->card(2),
        $self->board->card(3),
    );
}

## ----------------------------------------------------------------------------
sub turn_card {
  my $self = shift;
  return $self->board->card(4);
}
## ----------------------------------------------------------------------------
sub river_card {
  my $self = shift;
  return $self->board->card(5);
}

## ----------------------------------------------------------------------------
sub to_act {
    my $self = shift;

    ## have have no action, nobody post blind or anything, cant decide
    return undef if ( $self->actions->total == 0 );

    if ( $self->bet_round->actions->total == 0 ) {
        return $self->dealer_chair->next_playing->player;
    }

    my $lastAction = $self->actions->last;
    return $self->big_blind_chair->next_playing->player if $lastAction->is_post;

    my $nextPlayer = $lastAction->player->next_playing;
    if ( $nextPlayer->has_turn_to_act ) {
        return $nextPlayer;
    }
    else {
        return undef;
    }
}

## ----------------------------------------------------------------------------
sub players_to_act {
    my $self        = shift;
    my $playerToAct = $self->to_act;
    my $player      = $playerToAct;
    return () if not defined $player;

    my @players = ();
    do {
        push @players, $player if $player->has_turn_to_act;
        $player = $player->next_playing;
    } while ( $player != $playerToAct );

    return @players;
}

## ----------------------------------------------------------------------------
sub total_pot {
    my $self        = shift;
    my $dealerChair = $self->dealer_chair;
    my $total       = 0;

    foreach my $chairNo (0 .. VPoker::Table::MAX_CHAIRS()-1) {
        if ( $self->table->chair($chairNo)->player ) {
            $total += $self->current_bet_of( $self->table->chair($chairNo)->player );
        }
    }
    return $total + $self->pot;
}

sub finished {
    my $self = shift;
    return $self->bet_round->players_remain <= 1;
}

## ----------------------------------------------------------------------------
sub update_bet_position {
    my $self = shift;
    my $nextDealerChair = $self->dealer_chair->next;
    my $tmpChair        = $nextDealerChair;
    my $betPosition     = 1;

    do {
        if ( defined $tmpChair->player && $tmpChair->player->in_play ) {
            $self->bet_round->position_of( $tmpChair->player, $betPosition );
            $betPosition++;
        }
        $tmpChair = $tmpChair->next;
    } while ( $tmpChair != $nextDealerChair );
}

1;
