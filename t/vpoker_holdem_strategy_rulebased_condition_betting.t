use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use VPoker::Test::Table;
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Test::ConditionTester;

test_betting_condition(
    test         => 'preflop betting - test autoplayer bet detected',

    actions      => [(
        'autoplayer bet',
        'sblinder call',
        'bblinder call',
        'deal Ac Ad Ah',
    )],

    value        => 'autoplayer bet',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop betting - test autoplayer bet detected some one else raise',

    actions      => [(
        'autoplayer bet',
        'sblinder bet',
        'bblinder call',
        'deal Ac Ad Ah',
    )],

    value        => 'autoplayer bet',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop betting - test autoplayer not raise detected',

    actions      => [(
        'autoplayer bet',
        'sblinder bet',
        'bblinder call',
        'deal Ac Ad Ah',
    )],

    value        => 'autoplayer raised',
    expected     => 0,
);

test_betting_condition(
    test         => 'preflop betting -  bettor behind detected',
    autoplayer   => 'sblinder',

    actions      => [(
        'dealer bet',
        'sblinder call',
        'bblinder call',
        'deal Ac Ad Ah',
    )],

    value        => 'bettor behind',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop betting -  auto player lead',
    autoplayer   => 'sblinder',

    actions      => [(
        'dealer call',
        'sblinder bet',
        'bblinder call',
        'deal Ac Ad Ah',
        'dealer bet',
    )],

    value        => 'autoplayer lead',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop betting -  auto player not lead',

    actions      => [(
        'dealer bet',
        'sblinder bet',
        'bblinder call',
        'deal Ac Ad Ah',
        'dealer bet',
    )],

    value        => 'autoplayer lead',
    expected     => '',
);

test_betting_condition(
    test         => 'preflop betting -  opponent lead',

    actions      => [(
        'dealer bet',
        'sblinder bet',
        'bblinder call',
        'deal Ac Ad Ah',
        'dealer bet',
    )],

    value        => 'opponent lead',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop betting -  auto player not lead',

    actions      => [(
        'dealer call',
        'sblinder call',
        'bblinder check',
    )],

    value        => 'opponent lead',
    expected     => '',
);

test_betting_condition(
    test         => 'preflop betting -  bet from late',
    players      => 7,
    autoplayer   => 'firster',
    actions      => [(
        'firster call',
        'seconder call',
        'thirder call',
        'fourther call',
        'dealer bet',
        'sblinder call',
        'bblinder call',
    )],

    value        => 'bet from late',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  raised from middle',
    players      => 7,
    autoplayer   => 'firster',
    condition    => 'betting',
    actions      => [(
        'firster call',
        'seconder bet',
        'thirder bet',
        'fourther fold',
        'dealer fold',
        'sblinder call',
        'bblinder call',
    )],

    value        => 'raised from middle',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  any bettor behind',
    players      => 7,
    autoplayer   => 'fourther',
    condition    => 'betting',
    actions      => [(
        'firster call',
        'seconder call',
        'thirder bet',
        'fourther fold',
        'dealer bet',
        'sblinder call',
        'bblinder call',
    )],

    value        => 'any bettor behind',
    expected     => 1,
);

test_betting_condition(
    test         => 'preflop -  any bettor behind',
    players      => 7,
    autoplayer   => 'fourther',
    actions      => [(
        'firster call',
        'seconder fold',
        'thirder bet',
        'fourther call',
        'dealer bet',
        'sblinder call',
        'bblinder call',
        'deal Ac Ah Ad',
        'firster bet',
        'thirder fold',
    )],

    value        => 'any bettor behind',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  any bettor behind bettor already fold',
    players      => 3,
    autoplayer   => 'bblinder',
    condition    => 'flop betting',
    actions      => [(
        'dealer bet',
        'sblinder bet',
        'bblinder call',
        'dealer fold',
        'deal Ac Ah Ad',
        'sblinder bet',
    )],

    value        => 'any bettor behind',
    expected     => 0,
);

test_betting_condition(
    test         => 'betting -  not any bettor behind',
    players      => 7,
    autoplayer   => 'fourther',
    condition    => 'betting',
    actions      => [(
        'firster call',
        'seconder bet',
        'thirder bet',
        'fourther fold',
        'dealer fold',
        'sblinder call',
        'bblinder call',
    )],

    value        => 'any bettor behind',
    expected     => 0,
);

test_betting_condition(
    test         => 'betting -  fold to me',
    players      => 7,
    actions      => [(
        'firster fold',
        'seconder fold',
        'thirder fold',
        'fourther fold',
    )],

    value        => 'fold to me',
    expected     => 1,
);

test_betting_condition(
    test => 'betting -  fold to me only check the first action round, also true on next action round',
    players      => 7,
    actions      => [(
        'firster fold',
        'seconder fold',
        'thirder fold',
        'fourther fold',
        'dealer bet',
        'sblinder bet',
        'bblinder fold',
    )],

    value        => 'fold to me',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  preflop bettor check',
    condition    => 'betting',
    players      => 7,
    actions      => [(
        'firster bet',
        'seconder call',
        'thirder fold',
        'fourther fold',
        'dealer call',
        'sblinder fold',
        'bblinder fold',
        'deal Ah',
        'firster check',
    )],

    value        => 'preflop bettor check',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  continue bet',
    condition    => 'betting',
    players      => 7,
    actions      => [(
        'firster bet',
        'seconder call',
        'thirder fold',
        'fourther fold',
        'dealer call',
        'sblinder fold',
        'bblinder fold',
        'deal Ah',
        'firster bet',
    )],

    value        => 'continue bet',
    expected     => 1,
);

test_betting_condition(
    test         => 'betting -  not continue bet',
    condition    => 'betting',
    players      => 7,
    actions      => [(
        'firster bet',
        'seconder call',
        'thirder fold',
        'fourther fold',
        'dealer call',
        'sblinder fold',
        'bblinder fold',
        'deal Ah',
        'firster check',
        'seconder check',
    )],

    value        => 'continue bet',
    expected     => 0,
);

test_betting_condition(
    test       => 'betting -  preflop bettor check - has not act yet',
    condition  => 'betting',
    autoplayer => 'fourther',
    players    => 7,
    actions    => [(
        'firster fold',
        'seconder fold',
        'thirder check',
        'fourther check',
        'dealer bet',
        'sblinder fold',
        'bblinder fold',
        'thirder call',
        'fourther call',
        'deal Ah',
        'firster check',
    )],

    value        => 'preflop bettor check',
    expected     => 0,
);

test_betting_condition(
    test       => 'betting -  preflop bettor check - some one else bet',
    condition  => 'betting',
    autoplayer => 'fourther',
    players    => 7,
    actions    => [(
        'firster fold',
        'seconder fold',
        'thirder check',
        'fourther check',
        'dealer bet',
        'sblinder fold',
        'bblinder fold',
        'thirder call',
        'fourther call',
        'deal Ah',
        'firster bet',
    )],

    value        => 'preflop bettor check',
    expected     => 0,
);

sub test_betting_condition {
    my (%options) = @_;
    $options{'condition'}    = $options{'condition'} || 'preflop betting';
    $options{'players'}      = $options{'players'} || 3;
    $options{'strategyType'} = 'limit';
    $options{'autoplayer'}   = $options{'autoplayer'} || 'dealer';

    test_condition(%options);
}
