use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 9;
use VPoker::Card;
use_ok('VPoker::HandRank::TwoPairs');
ok(
    my $twoPairWithCards = VPoker::HandRank::TwoPairs->new(
        'pair1'  => [ VPoker::Card->new('Td'), VPoker::Card->new('Ts') ],
        'pair2'  => [ VPoker::Card->new('Qd'), VPoker::Card->new('Qc') ],
        'kicker' => VPoker::Card->new('Kh'),
    ),
    'initial two pair with cards',
);
is( $twoPairWithCards->high_pair_card->rank, 12, 'high pair is Q', );
is( $twoPairWithCards->low_pair_card->rank,  10, 'low pair is 10', );
is( $twoPairWithCards->kicker->rank,         13, 'kicker is K', );

ok(
    my $twoPairWithCardFaces = VPoker::HandRank::TwoPairs->new(
        'pair1'  => [ 'Td', 'Ts' ],
        'pair2'  => [ '2d', '2c' ],
        'kicker' => VPoker::Card->new('Ah'),
    ),
    'initial two pair with cards',
);
is( $twoPairWithCardFaces->high_pair_card->rank, 10, 'high pair is T', );
is( $twoPairWithCardFaces->low_pair_card->rank,  2,  'low pair is 2', );
is( $twoPairWithCardFaces->kicker->rank,         14, 'kicker is A', );
