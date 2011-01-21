package VPoker::Holdem::Strategy::RuleBased::Condition::Betting;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);
use VPoker::Debugger;

sub condition_value {
    my $self = shift;
    return scalar $self->bet_round->raise_actions;
}

sub bet_round {
    my $self = shift;
    return $self->strategy->bet_round;
}

## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        '$nobet|bet|raised|reraised$' => sub {
            my ($self, $text) = @_;
            return $self->_check(0)      if($text eq 'nobet');
            return $self->_check(1)      if($text eq 'bet');
            return $self->_check(2)      if($text eq 'raised');
            return $self->_check('>= 3') if($text eq 'reraised');
        },

        'bettor behind' => sub {
            my $self = shift;

            my $last_raise = $self->bet_round->last_raise;
            return $self->FALSE unless $last_raise;

            my $bettor = $last_raise->player;
            my @players_behind =
              $self->bet_round->players_behind($self->strategy->player);

            foreach my $player (@players_behind) {
              return $self->TRUE if $player == $bettor;
            }

            return $self->FALSE;
        },

        'any bettor behind' => sub {
            my ($self) = @_;
            foreach my $raise_action ($self->bet_round->raise_actions) {
              next if  $raise_action->player->not_in_play;

              my $autoplayer_position = $self->bet_round->position_of($self->strategy->player);
              my $raiser_position     = $self->bet_round->position_of($raise_action->player);
                return $self->TRUE if $raiser_position > $autoplayer_position;
            }

            return $self->FALSE;
        },

        '$opponent|autoplayer$ lead' => sub {
            my ($self, $player_lead) = @_;

            my $last_raise = $self->bet_round->last_raise;
            if ($last_raise) {
              return $self->TRUE if ( $player_lead eq 'autoplayer' ) && ( $last_raise->player == $self->strategy->player );
              return $self->TRUE if ( $player_lead eq 'opponent' )   && ( $last_raise->player != $self->strategy->player );

              return $self->FALSE;
            }
            else {
              return $self->FALSE;
            }
        },

        'autoplayer $bet|raised|reraised$' => sub {
            my ( $self, $bet ) = @_;
            my $counter = 0;
            foreach my $raise ($self->bet_round->raise_actions) {
                my $counter++;
                return $self->TRUE if (
                  ($counter == 1 && $bet eq 'bet')      ||
                  ($counter == 2 && $bet eq 'raised')   ||
                  ($counter >= 3 && $bet eq 'reraised')
                );
            }

            return $self->FALSE;
        },

        '$bet|raised|reraised$ from $early|middle|late$' => sub {
            my ($self, $bet, $position) = @_;
            return $self->FALSE if $self->_check_not($bet);
            my $bettor = $self->bet_round->last_raise->player;
            my $players_behind =  scalar @{ $self->bet_round->players } - $self->bet_round->position_of($bettor);

            if ($position eq 'early') {
              return $players_behind >= 4;
            }
            elsif ($position eq 'middle') {
              return $players_behind == 2 || $players_behind == 3;
            }
            elsif ($position eq 'late') {
              return $players_behind <= 1;
            }
        },

        'preflop bettor check' => sub {
            my ($self) = @_;
            my $has_act = 0;
            my $bettor = $self->strategy->hand->preflop->last_raise->player;
            my $bettor_action = $self->bet_round->actions->last_action_of($bettor);
            return $self->TRUE if $bettor_action && $bettor_action->is_check;
            return $self->FALSE;
        },
        'continue bet' => sub {
            my ($self) = @_;
            my $has_act = 0;
            my $bettor = $self->bet_round->previous->last_raise->player;
            my $bettor_action = $self->bet_round->actions->last_action_of($bettor);
            return $self->TRUE if $bettor_action && $bettor_action->is_bet;
            return $self->FALSE;
        },
    );
}

1;
