package VPoker::Holdem::Strategy::Limit;
use base qw(VPoker::Holdem::Strategy);
use strict;
use warnings;
use diagnostics;

sub bet {

    my $self = shift;
    if ( $self->bet_round->is_preflop || $self->bet_round->is_flop ) {

        ## 4 big bet cap
        if ( $self->hand_bet == ( $self->hand->big_blind * 4 ) ) {
            return $self->call;
        }

        return $self->SUPER::bet( $self->to_call + $self->hand->big_blind );
    }
    else {
        ## 4 big bet cap
        if ( $self->hand_bet == ( $self->hand->big_blind * 8 ) ) {
            return $self->call;
        }
        return $self->SUPER::bet( $self->to_call + $self->hand->big_blind * 2 );
    }
}

sub raise {
  return shift->bet(@_);
}

1;
