package VPoker::ActionSet;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);
use VPoker::Debugger;

__PACKAGE__->has_attributes('actions');

## ----------------------------------------------------------------------------
sub new {
    my ( $class, @actions ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init( actions => [] );
    $self->add(@actions) if @actions;
    return $self;
}

## ----------------------------------------------------------------------------
sub add {
    my ( $self, @newActions ) = @_;
    foreach my $newAction (@newActions) {
        if ( $newAction->isa('VPoker::Action') ) {
            push @{ $self->actions }, $newAction;
        }
        elsif ( $newAction->isa('VPoker::ActionSet') ) {
            $self->add( @{ $newAction->actions } );
        }
        else {
            die('expect VPoker::Action or VPoker::ActionSet only');
        }
    }
    return 1;
}

## ----------------------------------------------------------------------------
sub total {
    my $self = shift;
    return scalar @{ $self->actions };
}

## ----------------------------------------------------------------------------
sub action {
    my ( $self, $index ) = @_;
    return $self->actions->[ $index - 1 ];
}

## ----------------------------------------------------------------------------
sub player_actions {
    my ( $self, $player ) = @_;
    my $playerActions = VPoker::ActionSet->new;
    for ( my $i = 1 ; $i <= $self->total ; $i++ ) {
        my $action = $self->action($i);
        $playerActions->add($action) if ( $action->player == $player );
    }
    return $playerActions;
}

## ----------------------------------------------------------------------------
sub max_bet {
    my $self   = shift;
    my $maxBet = 0;
    foreach my $action ( @{ $self->actions } ) {
        $maxBet = $action->amount if ( $action->amount > $maxBet );
    }
    return $maxBet;
}
## ---------------------------------------------------------------------------=
sub last_action_of {
    my ( $self, $player ) = @_;
    my $lastAction = undef;
    foreach my $action ( @{ $self->actions } ) {
        $lastAction = $action if ( $action->player == $player );
    }
    return $lastAction;

}

## ----------------------------------------------------------------------------
sub bet_of {
    my ( $self, $player ) = @_;
    my $lastAction;
    $lastAction = $self->last_action_of($player);
    return $lastAction ? $lastAction->amount : 0;
}

## ----------------------------------------------------------------------------
sub last {
    my $self = shift;
    if ( $self->total > 0 ) {
        return $self->actions->[-1];
    }
    else {
        return undef;
    }
}

## ----------------------------------------------------------------------------
sub raises {
    my $self   = shift;
    my @raises = ();
    foreach my $action ( @{ $self->actions } ) {
        push @raises, $action if ( $action->is_raise || $action->is_bet );
    }
    return @raises;
}

sub active_callers {
    my $self     = shift;
    my %callers  = ();
    my %players  = ();
    foreach my $action ( @{ $self->actions } ) {
        $callers{$action->player->name} = $action->player if ( $action->is_call && $action->player->in_play);
    }
    return values %callers;
}

1;
