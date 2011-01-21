use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 12;
use VPoker::Table;
use VPoker::Holdem::Player;
use VPoker::Chair;

use_ok('VPoker::ChipEvaluator');


my $table = VPoker::Table->new;
my $player1 = VPoker::Holdem::Player->new(
    name    => 'vinhtiensinh',
    balance => 100,
);
my $player2 = VPoker::Holdem::Player->new(
    name    => 'bettowin',
    balance => 200,
);
my $player3 = VPoker::Holdem::Player->new(
    name    => 'partypoker',
    balance => 300,
);
my $player4 = VPoker::Holdem::Player->new(
    name    => 'fulltilt',
    balance => 400,
);

$player1->join($table, 0);
$player2->join($table, 1);
$player3->join($table, 3);
$player4->join($table, 9);

my $currentHand = $table->new_hand;
$currentHand->small_blind(1);
$currentHand->big_blind(2);

ok(my $chipValuator = VPoker::ChipEvaluator->new(table => $table), 'create a chip evaluator');
is($chipValuator->evaluate('bb'),  2, 'evaluate bb correctly');
is($chipValuator->evaluate('2bb'), 4, 'evaluate 2bb correctly');
is($chipValuator->evaluate('50% bb'), 1, 'evaluate 50% bb correctly');

$player1->bet(6);
$player2->call;
$player3->fold;
$player4->call;

is($chipValuator->evaluate('pot'),  18, 'evaluate pot correctly');
is($chipValuator->evaluate('balance0'),  94, 'evaluate balance0 player1 correctly');
is($chipValuator->evaluate('balance2'),  0, 'evaluate balance2 no player correctly');
is($chipValuator->evaluate('bet1'),  6, 'evaluate bet1 correctly');
is($chipValuator->evaluate('bet1 + pot'),  24, 'evaluate bet1+pot correctly');
is($chipValuator->evaluate('bet1 + 2/3pot'),  18, 'evaluate bet1+pot correctly');
is($chipValuator->evaluate('bet1 + 50%pot'),  15, 'evaluate bet1+50%pot correctly');


