package VPoker::Holdem::Player;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;
use VPoker::Debugger;

__PACKAGE__->has_attributes(
    'name',   'balance', 'chair',    'table',
    'active', 'hands',   'strategy', 'hole_cards',
);

__PACKAGE__->delegate(
    'current_hand' => [ 'table', 'current_hand' ],
    'in_play'      => [ 'chair', 'in_play' ],
);

## ----------------------------------------------------------------------------
sub join {
    my ( $self, $table, $chairNo ) = @_;
    $self->table($table);
    $self->chair( $table->chair($chairNo) );
    $self->table->chair($chairNo)->player($self);
}

## ----------------------------------------------------------------------------
sub leave {
    my $self = shift;
    $self->chair->player(undef);
    $self->chair(undef);
    $self->table(undef);
}

## ----------------------------------------------------------------------------
sub decide {
    my ($self) = @_;
    return $self->strategy->play;
}

## ----------------------------------------------------------------------------
sub bet {
    my ( $self, $amount ) = @_;
    my $realBet;
    if ( $self->balance < $amount ) {
        $realBet = $self->balance;
    }
    else {
        $realBet = $amount || 0;
    }
    
    my $handBet    = $self->current_hand->current_bet;
    my $currentBet = $self->current_bet;
    my $totalBet   = $realBet + $currentBet;

    my $action;
    if($totalBet > $handBet) {
        $action = $totalBet >= $self->balance ? 'allin' : 'bet';
    }
    elsif($totalBet < $handBet) {
        $action = $realBet > 0 ? 'call' : 'fold';
    }
    elsif($totalBet == $handBet) {
        $action = $handBet > 0 ? 'call' : 'check';
    }

    $self->balance( $self->balance - $realBet );
    $self->current_hand->new_action( $self, $action, $realBet + $currentBet );
    if ( $action eq VPoker::Action::ACTION_FOLD() ) {
        $self->in_play(0);
    }

    return $realBet;

}

## ----------------------------------------------------------------------------
sub fold {
    my $self = shift;
    return $self->bet(0);
}

## ----------------------------------------------------------------------------
sub check {
    my $self = shift;
    return $self->bet(0);
}

## ----------------------------------------------------------------------------
sub check_or_fold {
    my $self = shift;
    return $self->bet(0);
}

## ----------------------------------------------------------------------------
sub raise {
    my ( $self, $amount ) = @_;
    return $self->bet($amount);
}

## ----------------------------------------------------------------------------
sub call {
    my $self = shift;
    return $self->bet( $self->current_hand->current_bet - $self->current_bet );
}

## ----------------------------------------------------------------------------
sub allin {
    my $self = shift;
    return $self->bet( $self->balance );
}

## ----------------------------------------------------------------------------
sub post {
    my ( $self, $blind ) = @_;
    $self->balance( $self->balance - $blind );
    $self->current_hand->new_action( $self, 'post', $blind );
}

## ----------------------------------------------------------------------------
sub to_call {
    my $self = shift;
    return $self->current_hand->current_bet - $self->current_bet;

}

## ----------------------------------------------------------------------------
sub pass {
    my $self = shift;
    $self->current_hand->new_action( $self, 'pass');
}

## ----------------------------------------------------------------------------
sub current_bet {
    my $self = shift;
    return $self->current_hand->current_bet_of($self);
}

## ---------------------------------------------------------------------------
sub next_playing {
    my $self      = shift;
    my $nextChair = $self->chair;
    do { $nextChair = $nextChair->next; } while ( $nextChair->not_in_play );
    return $nextChair->player;
}

## ---------------------------------------------------------------------------
sub previous_playing {
    my $self          = shift;
    my $previousChair = $self->chair;
    do { $previousChair = $previousChair->next; }
      while ( $previousChair->not_in_play );
    return $previousChair->player;
}

## ----------------------------------------------------------------------------
sub has_turn_to_act {
    my $self = shift;
    if (
           $self->in_play
        && (
               (not defined $self->current_hand->bet_round->last_action_of($self))
            || ( $self->current_hand->last_action_of($self)->is_post )
            || ( $self->current_bet < $self->current_hand->current_bet )
           )
    ) {
        return 1;
    }
    return 0;
}

1;
