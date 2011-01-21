package VPoker::Action;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

__PACKAGE__->has_attributes( 'player', 'action', 'amount', 'time', );

use constant ACTION_FOLD  => 'fold';
use constant ACTION_CHECK => 'check';
use constant ACTION_CALL  => 'call';
use constant ACTION_BET   => 'bet';
use constant ACTION_RAISE => 'raise';
use constant ACTION_ALLIN => 'allin';
use constant ACTION_POST  => 'post';
use constant ACTION_PASS  => 'pass';

## ----------------------------------------------------------------------------
sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    $args{'time'}   = $args{'time'}   || time();
    $args{'amount'} = $args{'amount'} || 0;
    $self->init(%args);
    return $self;

}

## ----------------------------------------------------------------------------
sub new_fold {
    return shift->new( @_, 'action', ACTION_FOLD );
}

## ----------------------------------------------------------------------------
sub new_check {
    return shift->new( @_, 'action', ACTION_CHECK );
}

## ----------------------------------------------------------------------------
sub new_call {
    return shift->new( @_, 'action', ACTION_CALL );
}

## ----------------------------------------------------------------------------
sub new_bet {
    return shift->new( @_, 'action', ACTION_BET );
}

## ----------------------------------------------------------------------------
sub new_raise {
    return shift->new( @_, 'action', ACTION_RAISE );
}

## ----------------------------------------------------------------------------
sub new_allin {
    return shift->new( @_, 'action', ACTION_ALLIN );
}

## ----------------------------------------------------------------------------
sub new_post {
    return shift->new( @_, 'action', ACTION_POST );
}

## ----------------------------------------------------------------------------
sub new_pass {
    return shift->new( @_, 'action', ACTION_PASS );
}

## ----------------------------------------------------------------------------
sub is_fold {
    return shift->_is_action(ACTION_FOLD);
}

## ----------------------------------------------------------------------------
sub is_check {
    return shift->_is_action(ACTION_CHECK);
}

## ----------------------------------------------------------------------------
sub is_call {
    return shift->_is_action(ACTION_CALL);
}

## ----------------------------------------------------------------------------
sub is_bet {
    return shift->_is_action(ACTION_BET);
}

## ----------------------------------------------------------------------------
sub is_raise {
    return shift->_is_action(ACTION_RAISE);
}

## ----------------------------------------------------------------------------
sub is_allin {
    return shift->_is_action(ACTION_ALLIN);
}

## ----------------------------------------------------------------------------
sub is_post {
    return shift->_is_action(ACTION_POST);
}

## ----------------------------------------------------------------------------
sub is_pass {
    return shift->_is_action(ACTION_PASS);
}

## ----------------------------------------------------------------------------
sub _is_action {
    my ( $self, $action ) = @_;
    return $self->action eq $action;
}

1;
