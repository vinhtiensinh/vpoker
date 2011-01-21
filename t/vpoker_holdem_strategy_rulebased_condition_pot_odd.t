use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use VPoker::Test::Table;
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Test::ConditionTester;
use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::PotOdd');

test_pot_odd_condition(
    test         => 'pot odd - test pod odd > a certain number',

    actions      => [(
        'firster bet',
        'seconder, thirder, fourther, fifther, sixther call',
    )],

    value        => '75 %',
    expected     => 1,
);

sub test_pot_odd_condition {
    my (%options) = @_;
    $options{'condition'}    = 'pot odd';
    $options{'players'}      = $options{'players'} || 9;
    $options{'strategyType'} = 'limit';
    $options{'autoplayer'}   = $options{'autoplayer'} || 'dealer';

    test_condition(%options);
}
