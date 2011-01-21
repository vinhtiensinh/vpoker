use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;
use_ok('VPoker::Card');
use_ok('VPoker::Holdem::BoardCards');

ok( my $board = VPoker::Holdem::BoardCards->new, 'create new board' );
ok( $board->add( 'Ts', '9s', 'Kd' ), 'add flop cards Ts 9s Kd' );
ok( $board->add('Ac'), 'add turn Ac' );
ok( $board->add('2c'), 'add river 2c' );
ok( $board->flop->has( 'Ts', '9s', 'Kd' ), 'correct flop' );
ok( $board->turn->is('Ac'),  'correct turn card' );
ok( $board->river->is('2c'), 'correct river card' );
ok( $board->has( 'Ts', '9s', 'Kd', 'Ac', '2c' ), 'board has correct cards', )
