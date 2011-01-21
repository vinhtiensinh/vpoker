use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 4;
use VPoker::Test::Table;
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Test::ConditionTester;

test_player_condition(
    test         => 'player condition - players remain',

    actions      => [(
        'firster bet',
        'sblinder bet',
        'bblinder fold',
    )],

    value        => 'players remain = 3',
    expected     => 1,
);

test_player_condition(
    test         => 'player condition - players behind',
    autoplayer   => 'bblinder',

    actions      => [(
        'firster bet',
    )],

    value        => 'players behind = 2',
    expected     => 1,
);

test_player_condition(
    test         => 'player condition - players = 3',
    autoplayer   => 'firster',

    actions      => [(
        'firster bet',
        'dealer fold',
        'sblinder call',
        'bblinder call',
        'deal Ac Ad Ah',
        'sblinder bet',
        'bblinder fold'
    )],

    value        => '3',
    expected     => 1,
);

test_player_condition(
    test         => 'player condition - players <= 3',
    autoplayer   => 'firster',

    actions      => [(
        'firster bet',
        'dealer fold',
        'sblinder call',
        'bblinder call',
        'deal Ac Ad Ah',
        'sblinder bet',
        'bblinder fold'
    )],

    value        => '<= 3',
    expected     => 1,
);
sub test_player_condition {
    my (%options) = @_;
    $options{'condition'}    = 'player';
    $options{'players'}      = 4;
    $options{'strategyType'} = 'limit';
    $options{'autoplayer'}   = $options{'autoplayer'} || 'dealer';

    test_condition(%options);
}

