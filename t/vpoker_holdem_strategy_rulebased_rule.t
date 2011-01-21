use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
no warnings 'once';

use Test::More tests => 8;
use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;
use VPoker::Holdem::Hand;

use_ok('VPoker::Holdem::Strategy::RuleBased::Rule');

*VPoker::Holdem::Hand::table = sub {return VPoker::Table->new};
*VPoker::Table::current_hand = sub {return VPoker::Holdem::Hand->new};

my %strategyAction = ();

{
    _strategy_bet_round('preflop');
    _strategy_hole_cards('Kd', 'Kc');
    _strategy_player_behind(5);
    test_satisfied(
        testName => 'preflop pair',
        rule     => {
            conditions => {
                'bet round'  => 'preflop',
                'hole cards' => 'pair',
                'position'   => 'early',
            },
        },
        satisfied => 1,
    );

    test_satisfied(
        testName => 'preflop pair',
        
        rule     => {
            conditions => {
                'bet round'  => 'preflop',
                'hole cards' => 'pair',
                'position'   => 'middle',
            },
        },
        
        satisfied => 0,
    );

    test_satisfied(
        testName => 'flop pair early',
        rule     => {
            conditions => {
                'bet round'  => 'flop',
                'hole cards' => 'pair',
                'position'   => 'early',
            },
        },
        satisfied => 0,
    );

    test_satisfied(
        testName => 'flop AK early',
        rule     => {
            conditions => {
                'bet round'  => 'preflop',
                'hole cards' => 'AK',
                'position'   => 'early',
            },
        },
        satisfied => 0,
    );

}

## test apply action
{
    *VPoker::Holdem::Strategy::bet = sub {
        my ($class, $amount) = @_;
        return {
            action => 'bet',
            amount => $amount,
        }
    };
    
    my $rule = _make_rule(
        action => 'bet 100',
    );
    isa_ok($rule->strategy, 'VPoker::Holdem::Strategy::RuleBased', 'correct strategy');

    is_deeply(
        $rule->action->apply,
        {
            action => 'bet',
            amount => 100,
        },
        'apply bet correctly',
    );
    

    *VPoker::Holdem::Hand::big_blind     = sub { return 5 };
    $rule = _make_rule(
        action => 'bet 5bb',
    );
    is_deeply(
        $rule->action->apply,
        {
            action => 'bet',
            amount => 25,
        },
        'bet 5bb correctly',
    );
    

}


sub test_satisfied {
    *VPoker::Holdem::Strategy::table = sub {return VPoker::Table->new};
    my (%args) = @_;
    my ($ruleArgs, $testName) = ($args{'rule'}, $args{'testName'});

    my $rule = _make_rule(%$ruleArgs);

    if($args{'satisfied'}) {
        ok($rule->is_satisfied, "$testName is satisfied");
    }
    else {
        ok(!$rule->is_satisfied, "$testName is not satisfied");
    }

}

sub _make_rule {
   my (%ruleArgs) = @_;
   return VPoker::Holdem::Strategy::RuleBased::Rule->new(
        %ruleArgs,
        strategy    => VPoker::Holdem::Strategy::RuleBased->new,
    );
}

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

sub _strategy_player_behind {
    my ($players) = @_;
    *VPoker::Holdem::Strategy::players_behind = sub {
        return $players;
    };
}
