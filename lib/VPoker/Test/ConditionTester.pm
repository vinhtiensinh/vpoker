package VPoker::Test::ConditionTester;
use base qw(VPoker::Base);

use strict;
use warnings;
no warnings 'redefine';
use Test::More;
no warnings 'once';
use VPoker::Test::Table;

package main;

sub create_condition {
  VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(@_);
}

sub test_condition {
  my (%options)  = @_;
  my $expected   = delete $options{'expected'};
  my $test       = delete $options{'test'};
  my $actions    = delete $options{'actions'};
  my $autoplayer = delete $options{'autoplayer'};
  my $players    = delete $options{'players'};
  my $strategyType = delete $options{'strategyType'};

  my $table = VPoker::Test::Table->create(
      players      => $players,
      strategyType => $strategyType,
  );

  $table->new_hand;
  $table->autoplayer($autoplayer);
  $table->actions(@$actions);

  my $strategy  = $table->player_strategy($autoplayer);
  $options{'name'}     = delete $options{'condition'};
  my $condition = create_condition(%options, strategy => $strategy);

  if ($expected) {
    ok($condition->is_satisfied, $test);
  }
  else {
    ok($condition->is_not_satisfied, $test);
  }

  $table->new_hand;
  $table->autoplayer($autoplayer);
  $table->actions(@$actions);
}

1;
