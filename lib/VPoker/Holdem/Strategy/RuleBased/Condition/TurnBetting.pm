package VPoker::Holdem::Strategy::RuleBased::Condition::TurnBetting;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Betting);
use VPoker::Debugger;

sub bet_round {
  my $self = shift;
  return $self->strategy->hand->turn;
}

1;
