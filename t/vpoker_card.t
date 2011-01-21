use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 23;
use_ok('VPoker::Card');

my $tenSpade = VPoker::Card->new(
    rank => 10,
    suit => VPoker::Card::SPADE(),
);

is( $tenSpade->rank, 10,                    'rank' );
is( $tenSpade->suit, VPoker::Card::SPADE(), 'suit' );
is( $tenSpade->face, 'Ts',                  'face' );
ok( $tenSpade->is('T'),                       'Ts is T' );
ok( $tenSpade->is( VPoker::Card->new('Ts') ), 'Ts is VPoker::Card->new(Ts)' );
ok( $tenSpade->is('Ts'),                      'Ts is Ts' );
ok( !$tenSpade->is('Td'),                     'Ts is not is Td' );
ok( $tenSpade->is_not('Td'),                  'Ts is not Td' );

my $tenDiamond = VPoker::Card->new(
    rank => 10,
    suit => VPoker::Card::DIAMOND(),
);

my $jackSpade = VPoker::Card->new(
    rank => 11,
    suit => VPoker::Card::SPADE(),
);

my $aceClub = VPoker::Card->new(
    rank => 14,
    suit => VPoker::Card::CLUB(),
);

ok( $tenSpade == $tenDiamond,   'Ts == Td' );
ok( $tenSpade != $jackSpade,    'Ts != Js' );
ok( $jackSpade > $tenDiamond,   'Js > Td' );
ok( !( $aceClub < $jackSpade ), 'Ac > Js' );
ok( $tenSpade == 'T',            'compare with card face');
ok( $tenSpade < 'Q',            'Ts < Q');

## Initialize using card face
my $tenSpadeStr = VPoker::Card->new('Ts');
is( $tenSpadeStr->rank, 10, 'Ts rank: 10' );
is( $tenSpadeStr->suit, 4,  'Ts suit: 4' );
ok( $tenSpade == $tenSpadeStr, 'initialize using string' );

## validate card face
ok(VPoker::Card->validate_card_face('A'), 'A is a valid card face');
ok(VPoker::Card->validate_card_face('Ax'), 'Ax is a valid card face');
ok(VPoker::Card->validate_card_face('Xc'), 'Xc is a valid card face');
ok(VPoker::Card->validate_card_face('Xx'), 'Xx is a valid card face');
ok(!VPoker::Card->validate_card_face('AA'), 'AA is not a valid card face');
