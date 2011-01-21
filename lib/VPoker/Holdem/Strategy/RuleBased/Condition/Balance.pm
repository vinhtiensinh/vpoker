package VPoker::Holdem::Strategy::RuleBased::Condition::Balance;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Chip);

sub condition_value {
    my $self = shift;
    return $self->strategy->player->balance;
}

1;