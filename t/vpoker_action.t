use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 11;
use_ok('VPoker::Action');
use_ok('VPoker::Holdem::Player');

ok(
    my $fold = VPoker::Action->new_fold(
        player => VPoker::Holdem::Player->new( name => 'vinhking' ),
    ),
    'new fold action',
);

ok( $fold->is_fold, 'action is fold' );
is( $fold->player->name, 'vinhking', 'player is correct' );

my $check = VPoker::Action->new_check;
ok( $check->is_check, 'check action is check' );
my $call = VPoker::Action->new_call;
ok( $call->is_call, 'call action is call' );
my $bet = VPoker::Action->new_bet(
    player => VPoker::Holdem::Player->new( name => 'vinhking' ),
    amount => 10,
);
ok( $bet->is_bet, 'bet action is bet' );
is( $bet->amount, 10, 'bet amount correct' );
ok( $bet->time > time() - 10, 'bet time recored' );
my $raise = VPoker::Action->new_raise;
ok( $raise->is_raise, 'call action is raise' );
