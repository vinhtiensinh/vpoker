use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
no warnings 'once';

use Test::More tests => 4;
use Test::MockModule;
use VPoker::Test::Strategy;

use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::RuleBased::Limit;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;

use_ok('VPoker::Holdem::Strategy::RuleBased::RuleTable');

# this should execute a rule match in the master rules
my $masterTable = [
    ['bet round', 'hole cards', 'position', 'action' , 'name'               ],
#####################################################################################
    ['preflop',    'pair'      , 'early',   'bet', 'early position pair'],
    ['flop' ,    ['AK', 'AQ'],   'early',  'bet', 'early big card'     ],
];

test_rulebased_strategy(
    'test name' => 'test rule based master rule applied',
    'given' => {
      'bet_round'      => 'flop',
      'hole_cards'     => ['Ah', 'Kc'],
      'players_behind' => 4,
      'hand_bet'       => 10,
      'big_blind'      => 10,
    },
    'rules'      => {
      'master'     => $masterTable,
    },

    # when we apply rule based strategy

    'then' => {
      'action' => 'bet',
      'amount' => '10',
    },
);

push @$masterTable, ['turn','','','turn', 'apply turn table please'];
my $turnTable = [
    ['hole cards','action' , 'name'    ],
#####################################################################################
    ['pair'      ,'bet 100', 'pair'    ],
    [['AK', 'AQ'],'bet 400', 'big card'],
    ['AJ'        ,'bet 300', 'big card'],
];

test_rulebased_strategy(
    'test name' => 'test rule based action apply works',
    'given' => {
      'bet_round'      => 'turn',
      'hole_cards'     => ['Ah', 'Qc'],
      'hand_bet'       => 80,
      'big_blind'      => 10,
    },
    'rules'      => {
      'master'     => $masterTable,
      'turn'       => $turnTable,
    },

    # when we apply rule based strategy

    'then' => {
      'action' => 'call',
    },
);

sub test_rulebased_strategy {
    my (%args) = @_;

    my $given = $args{'given'};
    my $then  = $args{'then'};
    my $rules = $args{'rules'};
    my $testName = $args{'test name'};

    my $setup = VPoker::Test::Strategy::setup_strategy_condition(%$given);

    my $strategy  = VPoker::Holdem::Strategy::RuleBased::Limit->new;

    while(my ($name, $table) = each (%$rules)) {
        my $ruleTable = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
            'strategy'  => $strategy,
            'ruleTable' => $table,
        );
        $strategy->decision($name, $ruleTable);
    };

    $strategy->play;

    is(
        $strategy->_test_action_,
        $then->{'action'},
        $testName . ': correct action',
    );
 
    if ($then->{'amount'}) {
        is(
            $strategy->_test_amount_,
            $then->{'amount'},
            $testName . ': correct amount',
        );
    }
}
