use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More qw(no_plan);
use_ok('VPoker::Holdem::Strategy::RuleBased::Condition');


is(
    VPoker::Holdem::Strategy::RuleBased::Condition->new(
        name => 'test',
        value => 'value',
    )->to_string,
    'test.value',
    'to_string single value'
);

is(
    VPoker::Holdem::Strategy::RuleBased::Condition->new(
        name => 'test',
        value => ['value', 'array'] ,
    )->to_string,
    'test.array;value',
    'to_string multiple or value, the order of the values should be shorted'
);
is(
    VPoker::Holdem::Strategy::RuleBased::Condition->new(
        name => 'test',
        value => [['mixed', 'complex'], ['value', 'array']] ,
    )->to_string,
    'test.array&value;complex&mixed',
    'complex value with "and" and "or" mixin, each individual value should be shorted as well to make it unique',
);


