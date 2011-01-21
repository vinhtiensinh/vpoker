use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 63;
use_ok('VPoker::Card');
use_ok('VPoker::CardSet');

ok( my $cardSet = VPoker::CardSet->new( 'Ts', 'Td' ), 'new success TsTd' );

ok( !$cardSet->is_connected, 'TsTd is not connected' );
ok( !$cardSet->is_suited,    'TsTd is not suited' );
ok(
    my $cardSet2 = VPoker::CardSet->new(
        VPoker::Card->new(
            rank => 10,
            suit => 1,
        ),
        VPoker::Card->new(
            rank => 9,
            suit => 1,
        ),
        VPoker::Card->new(
            rank => 8,
            suit => 1,
        ),
    ),
    'new with VPoker::Card'
);
ok( $cardSet2->is_suited,    'Tc9c8c is suited' );
ok( $cardSet2->is_connected, 'Tc9c8c is connected' );
ok( $cardSet2->has( 'Tc', '8c' ), 'Tc9c8c has Tc 8c' );
ok( $cardSet2->has(
        VPoker::CardSet->new(
            VPoker::Card->new(rank => 10, suit => 1),
            VPoker::Card->new(rank => 9, suit => 1),
        )
    ),
    'Tc9c8c has Cardset(Tc9c)',
);

my $cardSet3 = VPoker::CardSet->new( 'As', 'Kd', 'Qd' );
ok( $cardSet3->is_connected, 'AsKdQc is connected' );
ok( !$cardSet3->is_suited, 'AsKdQc is not suited' );

my $cardSet4 = VPoker::CardSet->new( 'As', '2d', '3c' );
ok( $cardSet4->is_connected, 'As2d3c is connected' );

$cardSet4->add('4c');
ok( $cardSet4->is_connected, 'As2d3c4c is connected' );

$cardSet4->add('Ad');
ok( $cardSet4->has( 'A', 'A' ), $cardSet4->face . ' has A, A' );
ok( !$cardSet4->has( 'Ah', 'A' ), $cardSet4->face . ' do not have Ah, A' );
ok( $cardSet4->has( 'A', 'X'), $cardSet4->face . ' have AX' );
ok($cardSet4->has('A2'), $cardSet4->face . ' has A2');
ok($cardSet4->has('A24'), $cardSet4->face . ' has A24');
ok($cardSet4->has('34s'), $cardSet4->face . ' has 34s');
ok(!$cardSet4->has('A3s'), $cardSet4->face . ' does not have A3s');

## ----------------------------------------------------------------------------
## Testing card strength.
## ----------------------------------------------------------------------------

## ---------- Testing straight flush --------------
my $straightFlush =
  VPoker::CardSet->new( 'Kd', 'Jd', 'Td', '9d', '2d', '3c', 'Qd' );
ok( $straightFlush->strength->is_flush, 'KQJT92d 3c is flush', );

ok(
    $straightFlush->strength->is_straight_flush,
    'KQJT92d 3c is straight flush',
);

$straightFlush =
  VPoker::CardSet->new( 'Kd', 'Jd', 'Td', 'Ad', '2s', '3c', 'Qd' );
ok( $straightFlush->strength->is_flush, 'AKQJTd is flush', );

ok( $straightFlush->strength->is_straight_flush, 'AKQJTd is straight flush', );

$straightFlush =
  VPoker::CardSet->new( '4d', '5d', 'Ts', 'Ad', '2d', '3d', 'Ac' );
ok( $straightFlush->strength->is_flush, 'A2345d is flush', );

ok( $straightFlush->strength->is_straight_flush, 'A2345d is straight flush', );

## --------- Testing quad -----------------------
my $quad = VPoker::CardSet->new( 'Kd', 'Kc', 'Ks', 'Kh', 'Ad', '2c', 'Qd' );
ok( $quad->strength->is_quad, 'KKKK is quad', );

ok( $quad->strength->kicker->is('A'), 'correct kicker', );

## --------- Testing fullhouse -----------------------
$quad = VPoker::CardSet->new( 'Ad', 'Ac', '2s', '2h', '2c', '3c', 'Qd' );
ok( $quad->strength->is_fullhouse, 'AA222 is fullhouse', );

$quad = VPoker::CardSet->new( 'Kd', 'Kc', 'Ks', '2h', '2c', '2h', 'Qd' );
ok( $quad->strength->is_fullhouse, '222KK is fullhouse', );

## ---------- Testing straight -----------------------

my $straight = VPoker::CardSet->new( 'Ad', '2d', '3c', '5h', '4s', '3s' );
ok( $straight->strength->is_straight, 'A2345 is straight', );
ok( $straight->strength->high->is('5'), 'A2345 is 5 high straight', );

$straight = VPoker::CardSet->new( 'Ad', 'Kd', 'Jc', 'Qh', 'Ts', 'Qs' );
ok( $straight->strength->is_straight, 'TJQKA is straight', );
ok( $straight->strength->high->is('A'), 'TJQKA is A high straight', );

$straight = VPoker::CardSet->new( '9c', 'Kd', 'Jc', 'Qh', 'Ts', '7s' );
ok( $straight->strength->is_straight, '9TJQK is straight', );
ok( $straight->strength->high->is('K'), '9TJQK is K high straight', );

$straight = VPoker::CardSet->new( '9c', '8h', 'Jc', 'Kh', 'Ts', '7s' );
ok( $straight->strength->is_straight, '789TJ is straight', );
ok( $straight->strength->high->is('J'), '789TJ is J high straight', );
## ---------- Testing Trip --------------------------
my $trip = VPoker::CardSet->new( 'Ad', 'Ac', 'Ah', '5h', '4s', '7s' );
ok( $trip->strength->is_trip,          'AAA is trip', );
ok( $trip->strength->kicker->is(7),    'kicker is 7', );
ok( $trip->strength->kicker(2)->is(5), 'second kicker is 5', );
## ---------- Testing Two pair --------------------------
my $twoPairs = VPoker::CardSet->new( 'Kd', 'Kc', 'Ah', '5h', '5s', '7s' );
ok( $twoPairs->strength->is_two_pairs, 'KK55 is two pair', );

ok( $twoPairs->strength->kicker->is('A'), 'kicker is A', );

## -----------------------------------------------------
my $pair = VPoker::CardSet->new( 'Ad', 'Ac', 'Th', '8h', '5s', '7s' );
ok( $pair->strength->is_pair, 'AA is one pair', );

ok( $pair->strength->kicker->is('T'), 'kicker is T', );

## -------- Testing High Cards --------------------------
my $nothing = VPoker::CardSet->new( 'Ad', 'Kc', 'Th', '8h', '5s', '7s' );
ok( $nothing->strength->isa('VPoker::HandRank::HighCards'), 'is nothing', );

## -------- Test flush draw -----------------------------
my $flushDraw = VPoker::CardSet->new( 'Ad', 'Kd', '2d', '3d', 'Qs' );
ok( $flushDraw->has_flush_draw, 'has flush draw', );

## ------------------------------------------------------
my $straightDrawSet = VPoker::CardSet->new( 'Jh', 'Th', '9d', 'Qs', '2c' );
ok(
    my $straightDraw = $straightDrawSet->has_straight_draw,
    'has straight draw',
);

ok(
    $straightDraw->has( '9', 'T', 'J', 'Q' ) && $straightDraw->size == 4,
    'correct straight draw identification',
);

ok( $straightDraw->is_open_ended, 'straightDraw is open ended', );

$straightDrawSet = VPoker::CardSet->new( 'Kh', 'Th', '9d', 'Qs', '2c' );
ok(
    my $gutStraightDraw = $straightDrawSet->has_straight_draw,
    'has straight draw',
);

ok(
    $gutStraightDraw->has( '9', 'T', 'K', 'Q' ) && $gutStraightDraw->size == 4,
    'correct gut shot straight draw identification',
);

ok( $gutStraightDraw->is_gut_shot, 'straightDraw is gut shot', );

$straightDrawSet = VPoker::CardSet->new( 'Kh', 'Th', '9d', 'Js', '7c' );
ok(
    my $bustedBellyStraightDraw = $straightDrawSet->has_straight_draw,
    'has straight draw',
);

ok(
    $bustedBellyStraightDraw->has( '9', 'T', 'K', 'J', '7' )
      && $bustedBellyStraightDraw->size == 5,
    'correct busted belly straight draw identification',
);

ok( $bustedBellyStraightDraw->is_busted_belly, 'straightDraw is busted belly',
);

$straightDrawSet = VPoker::CardSet->new( 'Kh', 'Th', '9d', 'Qs', '7c', '6s' );
ok(
    $bustedBellyStraightDraw = $straightDrawSet->has_straight_draw,
    'has straight draw',
);

ok(
    $bustedBellyStraightDraw->has( '9', 'T', 'K', 'Q', '7', '6' )
      && $bustedBellyStraightDraw->size == 6,
    'correct busted belly 6 straight draw identification',
);

ok(
    $bustedBellyStraightDraw->is_busted_belly,
    'straightDraw is busted belly 6',
);

$straightDrawSet = VPoker::CardSet->new( 'Ah', '2h', '3d', '3s', '4c', '7s' );
ok( $straightDraw = $straightDrawSet->has_straight_draw, 'has straight draw', );

ok(
    $straightDraw->has( 'A', '2', '3', '4' ) && $straightDraw->size == 4,
    'correct straight draw identification',
);

ok( $straightDraw->is_gut_shot, 'straightDraw is gut shot', );
