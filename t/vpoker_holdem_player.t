use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 19;
use_ok('VPoker::Table');
use_ok('VPoker::Holdem::Player');

ok(
    my $player1 = VPoker::Holdem::Player->new(
        name    => 'vinhtiensinh',
        balance => 100,
    ),
    'vinhtiensinh player created'
);
ok(
    my $player2 = VPoker::Holdem::Player->new(
        name    => 'bettowin',
        balance => 100,
    ),
    'bettowin player created'
);

ok( my $table = VPoker::Table->new, 'new table created' );
$player1->join( $table, 0 );
$player2->join( $table, 3 );

ok( $table->chair(0)->player == $player1, 'player1 join table at chair 0' );
ok( $table->chair(3)->player == $player2, 'player2 join table at chair 1' );
ok( my $hand = $table->new_hand, 'table create new hand' );
$hand->dealer_chair( $table->chair(0) );

is( $player1->current_bet, 0, 'player 1 current bet is 0' );
$player1->check;
is( $hand->actions->total, 1, 'player 1 bet 10, one action' );
is( $player1->current_bet, 0, 'player 1 bet 10' );
$player2->check;
is( $hand->actions->total, 2, 'player 1 check and player 2 check, 2 actions' );
$hand->deal( 'Jh', 'Th', 'Ac' );
$player1->bet(10);
is( $player1->current_bet, 10, 'player 1 current bet 10' );
$player2->raise(20);
is( $player2->current_bet, 20, 'player 2 current bet 20' );
is( $player1->to_call,     10, 'player 1 need 10 to call' );
$player1->call;
is( $player1->current_bet, 20, 'player 1 call, current bet is 20' );

$player1->leave;
$player2->leave;
is( $table->chair(0)->player, undef, 'player 1 leave, chair 0 is empty' );
is( $player1->chair,          undef, 'player 1 chair is undef' );
is( $player1->table,          undef, 'player 1 table is undef' );

