use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More qw(no_plan);
use VPoker::Test::Table;
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Test::ConditionTester;

test_boardcards_condition(
    test         => 'board cards - flop rainbow',
    actions      => [(
        'deal Td 8s 8c',
    )],
    value        => 'rainbow',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - flop not rainbow',
    actions      => [(
        'deal Td 7d 8c',
    )],
    value        => 'not rainbow',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - turn rainbow',
    actions      => [(
        'deal Td 7s 8c',
        'deal Qh',
    )],
    value        => 'rainbow',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - turn not rainbow',
    actions      => [(
        'deal Td 7s 8c',
        'deal 2c',
    )],
    value        => 'rainbow',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - possible straight 3 cards connected',
    actions      => [(
        'deal Td 8d 8c',
        'deal 9d',
    )],
    value        => 'possible straight',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - possible straight 2 gaps',
    actions      => [(
        'deal Td 8d 6c',
        'deal Jd',
    )],
    value        => 'possible straight',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - possible straight 1 gap',
    actions      => [(
        'deal 9d 8d 5c',
        'deal 4d',
    )],
    value        => 'possible straight',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - possible straight with an A',
    actions      => [(
        'deal 3d 9d 5c',
        'deal Ad',
    )],
    value        => 'possible straight',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - no possible straight',
    actions      => [(
        'deal 8d 9d 3c',
        'deal 4s',
        'deal 4h',
    )],
    value        => 'possible straight',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - possible flush',
    actions      => [(
        'deal Td 8d 8c',
        'deal 9d',
    )],
    value        => 'possible flush',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - 3 cards suited',
    actions      => [(
        'deal Td 8d 8c',
        'deal 9d',
    )],
    value        => '3 cards suited',
    expected     => 1,
);

test_boardcards_condition(
    test         => '4 cards suited',
    actions      => [(
        'deal Td 8d 7d',
        'deal 9d',
    )],
    value        => '4 cards suited',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - not possible flush',
    actions      => [(
        'deal Td 8d 8c',
        'deal 9c',
    )],
    value        => 'possible flush',
    expected     => 0,
);

test_boardcards_condition(
    test         => 'board cards - two pairs',
    actions      => [(
        'autoplayer cards Ac Kd',
        'deal Td 8d 8c',
        'deal Tc',
    )],
    value        => 'two pairs',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - pair > 7',
    actions      => [(
        'autoplayer cards Ac Kd',
        'deal Td 8d 8c',
        'deal Kc',
    )],
    value        => 'pair > 7',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - pair > 9',
    actions      => [(
        'autoplayer cards Ac Kd',
        'deal Td 8d 8c',
        'deal Kc',
    )],
    value        => 'pair > 9',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - no over card',
    actions      => [(
        'autoplayer cards Ac Kd',
        'deal Td 8d Qc',
    )],
    value        => 'no over card',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - over card',
    actions      => [(
        'autoplayer cards Tc Qd',
        'deal Kd 8d Qc',
    )],
    value        => 'no over card',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - 1 over card',
    actions      => [(
        'autoplayer cards Tc Qd',
        'deal Kd 8d Qc',
    )],
    value        => '1 over card',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board cards - 1 over card',
    actions      => [(
        'autoplayer cards Tc Qd',
        'deal Kd Ad Qc',
    )],
    value        => '1 over card',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - 1 card flush',
    actions      => [(
        'deal Kd 8d Qd',
        'deal 7c',
        'deal 7d',
    )],
    value        => '1 card flush',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'board cards - not 1 card flush',
    actions      => [(
        'deal Kd 8d Qd',
        'deal 7c',
        'deal 7h',
    )],
    value        => '1 card flush',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board cards - 1 card straight gut shot',
    actions      => [(
        'deal Kd Jh Qd',
        'deal 9c',
        'deal 6h',
    )],
    value        => 'one card straight',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'board cards - 1 card straight <= 7',
    actions      => [(
        'deal 6d 3h 4d',
        'deal 5c',
    )],
    value        => 'one card straight <= 7',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'board cards - 1 card straight >= T',
    actions      => [(
        'deal 6d 3h 4d',
        'deal 5c',
    )],
    value        => 'one card straight >= T',
    expected     => '0',
);

test_boardcards_condition(
    test         => 'board cards - 1 card straight 2 ways',
    actions      => [(
        'deal 7d 8h 9d',
        'deal Jc',
        'deal 4h',
    )],
    value        => 'one card straight',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'board cards - 1 card straight 4 cards connected',
    actions      => [(
        'deal Kd Jh Qd',
        'deal Tc',
        'deal 6h',
    )],
    value        => 'one card straight',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'turn - not possible straight',
    actions      => [(
        'deal Kd 2h Qd',
        'deal 3c',
        'deal Td',
    )],
    condition    => 'turn',
    value        => 'possible straight',
    expected     => '',
);

test_boardcards_condition(
    test         => 'flop - not possible straight',
    actions      => [(
        'deal Kd 2h Qd',
        'deal Tc',
        'deal Td',
    )],
    condition    => 'flop',
    value        => 'possible straight',
    expected     => '',
);

test_boardcards_condition(
    test         => 'flop - possible straight',
    actions      => [(
        'deal Kd Th Qd',
        'deal Tc',
        'deal Td',
    )],
    condition    => 'flop',
    value        => 'possible straight',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'flop - possible flush draw',
    actions      => [(
        'deal Kd Tc Qd',
    )],
    condition    => 'flop',
    value        => 'possible flush draw',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'flop - possible straight draw connected',
    actions      => [(
        'deal Kd Qc 3d',
    )],
    condition    => 'flop',
    value        => 'possible straight draw',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'flop - possible straight draw gap 1',
    actions      => [(
        'deal Kd Tc 3d',
    )],
    condition    => 'flop',
    value        => 'possible straight draw',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'flop - possible straight draw gap 2',
    actions      => [(
        'deal Kd Tc 3d',
    )],
    condition    => 'flop',
    value        => 'possible straight draw',
    expected     => '1',
);

test_boardcards_condition(
    test         => 'flop - no possible straight draw',
    actions      => [(
        'deal Kd 8c 2d',
    )],
    condition    => 'flop',
    value        => 'possible straight draw',
    expected     => '',
);

test_boardcards_condition(
    test         => 'flop - different cards >= 9',
    actions      => [(
        'deal Kd Tc Jd',
    )],
    condition    => 'flop',
    value        => 'different cards >= 9 ',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'flop - not different cards >= 9',
    actions      => [(
        'deal Kd Tc Td',
    )],
    condition    => 'flop',
    value        => 'different cards >= 9 ',
    expected     => '',
);

test_boardcards_condition(
    test         => 'flop - not different cards >= 9 - board has 8',
    actions      => [(
        'deal Kd Tc 8d',
    )],
    condition    => 'flop',
    value        => 'different cards >= 9 ',
    expected     => '',
);

test_boardcards_condition(
    test         => 'flop - number of card >= 9',
    actions      => [(
        'deal Kd Tc 8d',
    )],
    condition    => 'flop',
    value        => '2 cards >= 9 ',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'flop - not number of card >= 9',
    actions      => [(
        'deal Kd Tc 8d',
    )],
    condition    => 'flop',
    value        => '3 cards >= 9 ',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board - more than 2 cards <= Q',
    actions      => [(
        'deal Kd Tc 8d',
        'deal 7d',
    )],
    condition    => 'board',
    value        => 'more than 2 cards <= Q',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'river - straight K high',
    actions      => [(
        'deal Kd Tc Jd',
        'deal Qh',
        'deal 9s',
    )],
    condition    => 'board',
    value        => 'straight K high',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board - A',
    actions      => [(
        'deal Ad Tc Jd',
    )],
    condition    => 'board',
    value        => 'A',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board - not A',
    actions      => [(
        'deal Kd Tc Jd',
    )],
    condition    => 'board',
    value        => 'A',
    expected     => '',
);

test_boardcards_condition(
    test         => 'board - 3 cards connected',
    actions      => [(
        'deal Kd Tc Jd',
		'deal 9d'
    )],
    condition    => 'board',
    value        => '3 cards connected',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board - no 3 cards connected',
    actions      => [(
        'deal Kd Ac Jd',
		'deal 9d'
    )],
    condition    => 'board',
    value        => 'no 3 cards connected',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board - >= 3 over card',
    actions      => [(
        'autoplayer cards Tc 3d',
        'deal Kd Ac Jd',
     	'deal 9d'
    )],
    condition    => 'board',
    value        => '>= 3 over card',
    expected     => 1,
);

test_boardcards_condition(
    test         => 'board - not >= 3 over card',
    actions      => [(
        'autoplayer cards Tc 3d',
        'deal Kd 3c Jd',
     	'deal 9d'
    )],
    condition    => 'board',
    value        => '>= 3 over card',
    expected     => '',
);

test_boardcards_condition(
    test         => 'over pair',
    actions      => [(
        'autoplayer cards Tc 3d',
        'deal Jd 3c Jc',
    )],
    condition    => 'board',
    value        => 'over pair',
    expected     => 1,
);

sub test_boardcards_condition {
    my (%options) = @_;
    $options{'condition'}    = $options{'condition'} || 'board';
    $options{'players'}      = 3;
    $options{'strategyType'} = 'limit';
    $options{'autoplayer'}   = $options{'autoplayer'} || 'dealer';

    test_condition(%options);
}
