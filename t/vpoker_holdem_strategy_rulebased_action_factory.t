use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use_ok 'VPoker::Holdem::Strategy::RuleBased::Action';
use_ok 'VPoker::Holdem::Strategy::RuleBased::RuleTable';
use_ok 'VPoker::Holdem::Strategy::RuleBased::ActionFactory';
use_ok 'VPoker::Holdem::Strategy::RuleBased::Limit';

## Test Factory produce Betting Action
{
  my $action = create_action('bet');
  isa_ok($action, 'VPoker::Holdem::Strategy::RuleBased::Action');
  ok($action->action eq 'bet', 'normal action saved correctly');
}
## Test Factory produce RuleTable using the table format
{
  my $rule_table = create_action('
      Bet Round | Hole Cards | Action
      preflop   | suited     | bet
      flop      | pair       | check
  ');
  is(
    ref($rule_table),
    'VPoker::Holdem::Strategy::RuleBased::RuleTable',
    'table format - is a RuleTable object',
  );
  test_rule(
      $rule_table->rules->[0],
      'test'       => 'table format',
      'conditions' => [
        { 'type' => 'bet round', 'value'  => 'preflop' },
        { 'type' => 'hole cards', 'value' => 'suited'  }
      ],
      'action'     => 'bet',
  );
  test_rule(
      $rule_table->rules->[1],
      'test'       => 'table format',
      'conditions' => [
        { 'type' => 'bet round', 'value'  => 'flop' },
        { 'type' => 'hole cards', 'value' => 'pair' }
      ],
      'action'     => 'check',
  );
}

## Test Factory produce simple RuleTable
{
  my $rule_table = create_action('Bet Round: preflop [ bet ]');
  isa_ok($rule_table, 'VPoker::Holdem::Strategy::RuleBased::RuleTable');
  my $first_rule = $rule_table->rules->[0];
  isa_ok(
      $first_rule->conditions->[0],
      'VPoker::Holdem::Strategy::RuleBased::Condition::BetRound'
  );
  ok(
    $first_rule->conditions->[0]->value eq 'preflop',
    'single rule - correct rule condition value'
  );

  is(
    $first_rule->action->action,
    'bet',
    'single rule - correct rule action value'
  );
}
## Test Factory produce RuleTable with 2 condition
{
  my $rule_table = create_action('Bet Round: preflop | Hole Cards: suited [ bet ]');
  isa_ok($rule_table, 'VPoker::Holdem::Strategy::RuleBased::RuleTable');
  test_rule(
      $rule_table->rules->[0],
      'test'       => 'single rule, double condition',
      'conditions' => [
        { 'type' => 'bet round', 'value'  => 'preflop' },
        { 'type' => 'hole cards', 'value' => 'suited'  }
      ],
      'action'     => 'bet',
  );
}

## Test Factory produce RuleTable with 2 rules
{
  my $rule_table = create_action('
      Bet Round: preflop [ bet   ]
      Hole Cards: suited [ check ]
  ');
  isa_ok($rule_table, 'VPoker::Holdem::Strategy::RuleBased::RuleTable');
  test_rule(
      $rule_table->rules->[0],
      'test'       => 'double rule',
      'conditions' => [ { 'type' => 'bet round', 'value' => 'preflop' } ],
      'action'     => 'bet',
  );
  test_rule(
      $rule_table->rules->[1],
      'test'       => 'double rule',
      'conditions' => [ { 'type' => 'hole cards', 'value' => 'suited' } ],
      'action'     => 'check',
  );
}
## Test Factory produce RuleTable with 2 rules, one is nested
{
  my $rule_table = create_action('
      Bet Round: preflop [ bet   ]
      Hole Cards: suited [ 
        Betting: nobet [ check ]
      ]
  ');
  isa_ok($rule_table, 'VPoker::Holdem::Strategy::RuleBased::RuleTable');
  test_rule(
      $rule_table->rules->[0],
      'test'       => 'double rule, 1 nested',
      'conditions' => [ { 'type' => 'bet round', 'value' => 'preflop' } ],
      'action'     => 'bet',
  );
  test_rule(
      $rule_table->rules->[1],
      'test'       => 'double rule, 1 nested',
      'conditions' => [ { 'type' => 'hole cards', 'value' => 'suited' } ],
  );

  my $rule2_action = $rule_table->rules->[1]->action;
  is(
      ref($rule2_action),
      'VPoker::Holdem::Strategy::RuleBased::RuleTable',
      'double rule, 1 nested - nested action is a rule table',
  );
  test_rule(
      $rule2_action->rules->[0],
      'test'       => 'double rule, 1 nested, test nested rule',
      'conditions' => [ {'type' => 'betting', 'value' => 'nobet'} ],
      'action'     => 'check',
  );
}

# test factory create rule table without a condition.
{
  my $ruleTable = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
      [ bet 100 ]
  ');

  ok( 
    $ruleTable->rules->[0]->is_satisfied('any thing'),
    'rule without condition',
  );

}

# test create decisions
{
  my $strategy = VPoker::Holdem::Strategy::RuleBased::Limit->new;
  my $ruleTable = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
    @call first
    Betting: nobet [
      bet
    ]
  ', $strategy);

  is(
    $ruleTable->rules->[0]->name,
    'call first',
    'correctly set the name of the rule',
  );

  is(
    $ruleTable->rules->[0]->conditions->[0]->value,
    'nobet',
    'correctly created the rule with the @syntax',
  );

}

{
  my $strategy = VPoker::Holdem::Strategy::RuleBased::Limit->new;
  my $ruleTable = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
    @flush draw
    Hand: flush draw [
        @call first
        Betting: nobet [
          bet
        ]

        @raise bet
        Betting: bet [
          bet
        ]
    ]

    @all else [
        bet
    ]
  ', $strategy);

  is(
    $ruleTable->rules->[0]->name,
    'flush draw',
    'correctly set the name of the named rule',
  );

  is(
    $ruleTable->rules->[0]->action->rules->[0]->name,
    'call first',
    'correctly created the nested named rule',
  );

  is(
    $ruleTable->rules->[0]->action->rules->[1]->name,
    'raise bet',
    'correctly created the nested named rule number 2',
  );

  is(
    $ruleTable->rules->[1]->name,
    'all else',
    'correctly created the second named rule',
  );

}

sub test_rule {
  my ($rule, %args) = @_;
  my $index = 0;
  foreach my $condition (@{$args{'conditions'}}) {
    is(
        ref($rule->conditions->[$index]),
        ref(VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(name => $condition->{'type'})),
        $args{'test'} . " - correct condition " . ($index + 1) . " type",
    );
    is(
      $rule->conditions->[$index]->value,
      $condition->{'value'},
      $args{'test'} . " - correct condition " . ($index + 1) . " value",
    );
    $index++;
  }

  if ($args{'action'}) {
    is(
      $rule->action->action,
      $args{'action'},
      $args{'test'} . " - correct action value",
    );
  }

}
sub create_action {
   return VPoker::Holdem::Strategy::RuleBased::ActionFactory->create(shift);
}
