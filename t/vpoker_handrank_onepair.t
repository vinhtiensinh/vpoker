use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 9;
use VPoker::Card;
use_ok('VPoker::HandRank::OnePair');
ok(
    my $onePairWithCards = VPoker::HandRank::OnePair->new(
        'pair'    => [ VPoker::Card->new('Td'), VPoker::Card->new('Ts') ],
        'kickers' => [
            VPoker::Card->new('Kh'), VPoker::Card->new('Ac'),
            VPoker::Card->new('2c'),
        ],
    ),
    'initial one pair with card object array',
);
is( $onePairWithCards->pair_card->rank, 10, 'correct pair card', );
is( $onePairWithCards->kicker->rank,    14, 'highest kicker is A', );
is( $onePairWithCards->kicker(2)->rank, 13, 'second kicker is K', );

ok(
    my $onePairWithCardFaces = VPoker::HandRank::OnePair->new(
        'pair'    => [ '9d', '9c' ],
        'kickers' => [ 'Kd', 'Ac', '2d' ],
    ),
    'initial one pair with card object array',
);
is(
    $onePairWithCardFaces->pair_card->rank,
    9, 'init with card face: correct pair card',
);
is(
    $onePairWithCardFaces->kicker->rank,
    14, 'init with card face: highest kicker is A',
);
is(
    $onePairWithCardFaces->kicker(2)->rank,
    13, 'init with card face: second kicker is K',
);
