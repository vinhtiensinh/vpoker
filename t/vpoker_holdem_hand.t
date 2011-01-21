use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 33;
use_ok('VPoker::Holdem::Hand');
use_ok('VPoker::Holdem::BetRound');
use_ok('VPoker::CardSet');
use_ok('VPoker::Card');
use_ok('VPoker::Holdem::Player');
use_ok('VPoker::Action');
use_ok('VPoker::Table');
my $table   = VPoker::Table->new;
my $player1 = VPoker::Holdem::Player->new( name => 'vinhking', balance => 100 );
my $player2 = VPoker::Holdem::Player->new( name => 'bettowin', balance => 100 );
my $player3 = VPoker::Holdem::Player->new( name => 'ultimate', balance => 100 );
my $player4 = VPoker::Holdem::Player->new( name => 'pacific', balance => 100 );

$player1->join( $table, 0 );
$player2->join( $table, 1 );
$player3->join( $table, 2 );
$player4->join( $table, 3 );
ok( my $hand = $table->new_hand, 'create new hand ok' );
$table->chair(0)->in_play(1);
$table->chair(1)->in_play(1);
$table->chair(2)->in_play(1);
$table->chair(3)->in_play(1);

ok( $hand->bet_round->is_preflop, 'hand bet round is preflop' );
$hand->dealer_chair( $table->chair(0) );
$hand->small_blind_chair( $table->chair(1) );
$hand->big_blind_chair( $table->chair(2) );

is( $hand->to_act, undef, 'no one post blind next to act is undef', );

$hand->new_action( $player2, 'post', 1 );
$hand->new_action( $player3, 'post', 2 );

is( $hand->total_pot, 3, 'total pot is 3', );

is( $hand->to_act, $player4, 'player 4 is next to act', );

$hand->new_action( $player4, 'bet', 10 );

my @players_to_act = $hand->players_to_act;
ok(
    $players_to_act[0] == $player1
      && $players_to_act[1] == $player2
      && $players_to_act[2] == $player3
      && scalar @players_to_act == 3,
    'correct players_to_act',
);

$hand->new_action( $player1, 'raise', 20 );

@players_to_act = $hand->players_to_act;

ok(
    $players_to_act[0] == $player2
      && $players_to_act[1] == $player3
      && $players_to_act[2] == $player4
      && scalar @players_to_act == 3,
    'correct players_to_act',
);

$hand->new_action( $player2, 'call', 20 );
$hand->new_action( $player3, 'fold', 2 );
$table->chair(2)->in_play(0);
$hand->new_action( $player4, 'call', 20 );

is( $hand->to_act, undef, 'ending betting round, no more to act', );

is( $hand->preflop->actions->total, 7, 'correct preflop actions' );
ok( !$hand->board->flop, 'flop is empty' );
ok(
    $hand->deal( VPoker::CardSet->new( 'Ad', 'Th', 'Jh' ) ),
    'deal the first three card',
);

ok( $hand->bet_round->is_flop, 'hand bet round is flop' );

is( $hand->total_pot, 62, 'total pot carry over to next bet round', );

is( $hand->to_act->name, $player2->name, 'on flop player 2 act first', );

$hand->new_action( $player2, 'check' );
$hand->new_action( $player4, 'check' );
$hand->new_action( $player1, 'bet', 10 );
$hand->new_action( $player2, 'call', 10 );
$hand->new_action( $player4, 'fold' );

is( $hand->to_act, undef, 'ending betting round, no more to act', );

is( $hand->flop->actions->total, 5, 'flop actions number correct' );
is( $hand->actions->total, 12, 'total hand actions correct' );
ok( $hand->board->flop->has( 'Ad', 'Th', 'Jh' ), 'correct flop cards' );
ok( $hand->deal( VPoker::Card->new('2d') ), 'deal 2d' );
ok( $hand->bet_round->is_turn,              'hand bet round is turn' );
ok( $hand->bet_round->previous->is_flop,    'hand previous bet round is flop' );
ok( $hand->flop->next->is_turn,             'hand next of flop bet round is turn' );
ok( $hand->deal('4c'),                      'deal river' );
ok( $hand->bet_round->is_river,             'hand bet round is river' );
ok( $hand->bet_round->previous->is_turn,    'hand previous bet round is flop' );
ok( $hand->turn->next->is_river,            'hand next of turn bet round is river' );

