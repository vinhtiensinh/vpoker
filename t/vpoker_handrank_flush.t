use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 4;
use VPoker::Card;
use_ok('VPoker::HandRank::Flush');
ok(
    my $flushWithCards = VPoker::HandRank::Flush->new(
        VPoker::Card->new('Td'), VPoker::Card->new('2d'),
        VPoker::Card->new('Ad'), VPoker::Card->new('Kd'),
        VPoker::Card->new('3d'),
    ),
    'initial flush with card object array',
);

is( $flushWithCards->suit, 2, 'flush is diamond', );

ok( !$flushWithCards->is_straight_flush, 'is not straight flush', );

