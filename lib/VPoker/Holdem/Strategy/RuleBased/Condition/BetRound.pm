package VPoker::Holdem::Strategy::RuleBased::Condition::BetRound;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition);

## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;
    return $self->validator->is_any_of($value, qw(preflop flop turn river));
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;
    my $method = "is_$value";
    return $self->strategy->bet_round->$method;
}

1;