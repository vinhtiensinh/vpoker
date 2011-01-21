use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
no warnings 'once';

use Test::More tests => 12;
use Test::MockModule;
use VPoker::Holdem::Strategy::Limit;
use VPoker::Test::Strategy;

test_limit_bet(@$_) for (
  # bet round, big blind, current bet, expected action, expected bet amount, test name] 
  ['preflop',  10,        0,           'bet',           '10',                'preflop bet' ], 
  ['flop',     10,        10,          'bet',           '10',                'flop bet'    ], 
  ['turn',     10,        40,          'bet',           '20',                'turn bet'    ], 
  ['river',    10,        60,          'bet',           '20',                'river bet'   ],
  ['preflop',  10,        40,          'call',          '',                  'preflop cap' ],
  ['flop',     10,        40,          'call',          '',                  'flop cap'    ],
  ['turn',     10,        80,          'call',          '',                  'turn cap'    ],
  ['river',    10,        80,          'call',          '',                  'river cap'   ],
);

sub test_limit_bet {
    my ($betround, $bigblind, $handbet, $expectedAction, $expectedBetAmount, $testName) = @_;

    my $strategy = VPoker::Holdem::Strategy::Limit->new;
    my $setup = VPoker::Test::Strategy::setup_strategy_condition(
        'bet_round' => $betround,
        'big_blind' => $bigblind,
        'hand_bet'  => $handbet,
    );
   
    $strategy->bet;
   
    is(
        $strategy->_test_action_,
        $expectedAction,
        $testName . ': correct action is ' . $expectedAction
    );

    if ($expectedBetAmount) { 
        is(
            $strategy->_test_amount_,
            $expectedBetAmount,
            $testName . ': correct bet amount'
        );
    }
}
