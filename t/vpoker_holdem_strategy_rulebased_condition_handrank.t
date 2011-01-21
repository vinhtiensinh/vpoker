use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

no warnings 'redefine';
no warnings 'once';

use Test::More tests => 338;
use VPoker::Holdem::Strategy;
use VPoker::Holdem::BetRound;
use VPoker::CardSet;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::HandRank');

my $handRankCondition = VPoker::Holdem::Strategy::RuleBased::Condition::HandRank->new(
    strategy => VPoker::Holdem::Strategy->new,
);

foreach my $value (hand_rank_values()) {
    ok($handRankCondition->validate($value), "$value value accepted");
}

test_all_values(
    cards     => ['Ac', 'Kc', 'Qc', 'Jc', 'Tc'],
    satisfied => ['straight flush', 'straight', 'flush', 'suited', 'connected'],
);

test_all_values(
    cards     => ['Ac', 'Kc', 'Qd', 'Jc', 'Tc'],
    satisfied => ['straight A high', 'connected', 'flush draw', 'straight'],
);

test_all_values(
    cards     => ['Ac', '2h', '3c', '4s', '5c'],
    satisfied => ['straight', 'connected', 'not straight A high'],
);

test_all_values(
    cards     => ['Ad', 'Ac', 'Ah', 'As', 'Kd'],
    satisfied => ['quad', 'four of a kind'],
);

test_all_values(
    cards     => ['Ad', 'Ac', '2d', '2s', '2h', 'Qh'],
    satisfied => ['fullhouse'],
);

test_all_values(
    cards     => ['Ad', 'Qc', '2c', '3c', 'Tc', 'Jc'],
    satisfied => ['flush'],
);

test_all_values(
    cards     => ['Td', '2c', '3d', 'Qs', 'Qc', 'Qh'],
    satisfied => ['trip', 'set'],
);

test_all_values(
    cards     => ['Ad', '2c', '3d', 'Qs', '5h', '4s'],
    satisfied => ['straight'],
);

test_all_values(
    cards     => ['Ad', 'Ac', '3d', '4s', 'Qc', 'Qh'],
    satisfied => ['two pairs', '2 pairs'],
);

test_all_values(
    cards     => ['Ad', 'Ac', '3d', '4s', 'Tc', 'Qh'],
    satisfied => ['a pair', '1 pair', 'one pair', 'pair'],
);

test_all_values(
    cards     => ['Ac', 'Kc', 'Td', '9d', '2c'],
    satisfied => ['high cards', 'nothing'],
);

test_all_values(
    cards     => ['Kc', 'Kd', 'Td', '9d', '2c'],
    satisfied => ['pair', 'a pair', 'one pair', '1 pair', 'pair > Q', 'pair = K', 'pair < A'],
);

test_all_values(
    cards     => ['9c', '9d', 'Td', 'Tc', '2c'],
    satisfied => ['two pairs', '2 pairs', '2 pairs > 8', 'two pairs < J'],
);

test_all_values(
    cards     => ['9c', '8c', '6c', '3c', '2d'],
    satisfied => ['flush draw', 'high cards', 'nothing'],
);

sub test_all_values {
    my (%args) = @_;
    my ($cards, $satisfied) = ($args{'cards'}, $args{'satisfied'});
    my $cardSet = VPoker::CardSet->new(@$cards);
    my $cardSetFace = $cardSet->face;
    ## ----------------------------------------------------------------------------
    {
        *VPoker::Holdem::Strategy::RuleBased::Condition::HandRank::condition_value = sub {
            return $cardSet;
        };

        foreach my $value (@$satisfied) {
            ok($handRankCondition->is_satisfied($value), "$cardSetFace is $value");
        }
    
        foreach my $value(hand_rank_values()) {
            if(is_not_any_of($value, @$satisfied)) {
                ok(!$handRankCondition->is_satisfied($value), "$cardSetFace is not $value");
            }
        }

    }
}

sub hand_rank_values {
    return (
        'straight flush',
        'quad', 'four of a kind',
        'fullhouse',
        'flush',
        'straight',
        'trip', 'set',
        'two pairs', '2 pairs',
        'pair', 'a pair', 'one pair', '1 pair',
        'gut shot straight draw',
        'open ended straight draw',
        'busted belly straight draw',
        'suited',
        'connected',
        'high cards', 'nothing',
        'flush draw',
    );
}

sub is_not_any_of {
    my ($value, @checkValues) = @_;
    foreach my $checkValue (@checkValues) {
        return 0 if $value eq $checkValue;
    }
    return 1;
}
