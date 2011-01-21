use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

no warnings 'redefine';

use Test::More qw(no_plan);
use VPoker::Holdem::Strategy;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::BoardCards;
use VPoker::Holdem::HoleCards;
use VPoker::Holdem::Hand;

use VPoker::CardSet;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::Hand');
my $handCondition = VPoker::Holdem::Strategy::RuleBased::Condition::Hand->new(
    strategy => VPoker::Holdem::Strategy->new
);

foreach my $value (hand_rank_values()) {
    ok($handCondition->validate($value), "$value value accepted");
}

test_values('over pair',
    board         => ['Qd', '2c', 'Jc'],
    hole_cards    => ['Ad', 'Ac'],
    satisfied     => ['over pair'],
    not_satisfied => ['straight', 'flush', 'fullhouse'],
);

test_values('one pair',
    board         => ['Qd', '2c', 'Jc'],
    hole_cards    => ['Ad', 'Qc'],
    satisfied     => ['one pair', 'pair Q'],
);

test_values('pair on turn',
    board         => ['Kd', '2c', 'Jc', 'Qd'],
    hole_cards    => ['Ad', 'Qc'],
    satisfied     => ['pair on turn'],
);

test_values('not pair on turn',
    board         => ['Qd', '2c', 'Jc', 'Kd'],
    hole_cards    => ['Ad', 'Qc'],
    satisfied     => ['one pair'],
    not_satisfied => ['pair on turn'],
);

test_values('2 pairs',
    board         => ['Qd', '2c', 'Jc'],
    hole_cards    => ['Qc', '2d'],
    satisfied     => ['2 pairs'],
);

test_values('pair A',
    board         => ['Ad', '2c', '2d'],
    hole_cards    => ['Ac', 'Kd'],
    not_satisfied => ['pair'],
);

test_values('trip',
    board         => ['Qd', '2c', 'Jc'],
    hole_cards    => ['Qs', 'Qc'],
    satisfied     => ['trip'],
);

test_values('over pair',
    board         => ['Qc', 'Kc', 'Jc', '7d'],
    hole_cards    => ['As', 'Ac'],
    satisfied     => ['over pair'],
    not_satisfied => ['bottom straight'],
);

test_values('over pair',
    board         => ['Qc', 'Kc', 'Jc', 'Kd'],
    hole_cards    => ['As', 'Ac'],
    satisfied     => ['over pair'],
);

test_values('bottom straight - one card',
    board         => ['Qd', 'Kc', 'Jc', 'Td'],
    hole_cards    => ['9s', 'Qc'],
    satisfied     => ['bottom straight'],
);

test_values('bottom straight - 2 cards',
    board         => ['Qd', 'Kc', 'Jc', 'Qc'],
    hole_cards    => ['9s', 'Tc'],
    satisfied     => ['bottom straight'],
);

test_values('bottom straight - A high',
    board         => ['Qd', 'Kc', 'Jc', 'Qc'],
    hole_cards    => ['As', 'Tc'],
    not_satisfied => ['bottom straight'],
);

test_values('top pair',
    board         => ['3d', 'Kc', 'Jc', 'Qc'],
    hole_cards    => ['Ks', 'Tc'],
    satisfied     => ['top pair', 'top pair K'],
    not_satisfied => ['bottom straight'],
);

test_values('top pair, comparision',
    board         => ['3d', '4c', 'Jc', 'Tc'],
    hole_cards    => ['Js', 'Ac'],
    satisfied     => ['top pair >= 9', 'top pair >= J'],
    not_satisfied => ['top pair > J', 'top pair >= Q' ],
);

test_values('back door flush draw - hole card suited',
    board         => ['3d', '4h', 'Jc'],
    hole_cards    => ['Kc', 'Ac'],
    satisfied     => ['back door flush draw'],
    not_satisfied => ['flush draw'],
);

test_values('back door flush draw - board 2 suited card',
    board         => ['3d', '4c', 'Jc'],
    hole_cards    => ['Ks', 'Ac'],
    satisfied     => ['back door flush draw'],
    not_satisfied => ['flush draw'],
);

test_values('high cards',
    board         => ['9d', 'Js', 'Qh'],
    hole_cards    => ['Ad', 'Kh'],
    satisfied     => ['not flush draw', 'no pair'],
);

test_values('nut flush draw, straight',
    board         => ['3d', 'Kc', 'Js', 'Qc'],
    hole_cards    => ['Ac', 'Tc'],
    satisfied     => ['nut flush draw', 'straight'],
);

test_values('negative nut flush draw',
    board         => ['3d', 'Ac', 'Js', 'Kc'],
    hole_cards    => ['9c', 'Tc'],
    satisfied     => ['flush draw'],
    not_satisfied => ['nut flush draw', 'flush draw K high'],
);

test_values('flush draw comparision',
    board         => ['3d', '4c', 'Js', 'Qc'],
    hole_cards    => ['9c', 'Tc'],
    satisfied     => ['flush draw', 'flush draw >= J', 'flush draw >= Q'],
    not_satisfied => ['nut flush draw', 'flush draw >= K'],
);

test_values('nut flush draw, A on board',
    board         => ['3d', 'Ac', 'Js', 'Qc'],
    hole_cards    => ['Kc', '4c'],
    satisfied => ['nut flush draw'],
);

test_values('nut flush',
    board         => ['3d', '4c', 'Jc', 'Qc'],
    hole_cards    => ['Ac', '7c'],
    satisfied     => ['nut flush'],
);

test_values('nut flush, A on board',
    board         => ['3d', 'Ac', 'Jc', 'Qc'],
    hole_cards    => ['Kc', '4c'],
    satisfied     => ['nut flush'],
    not_satisfied => ['flush K high'],
);

test_values('negagive nut flush',
    board         => ['3d', '9c', 'Jc', 'Qc'],
    hole_cards    => ['Kc', '4c'],
    not_satisfied => ['nut flush', 'flush A high'],
);

test_values('second best flush',
    board         => ['3d', 'Ac', '9c', 'Kc'],
    hole_cards    => ['Jc', '4c'],
    satisfied     => ['second best flush'],
    not_satisfied => ['nut flush'],
);

test_values('negagive second best flush',
    board         => ['3d', 'Ac', '9c', 'Kc'],
    hole_cards    => ['Tc', '4c'],
    not_satisfied => ['nut flush', 'second best flush'],
);

test_values('flush draw A on board',
    board         => ['3d', 'Ac', '9d', 'Kc'],
    hole_cards    => ['Tc', '4c'],
    satisfied     => ['flush draw', 'flush draw A high', 'flush draw A'],
    not_satisfied => ['nut flush', 'second best flush'],
);

test_values('straight, not bottom straight',
    board         => ['Td', 'Ac', 'Jd', 'Qc'],
    hole_cards    => ['Kc', '4c'],
    satisfied     => ['straight', 'not bottom straight'],
);

test_values('second pair, kicker T',
    board         => ['4d', 'Ac', 'Jd', 'Qc'],
    hole_cards    => ['Qd', 'Tc'],
    satisfied     => ['second pair', 'kicker T'],
);

test_values('kicker over board',
    board         => ['4d', '5c', '8d', '6c', 'Td'],
    hole_cards    => ['8h', 'Jc'],
    satisfied     => ['second pair', 'kicker >= J'],
);

test_values('second pair, kicker comparision',
    board         => ['9d', 'Kc', 'Jd', 'Qc'],
    hole_cards    => ['Qd', 'Ac'],
    satisfied     => ['second pair', 'kicker >= Q'],
);

test_values('2 pairs, kicker J',
    board         => ['9d', 'Kc', 'Jd', 'Qc'],
    hole_cards    => ['Qd', 'Kd'],
    satisfied     => ['2 pairs', 'kicker J', 'kicker >= J'],
);

test_values('second pair, not top pair',
    board         => ['Jc', '2c', 'Jd', 'Qc'],
    hole_cards    => ['Kd', '4c'],
    satisfied     => ['second pair', 'not top pair'],
);

test_values('not second pair',
    board         => ['Td', 'Ac', 'Jd', 'Qc'],
    hole_cards    => ['Jd', '4c'],
    satisfied     => ['not second pair'],
);

test_values('top set',
    board         => ['Jc', '2c', 'Jd', 'Tc'],
    hole_cards    => ['Js', '4c'],
    satisfied     => ['top set'],
);

test_values('nut straight straight to A',
    board         => ['Jc', 'Qc', 'Kd', 'Tc'],
    hole_cards    => ['As', '4c'],
    satisfied     => ['nut straight'],
);

test_values('nut straight, straight to A on board',
    board         => ['Ac', 'Qc', 'Kd', 'Tc'],
    hole_cards    => ['Js', '4c'],
    satisfied => ['nut straight'],
);

test_values('nut straight, we have 2 high card',
    board      => ['9c', 'Jc', '4d', 'Tc'],
    hole_cards => ['Qs', 'Kc'],
    satisfied  => ['nut straight'],
);

test_values('not nut straight, possible upper straight',
    board         => ['8c', 'Qc', 'Kd', 'Tc'],
    hole_cards    => ['Js', '9c'],
    not_satisfied => ['nut straight'],
);

test_values('not nut straight, possible upper straight',
    board         => ['9c', 'Jc', 'Kd', 'Tc'],
    hole_cards    => ['Qs', 'Kc'],
    not_satisfied => ['nut straight'],
);

test_values('not bottom straight if we has 25 and board 1234',
    board         => ['2c', 'Ac', '3d', 'Tc', '4d'],
    hole_cards    => ['2s', '5c'],
    satisfied     => ['not bottom straight'],
);

test_values('2 over cards',
    board         => ['2c', 'Qc', '3d', 'Tc', '4d'],
    hole_cards    => ['Ks', 'Ac'],
    satisfied     => ['2 over cards'],
);

test_values('1 over cards',
    board         => ['2c', 'Qc', '3d', 'Tc', '4d'],
    hole_cards    => ['Js', 'Ac'],
    satisfied     => ['over cards', '1 over cards'],
    not_satisfied => ['2 over cards']
);

test_values('open ended straight draw',
    board         => ['Tc', 'Qd', '4h'],
    hole_cards    => ['Js', 'Kc'],
    satisfied     => ['open ended straight draw', 'two way straight draw'],
);

test_values('busted belly straight draw',
    board         => ['Kc', 'Jd', '9h'],
    hole_cards    => ['Ts', '7c'],
    satisfied     => ['busted belly straight draw', 'two way straight draw'],
);

test_values('flush >= Q',
    board         => ['Qc', 'Jc', '9c'],
    hole_cards    => ['Kc', '7c'],
    satisfied     => ['flush >= Q', 'flush >= K'],
    not_satisfied => ['flush >= A', 'flush > K' ],
);
## ----------------------------------------------------------------------------
sub hand_rank_values {
    return (
        'straight draw',
        'bottom 2 pairs',
        'top 2 pairs',
        'over pair',
        'top pair',
        'top kicker',
        'kicker A',
        'kicker > K',
        'kicker < T',
        'bottom straight',
        'nut flush draw',
    );
}


## ----------------------------------------------------------------------------
sub test_values {
    my ($test, %args) = @_;
    my ($board, $holeCards, $satisfied, $not_satisfied) =
        ($args{'board'}, $args{'hole_cards'}, $args{'satisfied'}, $args{'not_satisfied'});
    $board     = VPoker::Holdem::BoardCards->new($board);
    $holeCards = VPoker::Holdem::HoleCards->new($holeCards);
    my $hand   = VPoker::Holdem::Hand->new();
    $hand->board($board);

    {
        *VPoker::Holdem::Strategy::hand = sub {
            return $hand;
        };
        *VPoker::Holdem::Strategy::hole_cards = sub {
            return $holeCards;
        };

        foreach my $value (@$satisfied) {
            ok($handCondition->validate($value), "$test - $value is valid");
            ok($handCondition->is_satisfied($value), "$test - $value is satisfied");
        }

        foreach my $value (@$not_satisfied) {
            ok($handCondition->validate($value), "$test - $value is valid");
            ok(!$handCondition->is_satisfied($value), "$test - $value is not satified");
        }
    }
}


