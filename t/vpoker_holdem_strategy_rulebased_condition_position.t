use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
 
use Test::More tests => 28;
use VPoker::Holdem::Strategy;



use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::Position');

my $positionCondition = VPoker::Holdem::Strategy::RuleBased::Condition::Position->new(
    strategy => VPoker::Holdem::Strategy->new
);

foreach my $value (qw(early middle late last button SB BB 9)) {
    ok($positionCondition->validate($value), "$value is correct value");
}

## override, this method is provided by child class.
{
    *VPoker::Holdem::Strategy::position       = sub { return 2 };
    *VPoker::Holdem::Strategy::players_behind = sub { return 5 } ;

    ok($positionCondition->is_satisfied(2), 'position is 2');
    ok(!$positionCondition->is_satisfied('greater 3'), 'position is not greater 3');
    ok($positionCondition->is_satisfied('early'), 'check if position is early');
    ok(!$positionCondition->is_satisfied('middle'), 'check if position is not middle');
    ok(!$positionCondition->is_satisfied('late'), 'check if position is not late');
    ok(!$positionCondition->is_satisfied('last'), 'check if position is not last');
}

{
    *VPoker::Holdem::Strategy::players_behind = sub { return 4 } ;
    ok($positionCondition->is_satisfied('early'), 'check if position is early');
    ok(!$positionCondition->is_satisfied('late'), 'check if position is late');
    ok(!$positionCondition->is_satisfied('last'), 'check if position is not last');
}

{
    *VPoker::Holdem::Strategy::players_behind = sub { return 1 } ;
    ok(!$positionCondition->is_satisfied('early'), 'check if position is not early');
    ok(!$positionCondition->is_satisfied('middle'), 'check if position is not middle');
    ok($positionCondition->is_satisfied('late'), 'check if position is late');
    ok(!$positionCondition->is_satisfied('last'), 'check if position is not last');
}

{
    *VPoker::Holdem::Strategy::players_behind = sub { return 0 } ;
    ok(!$positionCondition->is_satisfied('early'), 'check if position is not early');
    ok(!$positionCondition->is_satisfied('middle'), 'check if position is not middle');
    ok($positionCondition->is_satisfied('late'), 'check if position is late');
    ok(!$positionCondition->is_satisfied('second last'), 'check if position is not second last');
    ok($positionCondition->is_satisfied('last'), 'check if position is last');
}

{
    *VPoker::Holdem::Strategy::players_behind = sub { return 1 } ;
    ok($positionCondition->is_satisfied('second last'), 'check if position is second last');
}
