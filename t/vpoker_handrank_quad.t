use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 7;
use VPoker::Card;
use_ok('VPoker::HandRank::Quad');
ok(
    my $quadWithCards = VPoker::HandRank::Quad->new(
        'quad' => [
            VPoker::Card->new('Td'),
            VPoker::Card->new('Ts'),
            VPoker::Card->new('Td'),
            VPoker::Card->new('Tc'),

        ],
        'kicker' => VPoker::Card->new('Ah'),
    ),
    'initial quad with card object array',
);
is( $quadWithCards->quad_card->rank, 10, 'correct quad card', );
is( $quadWithCards->kicker->rank,    14, 'highest kicker is A', );

ok(
    my $quadWithCardFaces = VPoker::HandRank::Quad->new(
        'quad'   => [ '9d', '9c', '9s', '9h' ],
        'kicker' => 'Kd',
    ),
    'initial quad with card object array',
);
is(
    $quadWithCardFaces->quad_card->rank,
    9, 'init with card face: correct quad card',
);
is(
    $quadWithCardFaces->kicker->rank,
    13, 'init with card face: highest kicker is K',
);
