package VPoker::Holdem::Strategy::RuleBased::Condition::FlopBetting;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Betting);
use VPoker::Debugger;

sub bet_round {
  my $self = shift;
  return $self->strategy->hand->flop;
}

1;
