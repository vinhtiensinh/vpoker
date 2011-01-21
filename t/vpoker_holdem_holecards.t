use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 36;
use_ok('VPoker::Card');
use_ok('VPoker::Holdem::HoleCards');

ok( my $holeCards = VPoker::Holdem::HoleCards->new( 'Ts', 'Td' ),
    'new success TsTd' );
ok( $holeCards->is_pair,       'TsTd is pair' );
ok( $holeCards->face,          'TsTd face is TsTd' );
ok( !$holeCards->is_connected, 'TsTd is not connected' );
ok( !$holeCards->is_suited,    'TsTd is not suited' );
ok(
    my $holeCards2 = VPoker::Holdem::HoleCards->new(
        VPoker::Card->new(
            rank => 10,
            suit => 1,
        ),
        VPoker::Card->new(
            rank => 9,
            suit => 1,
        ),
    ),
    'new with VPoker::Card'
);
is( $holeCards2->face, 'Tc9c', '10c9c face is Tc9c' );
ok( $holeCards2->is('9Ts'),            'Tc9c is 9Ts' );
ok( $holeCards2->is_suited,            '9c8c is suited' );
ok( $holeCards2->is_connected,         '9c8c is connected' );
ok( $holeCards2->is_suited_connectors, '9c8c is suited connectors' );
ok( $holeCards2->is_any_of( '9J', '9Ts', 'JQ', 'QK' ), 'is any of find cards' );
ok( !$holeCards2->is_any_of( '9J', '29', 'JQ', 'QK' ),
    'is any of not find cards' );
my $holeCards3 = VPoker::Holdem::HoleCards->new( 'As', 'Kd' );
ok( $holeCards3->is_connected,          'AsKd is connected' );
ok( !$holeCards3->is_suited,            'AsKd is not suited' );
ok( !$holeCards3->is_suited_connectors, 'AsKd is not suited connectors' );

my $holeCards4 = VPoker::Holdem::HoleCards->new( 'As', '2d' );
ok( $holeCards4->is_connected, 'As2d is connected' );
ok( $holeCards4->is('2A'), 'As2d is 2A' );

my $holeCards5 = VPoker::Holdem::HoleCards->new( 'Ks', 'Td' );
ok($holeCards5  >= 'JT', 'KT >= JT');
ok($holeCards5  >= 'QT', 'KT >= QT');
ok(!($holeCards5 >= 'AQ'), 'not KT >= AQ');
ok(!($holeCards5 >= 'QJ'), 'not KT >= QJ');
ok(!($holeCards5 >= 'JJ'), 'not KT >= JJ');
ok($holeCards5 <= 'AQ', 'KT <= AQ');

my $holeCards6 = VPoker::Holdem::HoleCards->new( 'Ah', '2h' );
ok(!($holeCards6 >= 'AQ'), 'not A2 >= AQ');
ok(!($holeCards6 < 'KJ'), 'not A2 < KJ');

my $gap1 = VPoker::Holdem::HoleCards->new( 'Ah', '3h' );
ok($gap1->is_gap1, 'A3 is gap1');
ok($gap1 >= 'A3sg1', 'A3s is >= A2sg1');

my $gap2 = VPoker::Holdem::HoleCards->new( 'Kh', 'Ts' );
ok($gap2->is_gap2, 'KT is gap2');
ok($gap2 >= 'Q9g2', 'KT is >= Q9');
ok(!($gap2 >= 'Q9sg2'), 'KhTs is >= Q9 bot not suited');

my $gap3 = VPoker::Holdem::HoleCards->new( 'Ah', 'Ts' );
ok($gap3->is_gap3, 'AT is gap3');
ok($gap3 >= 'Q8g3', 'AT is >= Q8');
ok(!($gap3 >= 'Q9sg3'), 'AhTs is >= Q8 bot not suited');



