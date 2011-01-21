package VPoker::Holdem::Strategy::RuleBased::Condition::Flop;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::BoardCards);
use VPoker::CardSet;

## ----------------------------------------------------------------------------
sub condition_value {
  my $self = shift;
  return $self->strategy->flop_cards;
}

1;
