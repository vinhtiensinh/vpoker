use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
no warnings 'once';

use Test::More tests => 10;
use Test::MockModule;
use VPoker::Test::Strategy;

use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;
use Scalar::Util qw(blessed);

use_ok('VPoker::Holdem::Strategy::RuleBased::RuleTable');

# this should execute a rule match in the master rules
my $masterTable = [
    ['bet round', 'hole cards', 'position', 'action' ],
#####################################################################################
    ['preflop',    'pair'      , 'early',   'bet 100'],
    ['flop' ,    ['AK', 'AQ'],   'early',  'bet 200' ],
];

test_rulebased_strategy(
    'test name' => 'test rule based master rule applied',
    'given' => {
      'bet_round'      => 'flop',
      'hole_cards'     => ['Ah', 'Kc'],
      'players_behind' => 4,
    },
    'rules'      => {
      'master'     => $masterTable,
    },

    # when we apply rule based strategy

    'then' => {
      'action' => 'bet',
      'amount' => '200',
    },
);

push @$masterTable, ['turn','','','turn', 'apply turn table please'];
my $turnTable = [
    ['hole cards','action' ],
#####################################################################################
    ['pair'      ,'bet 100'],
    [['AK', 'AQ'],'bet 400'],
    ['AJ'        ,'bet 300'],
];


test_rulebased_strategy(
    'test name' => 'test rule based action apply works',
    'given' => {
      'bet_round'      => 'turn',
      'hole_cards'     => ['Ah', 'Qc'],
    },
    'rules'      => {
      'master'     => $masterTable,
      'turn'       => $turnTable,
    },

    # when we apply rule based strategy

    'then' => {
      'action' => 'bet',
      'amount' => '400',
    },
);

my $strategy = VPoker::Holdem::Strategy::RuleBased->new();
my $masterStrategy = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create('
    @flush draw
    Hand: flush draw [ bet ]
    Hole Cards: AQ [ ~local ]
    @all else [
        Betting: nobet [ bet  ]
        @call bet
        Betting: bet   [ call ]
    ]
    @local [ call ]
    ',
    $strategy,
    'master',
);

$strategy->decision('master', $masterStrategy);
my $masterFlushDraw = $strategy->decision('master.flush draw');
ok ($masterFlushDraw, 'find the flush draw strategy from master strategy');
is(
    $masterFlushDraw->action->action,
    'bet',
    'correct action of the sub strategy',
);

my $callBet = $strategy->decision('master.call bet');
ok ($callBet, 'find the call bet strategy from master strategy');
is(
    $callBet->action->action,
    'call',
    'correct action of the call bet strategy',
);

test_rulebased_strategy(
    'test name' => 'test calling local strategy',
    'strategy'  => $strategy,
    'given'     => {
      'hole_cards'     => ['Ah', 'Qc'],
    },
    'rules'      => {
      'master'     => $masterStrategy,
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
    my $strategy = $args{'strategy'} || VPoker::Holdem::Strategy::RuleBased->new;

    my $setup = VPoker::Test::Strategy::setup_strategy_condition(%$given);


    while(my ($name, $table) = each (%$rules)) {
        $table = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
            'strategy'  => $strategy,
            'ruleTable' => $table,
        ) unless blessed($table) && $table->isa('VPoker::Holdem::Strategy::RuleBased::RuleTable');
        $strategy->decision($name, $table);
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
