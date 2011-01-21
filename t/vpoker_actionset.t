use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 13;

use_ok('VPoker::Action');
use_ok('VPoker::ActionSet');
use_ok('VPoker::Holdem::Player');
ok( my $actionSet = VPoker::ActionSet->new, 'create action set object', );

my $player1 = VPoker::Holdem::Player->new( name => 'vinhtiensinh' );
my $player2 = VPoker::Holdem::Player->new( name => 'bettowin' );

ok(
    $actionSet->add(
        VPoker::Action->new(
            player   => $player1,
            'action' => 'bet',
            'amount' => 10
        )
    ),
    'add new action ok',
);
is( $actionSet->total, 1, 'only one action in set' );

my $actionSet2 = VPoker::ActionSet->new;
$actionSet2->add(
    VPoker::Action->new(
        player   => $player2,
        'action' => 'raise',
    )
);
$actionSet2->add(
    VPoker::Action->new(
        player => $player1,
        action => 'call'
    )
);

is( $actionSet2->total, 2, 'two actions in set 2' );
ok( $actionSet->add($actionSet2), 'add 2 into 1' );
is( $actionSet->total, 3, 'now 1 have 3 actions' );

ok(
    $actionSet->action(2)->player->name eq 'bettowin'
      && $actionSet->action(2)->is_raise,
    'the 2nd action is p layer bettowin raise',
);
ok( my $player1Actions = $actionSet->player_actions($player1),
    'get player1 actions' );
ok(
    $player1Actions->action(1)->is_bet
      && $player1Actions->action(1)->player->name eq 'vinhtiensinh'
      && $player1Actions->action(2)->is_call
      && $player1Actions->action(2)->player->name eq 'vinhtiensinh',
    'get player actions correctly',
);

is( scalar $actionSet->raises, 2, 'there are 2 raise (one bet and one raise)',
);

