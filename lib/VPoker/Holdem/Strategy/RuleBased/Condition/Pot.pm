package VPoker::Holdem::Strategy::RuleBased::Condition::Pot;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Chip);

sub condition_value {
    my $self = shift;
    return $self->strategy->hand->total_pot;
}

1;