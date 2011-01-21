use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
no warnings 'once';

use Test::More tests => 5;
use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;

use_ok('VPoker::Holdem::Strategy::RuleBased::RuleTable');

my $strategyAction = {};
my $check_or_fold  = 0;

*VPoker::Holdem::Strategy::table = sub {return VPoker::Table->new};
*VPoker::ChipEvaluator::evaluate = sub {shift; return shift;};

*VPoker::Holdem::Strategy::bet = sub {
    my ($class, $amount) = @_;
    $strategyAction = {
        action => 'bet',
        amount => $amount,
    }
};
*VPoker::Holdem::Strategy::check_or_fold = sub { $check_or_fold = 1 };

my $table = [
    ['bet round', 'hole cards', 'position', 'action' , 'name'               ],
#####################################################################################
    ['preflop',    'pair'      , 'early',   'bet 100', 'early position pair'],
    ['flop' ,    ['AK', 'AQ'],   'middle',  'bet 200', 'early big card'     ],
];

my $ruleTable = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
    ruleTable  => $table,
    strategy   => VPoker::Holdem::Strategy::RuleBased->new,
);

my $firstRuleConditions = $ruleTable->rules->[0]->conditions;
isa_ok(
    $firstRuleConditions->[0],
    'VPoker::Holdem::Strategy::RuleBased::Condition::BetRound',
    'correct first rule first condition',
);
is(
    $firstRuleConditions->[0]->value,
    'preflop',
    'correct first rule first condition value',
);

{
    _test_rule_table(
        'ruleTable'       => $ruleTable,
        'bet round'       => 'preflop',
        'hole cards'      => ['Kd', 'Kc'],
        'players behind'  => 5,
        'check or fold'   => 0,
        'expected action' => 'bet',
        'expected amount' => 100,
    );
}

sub _test_rule_table {
    my (%args) = @_;
    $strategyAction = {};
    $check_or_fold  = 0;
    _strategy_bet_round($args{'bet round'}) if $args{'bet round'};
    _strategy_hole_cards(@{ $args{'hole cards'} }) if $args{'hole cards'};
    _strategy_players_behind($args{'players behind'}) if $args{'players behind'};
    $args{'ruleTable'}->apply;
    ok($check_or_fold == $args{'check or fold'}, 'expected check or fold = ' . $args{'check or fold'});
    if(exists $args{'expected action'}) {
        is_deeply(
            $strategyAction,
            {
                action => $args{'expected action'},
                amount => $args{'expected amount'},
            },
            'rule table apply correct',
        );
    }
}

## ----------------------------------------------------------------------------
sub _strategy_bet_round {
   my ($betRound) = @_;
   *VPoker::Holdem::Strategy::bet_round = sub {
       my $method = "new_$betRound";
       return VPoker::Holdem::BetRound->$method;
   };
}

sub _strategy_hole_cards {
    my (@cards) = @_;
    *VPoker::Holdem::Strategy::hole_cards = sub {
        return VPoker::Holdem::HoleCards->new(@cards);
    };
}

sub _strategy_players_behind {
    my ($players) = @_;
    *VPoker::Holdem::Strategy::players_behind = sub {
        return $players;
    };
}
