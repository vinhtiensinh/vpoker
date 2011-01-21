package VPoker::Holdem::Strategy::RuleBased::Condition::ActionRound;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);

## ----------------------------------------------------------------------------
sub condition_value {
    my $self = shift;
    return scalar $self->strategy->bet_round->action_round;
}

1;