use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 4;
use VPoker::Test::Table;
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Test::ConditionTester;
use VPoker::Holdem::Strategy::RuleBased::ActionFactory;
use VPoker::Holdem::Strategy::RuleBased::Limit;

# test action calling the strategy custom rule table.
{
  my $autoplayerStrategy = VPoker::Holdem::Strategy::RuleBased::Limit->new();
  my $strategy = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
      Bet Round: flop [ gonna do some betting ]
  ', $autoplayerStrategy);
  my $custom_strategy = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create(' bet ', $autoplayerStrategy);
  $autoplayerStrategy->decision('master', $strategy);
  $autoplayerStrategy->decision('gonna do some betting', $custom_strategy);
  my $table = VPoker::Test::Table->create(
      players      => 3,
      autoplayer   => 'dealer',
      strategyType => 'limit',
      autoplayerStrategy => $autoplayerStrategy,
  );

  $table->new_hand;
  $table->actions(
      'deal Ac Ad Ah',
  );
  $table->player($table->autoplayer)->decide;
  my $action = $table->autoplayer_decision;
  is(
      $action->action, 'bet',
      'correctly call custom action',
  );
}

# test action contain multiple custom action.
{
  my $autoplayerStrategy = VPoker::Holdem::Strategy::RuleBased::Limit->new();
  my $strategy = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
      Bet Round: flop [ bet first, call bet ]
  ', $autoplayerStrategy);
  my $bet_first =
    VPoker::Holdem::Strategy::RuleBased::ActionFactory->create(
        'Betting: nobet [ bet ]', $autoplayerStrategy
  );
  my $call_bet =
    VPoker::Holdem::Strategy::RuleBased::ActionFactory->create(
        'Betting: bet [ call ]', $autoplayerStrategy
  );
  $autoplayerStrategy->decision('master', $strategy);
  $autoplayerStrategy->decision('bet first', $bet_first);
  $autoplayerStrategy->decision('call bet', $call_bet);
  my $table = VPoker::Test::Table->create(
      players      => 3,
      autoplayer   => 'dealer',
      strategyType => 'limit',
      autoplayerStrategy => $autoplayerStrategy,
  );
  $table->new_hand;
  $table->actions(
      'deal Ac Ad Ah',
      'sblinder check',
      'bblinder check',
  );
  $table->player($table->autoplayer)->decide;
  my $action = $table->autoplayer_decision;
  is(
      $action->action, 'bet',
      'multiple actions - correctly call custom action',
  );

  $table->new_hand;
  $table->actions(
      'deal Ac Ad Ah',
      'sblinder check',
      'bblinder bet',
  );

  #instead of check lest bet
  $table->player($table->autoplayer)->decide;
  $action = $table->autoplayer_decision;
  is(
      $action->action, 'call',
      'multiple actions - correctly skip the first unmatch action and call custom action',
  );

  # non of the action match, should fold
  $table->new_hand;
  $table->actions(
      'deal Ac Ad Ah',
      'sblinder bet',
      'bblinder bet',
  );

  #instead of check lest bet
  $table->player($table->autoplayer)->decide;
  $action = $table->autoplayer_decision;
  is(
      $action->action, 'fold',
      'multiple actions - correctly skip all the actions coz they are not match, call check or fold',
  );
}

