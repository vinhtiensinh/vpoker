use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

no warnings 'redefine';

use Test::More tests => 11;
use VPoker::Holdem::Strategy;
use VPoker::Holdem::BetRound;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::BetRound');

my $betRoundCondition = VPoker::Holdem::Strategy::RuleBased::Condition::BetRound->new(
    strategy => VPoker::Holdem::Strategy->new,
);

foreach my $value ( ('preflop', 'flop', 'turn', 'river', 'not preflop', 'not preflop', 'no river') ) {
    ok($betRoundCondition->validate($value), "$value value accepted");
}

## ----------------------------------------------------------------------------
{
    *VPoker::Holdem::Strategy::bet_round = sub { return VPoker::Holdem::BetRound->new_preflop; };
    ok(
        $betRoundCondition->is_satisfied('preflop'),
        'correct condition',
    );
    ok(
        $betRoundCondition->is_satisfied('not flop'),
        'correct condition preflop is not flop',
    );
    ok(
        $betRoundCondition->is_satisfied('no turn'),
        'correct condition preflop is no turn',
    );
}
