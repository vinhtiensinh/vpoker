use strict;
use warnings;

use Test::More qw(no_plan);

use FindBin;
use lib "$FindBin::Bin/../lib";
use_ok('VPoker::Holdem::Strategy::RuleBased::DSL::Yaml');
use VPoker::Holdem::Strategy::RuleBased::Limit;
use Data::Dumper;

my $syntax_yaml = 'VPoker::Holdem::Strategy::RuleBased::DSL::Yaml' ;
my $strategy = VPoker::Holdem::Strategy::RuleBased::Limit->new();

diag("\n########## Test simple list format --------------------------------------");
my $rule_table = $syntax_yaml->create($strategy, '
    - Bet Round. preflop: bet
    - Bet Round. flop | Hand. flush draw: bet
    - Bet Round. turn | Hand. flush draw; straight draw: call
    - Bet Round. river: check, fold
');

test_simple_rule( $rule_table, 0, {'bet round' => 'preflop'} , 'bet');
test_simple_rule( $rule_table, 1, {
        'bet round' => 'flop',
        'hand' => 'flush draw'},
    'bet');

test_simple_rule( $rule_table, 2, {
        'bet round' => 'turn',
        'hand' => ['flush draw', 'straight draw']} ,
    'call');

test_simple_rule( $rule_table, 3, {'bet round' => 'river' } , 'check, fold');
 
diag("\n########## Test list hash format ---------------------------------------");
$rule_table = $syntax_yaml->create($strategy, '
rules:
  - play straight flush
  - play two pairs
  - play top pair
with:
  play straight flush:
    - Hand. straight flush: bet
  play two pairs: 
    - Hand. two pairs: call
  play top pair: 
    - Hand. top pair: fold
');

test_simple_rule( $rule_table->rules->[0], 0, {'hand' => 'straight flush' } , 'bet');
test_simple_rule( $rule_table->rules->[1], 0, {'hand' => 'two pairs' } , 'call');
test_simple_rule( $rule_table->rules->[2], 0, {'hand' => 'top pair' } , 'fold');

diag("\n########## Test complext list format ---------------------------------------");
$rule_table = $syntax_yaml->create($strategy, '
- Hole Cards. AA: &AA
    - Board. pair: check, fold
    - Board. trip: bet

- Hole Cards. KK:
      use: *AA
      with:
        Board. trip: raise
');

diag("     #### test rule table rules");
test_simple_rule( $rule_table, 0, {'hole cards' => 'AA' });
test_simple_rule( $rule_table, 1, {'hole cards' => 'KK' });

diag("     #### test rule table board trip rule");
test_simple_rule( $rule_table->rules->[1]->action, 0, {'board' => 'pair' }, 'check, fold');
test_simple_rule( $rule_table->rules->[1]->action, 1, {'board' => 'trip' }, 'raise');

diag("\n########## Test reference to global and local value ------");
$rule_table = $syntax_yaml->create($strategy, '
rules:
  - hole cards. AA:
        - specific->pair
        - check raise
with:
    top bet:
      - hand. top pair: bet
');

my $rule_table_specific = $syntax_yaml->create($strategy,'
- pair:
    - hand. pair: raise
');

my $rule_table_global = $syntax_yaml->create($strategy, '
- check raise:
    - betting. nobet: check
    - betting. bet: raise
');

$strategy->decision('preflop', $rule_table);
$strategy->decision('specific', $rule_table_specific);
$strategy->decision('_global', $rule_table_global);

test_simple_rule($rule_table, 0, {'hole cards' => 'AA' });
my $checked_table = $rule_table->rules->[0]->action;

my $specific_pair = $checked_table->rules->[0];
test_simple_rule($specific_pair, 0, {'hand' => 'pair'}, 'raise');

my $check_raise = $checked_table->rules->[1];
test_simple_rule($check_raise, 0, {'betting' => 'nobet'}, 'check');
test_simple_rule($check_raise, 1, {'betting' => 'bet'}, 'raise');

sub test_simple_rule {

    my ($rule_table, $index, $expected_conditions, $expected_action) = @_;
    diag("rule $index");

    my $rule = $rule_table->rules->[$index];

    my $condition_index = 0;
    foreach my $expectation (keys %$expected_conditions) {
        my $expected_condition = $expectation;
        my $expected_condition_value = $expected_conditions->{$expectation};

        is(
            $rule->conditions->[$condition_index]->name,
            $expected_condition,
            "  condition $condition_index is correct ($expected_condition)"
        );

        if (ref($expected_condition_value) eq 'ARRAY') {
            is_deeply(
                $rule->conditions->[$condition_index]->value,
                $expected_condition_value,
                "  condition $condition_index value is correct (".Dumper($expected_condition_value).")"
            );
        }
        else {
            is(
                $rule->conditions->[$condition_index]->value,
                $expected_condition_value,
                "  condition $condition_index value is correct ($expected_condition_value)"
            );
        }

        $condition_index++;
    }

    if($expected_action) {
        is( 
            $rule->action->action,
            $expected_action,
            "  has correct action($expected_action)"
        );
    }
}

