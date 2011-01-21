use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 7;
use VPoker::Card;
use_ok('VPoker::HandRank::FullHouse');
ok(
    my $fullhouseWithCards = VPoker::HandRank::FullHouse->new(
        'trip' => [
            VPoker::Card->new('Td'), VPoker::Card->new('Ts'),
            VPoker::Card->new('Td'),
        ],
        'pair' => [ VPoker::Card->new('Ah'), VPoker::Card->new('As'), ],
    ),
    'initial fullhouse with card object array',
);
is( $fullhouseWithCards->trip_card->rank, 10, 'trip card is T', );
is( $fullhouseWithCards->pair_card->rank, 14, 'pair is A', );

ok(
    my $fullhouseWithCardFaces = VPoker::HandRank::FullHouse->new(
        'trip' => [ '9d', '9c', '9s' ],
        'pair' => [ 'Kd', 'Kc' ]
    ),
    'initial fullhouse with card face',
);
is(
    $fullhouseWithCardFaces->trip_card->rank,
    9, 'init with card face: correct trip card',
);
is(
    $fullhouseWithCardFaces->pair_card->rank,
    13, 'init with card face: correct pair card',
);
