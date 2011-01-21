use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

no warnings 'redefine';

use Test::More tests => 10;
use VPoker::Holdem::Strategy;

use_ok('VPoker::Holdem::Strategy::RuleBased::ConditionFactory');

my %all_condition_class_mapping = (
    'hand'            => 'VPoker::Holdem::Strategy::RuleBased::Condition::Hand',
    'action round'    => 'VPoker::Holdem::Strategy::RuleBased::Condition::ActionRound',
    'bet round'       => 'VPoker::Holdem::Strategy::RuleBased::Condition::BetRound',
    'board'           => 'VPoker::Holdem::Strategy::RuleBased::Condition::BoardCards',
    'hole cards'      => 'VPoker::Holdem::Strategy::RuleBased::Condition::HoleCards',
    'betting'         => 'VPoker::Holdem::Strategy::RuleBased::Condition::Betting',
    'position'        => 'VPoker::Holdem::Strategy::RuleBased::Condition::Position',
    'caller'          => 'VPoker::Holdem::Strategy::RuleBased::Condition::Caller',
    'preflop betting' => 'VPoker::Holdem::Strategy::RuleBased::Condition::PreflopBetting',
);

while( my ($header, $class) = each %all_condition_class_mapping) {
    my $condition =
        VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(name => $header);
    isa_ok(
        $condition,
        $class,
        "create $header condition",
    );
}
