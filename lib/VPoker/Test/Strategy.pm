package VPoker::Test::Strategy;

use strict;
use warnings;
no warnings 'redefine';
no warnings 'once';

use Test::More;
use Test::MockModule;

use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;

sub setup_strategy_condition {
  my %given = @_ ;

  my $mockRuleBasedStrategy =
    new Test::MockModule('VPoker::Holdem::Strategy');

  $mockRuleBasedStrategy->mock('bet_round', sub {
      my $method = 'new_' . $given{'bet_round'};
      return VPoker::Holdem::BetRound->$method;
  }) if $given{'bet_round'};

  $mockRuleBasedStrategy->mock('hole_cards', sub {
      return VPoker::Holdem::HoleCards->new(@{$given{'hole_cards'}});
  }) if $given{'hole_cards'};

  $mockRuleBasedStrategy->mock('players_behind', sub {
      return $given{'players_behind'};
  }) if $given{'players_behind'};

  $mockRuleBasedStrategy->mock('hand_bet', sub {
      return $given{'hand_bet'};
  }) if exists $given{'hand_bet'};

  $mockRuleBasedStrategy->mock('to_call', sub {
      return $given{'to_call'} || 0;
  });

  $mockRuleBasedStrategy->mock(
      'bet' => sub {
          my ($class, $amount) = @_;
          my $self = shift;
          $self->{'_test_action_'} = 'bet',
          $self->{'_test_amount_'} = $amount,
      },
      'call' => sub {
         shift->{'_test_action_'} = 'call',
      },
      'check_or_fold' => sub {
         shift->{'_test_action_'} = 'check or fold',
      },
      'table' => sub {
          return VPoker::Table->new
      },
      'hand' => sub {
          return VPoker::Holdem::Hand->new
      },
      '_test_action_' => sub {return shift->{'_test_action_'}},
      '_test_amount_' => sub {return shift->{'_test_amount_'}},
  );

  my $mockChipEvaluator = Test::MockModule->new('VPoker::ChipEvaluator');
  $mockChipEvaluator->mock( 'evaluate' => sub { shift; return shift;});

  my $mockHoldemHand =
    new Test::MockModule('VPoker::Holdem::Hand');

  $mockHoldemHand->mock('big_blind', sub {
      return $given{'big_blind'};
  }) if $given{'big_blind'};


  return {
    '_mockChipEvaluator'     => $mockChipEvaluator,
    '_mockStrategyRuleBased' => $mockRuleBasedStrategy,
    '_mockHoldemHand'        => $mockHoldemHand,
  }
}

1;
