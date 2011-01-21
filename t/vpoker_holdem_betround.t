use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 28;
use_ok('VPoker::Holdem::BetRound');
use_ok('VPoker::Action');
use_ok('VPoker::Holdem::Player');
use_ok('VPoker::Chair');

my $player1 = VPoker::Holdem::Player->new( name => 'vinhking', balance => 100 );
my $player2 = VPoker::Holdem::Player->new( name => 'bettowin', balance => 100 );
my $player3 =
  VPoker::Holdem::Player->new( name => 'pokerstar', balance => 100 );
my $player4 = VPoker::Holdem::Player->new( name => 'fulltilt', balance => 100 );

$player1->chair( VPoker::Chair->new );
$player1->chair->in_play(1);
$player2->chair( VPoker::Chair->new );
$player2->chair->in_play(1);
$player3->chair( VPoker::Chair->new );
$player3->chair->in_play(1);
$player4->chair( VPoker::Chair->new );
$player4->chair->in_play(1);

## ----------------------------------------------------------------------------
## Testing bet round type
ok(
    my $preflop = VPoker::Holdem::BetRound->new_preflop,
    'create preflop betround',
);
ok( $preflop->is_preflop, 'is preflop bet round' );
$preflop->position_of( $player1, 1 );
$preflop->position_of( $player2, 2 );
$preflop->position_of( $player3, 3 );
$preflop->position_of( $player4, 4 );

is( $preflop->position_of($player1), 1, 'position of player1 is 0', );

is( $preflop->position_of($player2), 2, 'position of player2 is 2', );

is( $preflop->position_of($player3), 3, 'position of player3 is 3', );

is(
    $preflop->player_at_position(1),
    $player1, 'player at position 1 is player1',
);

is(
    $preflop->player_at_position(2),
    $player2, 'player at postion 2 is player2',
);

is(
    $preflop->player_at_position(3),
    $player3, 'player at postion 3 is player3',
);

is(
    $preflop->player_at_position(4),
    $player4, 'player at postion 3 is player3',
);

my @playersRemain = $preflop->players_remain;
is( scalar @playersRemain, 4, 'correct player remains', );

my @playersBeforePlayer3 = $preflop->players_before($player3);
is( $playersBeforePlayer3[0], $player1, 'player 1 before player 3', );
is( $playersBeforePlayer3[1], $player2, 'player 2 before player 3', );

my @playersBehindPlayer3 = $preflop->players_behind($player3);
is( $playersBehindPlayer3[0], $player4, 'player 4 behind player 3', );

ok( my $flop = VPoker::Holdem::BetRound->new_flop, 'create flop betround', );
ok( $flop->is_flop, 'is flop bet round' );
ok( my $turn = VPoker::Holdem::BetRound->new_turn, 'create turn betround', );
ok( $turn->is_turn, 'is turn bet round' );
ok( my $river = VPoker::Holdem::BetRound->new_river, 'create river betround', );
ok( $river->is_river, 'is river bet round' );

## ----------------------------------------------------------------------------
## Testing actions
$preflop->new_action( $player1, 'bet',   10 );
$preflop->new_action( $player2, 'raise', 20 );
$preflop->new_action( $player1, 'call' );
ok( my $player1Actions = $preflop->player_actions($player1),
    'get player1 actions' );

ok( $player1Actions->action(1)->is_bet,  'player 1 first action is bet' );
ok( $player1Actions->action(2)->is_call, 'player 1 2nd action is call' );
ok(
    my $player2Actions = $preflop->player_actions($player2),
    'get player2 actions',
);
ok( $player2Actions->action(1)->is_raise, 'player2 action is raise' );
