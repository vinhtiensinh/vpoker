use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 9;
use VPoker::Card;
use_ok('VPoker::HandRank::Trip');
ok(
    my $tripWithCards = VPoker::HandRank::Trip->new(
        'trip' => [
            VPoker::Card->new('Td'), VPoker::Card->new('Ts'),
            VPoker::Card->new('Td'),
        ],
        'kickers' => [
            VPoker::Card->new('Kh'), VPoker::Card->new('Ac'),
            VPoker::Card->new('2c'),
        ],
    ),
    'initial trip with card object array',
);
is( $tripWithCards->trip_card->rank, 10, 'correct pair card', );
is( $tripWithCards->kicker->rank,    14, 'highest kicker is A', );
is( $tripWithCards->kicker(2)->rank, 13, 'second kicker is K', );

ok(
    my $tripWithCardFaces = VPoker::HandRank::Trip->new(
        'trip'    => [ '9d', '9c', '9s' ],
        'kickers' => [ 'Kd', 'Ac', '2d' ],
    ),
    'initial trip with card object array',
);
is(
    $tripWithCardFaces->trip_card->rank,
    9, 'init with card face: correct trip card',
);
is(
    $tripWithCardFaces->kicker->rank,
    14, 'init with card face: highest kicker is A',
);
is(
    $tripWithCardFaces->kicker(2)->rank,
    13, 'init with card face: second kicker is K',
);
