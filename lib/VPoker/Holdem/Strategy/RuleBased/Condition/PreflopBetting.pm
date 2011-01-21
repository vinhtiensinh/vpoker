package VPoker::Holdem::Strategy::RuleBased::Condition::PreflopBetting;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Betting);

sub bet_round {
    my $self = shift;
    return $self->strategy->preflop;
}

sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        'fold to me' => sub {
            my $self = shift;
            my $actions = $self->bet_round->actions->actions;
            foreach my $action (@$actions) {
                next if $action->is_post;
                return $self->TRUE if $action->player == $self->strategy->player;
                return $self->FALSE if $action->is_call || $action->is_bet;
            }

            $self->TRUE;
        },
    );
}

1;
