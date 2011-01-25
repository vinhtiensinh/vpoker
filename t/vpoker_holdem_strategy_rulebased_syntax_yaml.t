use strict;
use warnings;

use Test::More qw(no_plan);

use FindBin;
use lib "$FindBin::Bin/../lib";
use_ok('VPoker::Holdem::Strategy::RuleBased::DSL::Yaml');
use VPoker::Holdem::Strategy::Limit;
use Data::Dumper;

my $syntax_yaml = 'VPoker::Holdem::Strategy::RuleBased::DSL::Yaml' ;
my $strategy = VPoker::Holdem::Strategy::Limit->new();

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
 
diag("\n########## Test simple list format ---------------------------------------");
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

test_simple_rule( $rule_table, 0, {'hand' => 'straight flush' } , 'bet');
test_simple_rule( $rule_table, 1, {'hand' => 'two pairs' } , 'call');
test_simple_rule( $rule_table, 2, {'hand' => 'top pair' } , 'fold');

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

    is( 
        $rule->action->action,
        $expected_action,
        "  has correct action($expected_action)"
    );
}

