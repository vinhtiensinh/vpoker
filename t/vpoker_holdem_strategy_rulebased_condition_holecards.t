use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
no warnings 'redefine';
 
use Test::More tests => 31;
use VPoker::Holdem::Strategy;
use VPoker::Holdem::HoleCards;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::HoleCards');

my $holeCardsCondition = VPoker::Holdem::Strategy::RuleBased::Condition::HoleCards->new(
    strategy => VPoker::Holdem::Strategy->new
);

foreach my $value (('pair', 'suited', 'connected', 'suited connectors', 'KK', 'AKs', 'AJ', 'AX', 'KXs')) {
    ok($holeCardsCondition->validate($value), "$value is correct value");
}

{
    *VPoker::Holdem::Strategy::hole_cards = sub {return VPoker::Holdem::HoleCards->new('Ac', 'Kc')};
    ok($holeCardsCondition->is_satisfied('AK'), 'is AK');
    ok($holeCardsCondition->is_satisfied('AKs'), 'is AKs');
    ok($holeCardsCondition->is_satisfied('suited'), 'is suited');
    ok($holeCardsCondition->is_satisfied('connected'), 'is connected');
    ok($holeCardsCondition->is_satisfied('suited connectors'), 'is suited connectors');
    ok(!$holeCardsCondition->is_satisfied('pair'), 'is not pair');
    ok(!$holeCardsCondition->is_satisfied('AQ'), 'is not AQ');
}

{
    *VPoker::Holdem::Strategy::hole_cards = sub {return VPoker::Holdem::HoleCards->new('Kd', 'Kc')};
    ok(!$holeCardsCondition->is_satisfied('suited'), 'is not suited');
    ok(!$holeCardsCondition->is_satisfied('connected'), 'is not connected');
    ok(!$holeCardsCondition->is_satisfied('suited connectors'), 'is not suited connectors');
    ok($holeCardsCondition->is_satisfied('pair'), 'is pair');
}

{
    *VPoker::Holdem::Strategy::hole_cards = sub {return VPoker::Holdem::HoleCards->new('Td', 'Kc')};
    ok(!$holeCardsCondition->is_satisfied('suited'), 'is not suited');
    ok(!$holeCardsCondition->is_satisfied('connected'), 'is not connected');
    ok(!$holeCardsCondition->is_satisfied('suited connectors'), 'is not suited connectors');
    ok(!$holeCardsCondition->is_satisfied('pair'), 'is pair');
    ok($holeCardsCondition->is_satisfied('KT'), 'is KT');
    ok($holeCardsCondition->is_satisfied('KX'), 'is KX');
    ok($holeCardsCondition->is_satisfied('>= K9'), '>= K9');
    ok($holeCardsCondition->is_satisfied('<= AT'), '<= AT');
    ok($holeCardsCondition->is_satisfied('>= 99'), '>= 99');


}

{
    *VPoker::Holdem::Strategy::hole_cards = sub {return VPoker::Holdem::HoleCards->new('Ah', '2h')};
    ok(!($holeCardsCondition->is_satisfied('>= AQ')), 'A2 is not >= AQ');
}
