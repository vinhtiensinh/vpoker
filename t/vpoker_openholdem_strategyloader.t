use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;
use_ok('VPoker::OpenHoldem::StrategyLoader');
use_ok('VPoker::Holdem::Strategy::RuleBased::Limit');
use_ok('VPoker::Test::Table');

my $strategy = VPoker::Holdem::Strategy::RuleBased::Limit->new();
VPoker::OpenHoldem::StrategyLoader->strategy($strategy, "$FindBin::Bin/data/StrategyFiles");
$strategy->validate;
is(
  ref($strategy->decision('master')),
  'VPoker::Holdem::Strategy::RuleBased::RuleTable',
  'correctly use the file name master as the decision table',
);
is(
  ref($strategy->decision('AA')),
  'VPoker::Holdem::Strategy::RuleBased::RuleTable',
  'correctly use the file name AK as the decision table',
);
is(
  ref($strategy->decision('AK')),
  'VPoker::Holdem::Strategy::RuleBased::RuleTable',
  'correctly use the file name AA as the decision table',
);
is(
  ref($strategy->decision('call bet')),
  'VPoker::Holdem::Strategy::RuleBased::RuleTable',
  'correctly use the file name call bet as the rule table',
);

my $table = VPoker::Test::Table->create(
    players      => 3,
    strategyType => 'VPoker::Holdem::Strategy::RuleBased::Limit',
    autoplayer => 'dealer',
    autoplayerStrategy => $strategy,
    strategyType => 'limit',
);

$table->new_hand;
$table->actions('dealer cards Ac Ad');
$table->player_make_decision('dealer');
is($table->autoplayer_decision->action, 'bet', 'correct detect AA preflop decision');


$table->actions('sblinder bet');
$table->player_make_decision('dealer');
is($table->autoplayer_decision->action, 'bet', 'correct detect AA preflop decision always bet');


$table->actions(
  'deal Ah Kh Qh',
  'sblinder bet'
);
$table->player_make_decision('dealer');
is($table->autoplayer_decision->action, 'call', 'correct detect AA flop');

