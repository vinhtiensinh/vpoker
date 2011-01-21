package VPoker::Holdem::Strategy::RuleBased::Condition::Turn;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::BoardCards);
use VPoker::CardSet;

## ----------------------------------------------------------------------------
sub condition_value {
  my $self = shift;
  return VPoker::CardSet->new($self->strategy->flop_cards, $self->strategy->turn_card);
}

1;
