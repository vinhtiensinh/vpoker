package VPoker::Holdem::Strategy::RuleBased::Condition::Caller;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);

## ----------------------------------------------------------------------------
sub condition_value {
    my $self = shift;
    return scalar $self->strategy->bet_round->active_callers;
}

1;
