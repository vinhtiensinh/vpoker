use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 8;
use VPoker::Holdem::Player;
use VPoker::Holdem::Hand;
use VPoker::Table;

my $vinhking = VPoker::Holdem::Player->new( name => 'vinhking', balance => 100 );
my $bettowin = VPoker::Holdem::Player->new( name => 'bettowin', balance => 100 );
my $pokerstars =
  VPoker::Holdem::Player->new( name => 'pokerstar', balance => 100 );
my $fulltilt = VPoker::Holdem::Player->new( name => 'fulltilt', balance => 100 );

my $table = VPoker::Table->new;

$vinhking->join($table, 1); 
$bettowin->join($table, 2);
$pokerstars->join($table, 3);
$fulltilt->join($table, 4);

_new_hand(
    dealer_chair      => $table->chair(1),
    small_blind_chair => $table->chair(2),
    big_blind_chair   => $table->chair(3),
    small_blind       => 1,
    big_blind         => 2,
);

$bettowin->post(1);
$pokerstars->post(2);

is(
    $table->current_hand->bet_round->action_round,
    1,
    'beginning, action round is 1',
);

$fulltilt->bet(6);
is(
    $table->current_hand->bet_round->action_round,
    1,
    'on button - action round is 1',
);

$vinhking->fold;
is(
    $table->current_hand->bet_round->action_round,
    1,
    'on small blind - action round is 1',
);

$bettowin->call(6);
is(
    $table->current_hand->bet_round->action_round,
    1,
    'on big blind - action round is 1',
);

$pokerstars->raise(12);
is(
    $table->current_hand->bet_round->action_round,
    2,
    'a player reraise - bet round should be 2',
);

is(
    scalar $table->current_hand->bet_round->active_callers,
    1,
    'there is one caller',
);

$fulltilt->call;

is(
    scalar $table->current_hand->bet_round->active_callers,
    2,
    'there is 2 caller after fulltilt call',
);

$bettowin->fold;

is(
    scalar $table->current_hand->bet_round->active_callers,
    1,
    'there is 1 caller after bettowin fold',
);


sub _new_hand {
    my (%args) = @_;

    $table->chair(1)->in_play(1);
    $table->chair(2)->in_play(1);
    $table->chair(3)->in_play(1);
    $table->chair(4)->in_play(1);
    $table->new_hand;

    $table->current_hand->init(%args);
}

