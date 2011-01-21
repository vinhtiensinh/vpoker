use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

no warnings 'once';

use Test::More tests => 27;
use VPoker::Holdem::Strategy;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::Integer');

my $integerCondition = VPoker::Holdem::Strategy::RuleBased::Condition::Integer->new(
    strategy        => VPoker::Holdem::Strategy->new,
);

foreach my $value ((4, 'greater 4', 'less 2', 'between 3 6')) {
    ok($integerCondition->validate($value), "$value is correct value");
}

ok(!$integerCondition->validate('4.5'), '4.5 is not correct');
ok(!$integerCondition->validate('greeter 5'), 'greeter is not correct');
ok($integerCondition->validate('less than 5'), 'less than 5 is correct');
ok($integerCondition->validate('between 3 and 4'), 'between 3 and 4 is correct');
ok(!$integerCondition->validate('zero'), 'zero is not correct, use 0');

## override, this method is provided by child class.
{
    no warnings 'redefine';
    *VPoker::Holdem::Strategy::RuleBased::Condition::Integer::condition_value = sub { return 2 };
}

foreach my $value ((4, 'greater 4', 'greater 2', 'less 2', 'between 3 6', 'between 0 1')) {
    ok(!$integerCondition->is_satisfied($value), "$value is not 2 (correct value)");
}

foreach my $value((2, 'greater 1', 'less 3', 'between 1 2', 'between 1 3', 'between 2 3', '>= 2', '<= 2', '> 1', '< 3')) {
    ok($integerCondition->is_satisfied($value), "$value is correct for 2");
}

## override, this method is provided by child class.
{
    no warnings 'redefine';
    *VPoker::Holdem::Strategy::RuleBased::Condition::Integer::condition_value = sub { return scalar ({}) };
}

ok(!$integerCondition->is_satisfied('0'), "'0' should not satisfied for 1");