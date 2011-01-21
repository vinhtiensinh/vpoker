use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 19;
use VPoker::Card;
use_ok('VPoker::HandRank::StraightDraw');
ok(
    my $openEndedDraw = VPoker::HandRank::StraightDraw->new(
        VPoker::Card->new('Td'), VPoker::Card->new('9c'),
        VPoker::Card->new('8s'), VPoker::Card->new('7c'),
    ),
    'initial open ended straight draw card object array',
);

ok( $openEndedDraw->is_open_ended, 'is open ended', );

ok( !$openEndedDraw->is_busted_belly, 'is not busted belly', );

ok(
    $openEndedDraw->complete_cards->has(
        '6c', '6d', '6s', '6h', 'Jc', 'Jd', 'Js', 'Jh'
    ),
    'complete card has all 6, and all J',
);

##-----------------------------------------------------------------------------
ok(
    my $gutShotDraw =
      VPoker::HandRank::StraightDraw->new( 'Ad', 'Kc', 'Qs', 'Tc', ),
    'initial gut shot straight draw card card face',
);

ok( !$gutShotDraw->is_open_ended, 'gut shot is not open ended', );

ok( $gutShotDraw->is_gut_shot, 'is gut shot draw', );

ok(
    $gutShotDraw->complete_cards->has( 'Js', 'Jd', 'Jc', 'Jh' ),
    'to complete gut shot need one of the Jacks',
);

## ----------------------------------------------------------------------------

ok(
    my $bustedBellyDraw =
      VPoker::HandRank::StraightDraw->new( 'Ad', 'Qs', 'Jc', 'Tc', '8d', ),
    'initial busted belly straight draw card card face',
);

ok( !$bustedBellyDraw->is_open_ended, 'busted belly is not open ended', );

ok( !$bustedBellyDraw->is_gut_shot, 'busted belly is not gut shot', );

ok( $bustedBellyDraw->is_busted_belly, 'is busted belly draw', );

ok(
    $bustedBellyDraw->complete_cards->has(
        'Ks', 'Kd', 'Kc', 'Kh', '9s', '9d', '9c', '9h'
    ),
    'to complete busted belly need one of the Kings or 9s',
);

ok(
    my $bustedBelly6CardsDraw =
      VPoker::HandRank::StraightDraw->new( 'Ad', 'Ks', 'Jc', 'Tc', '8d', '7d' ),
    'initial busted belly 6 straight draw card card face',
);

ok( !$bustedBelly6CardsDraw->is_open_ended, 'busted belly is not open ended', );

ok( !$bustedBelly6CardsDraw->is_gut_shot, 'busted belly 6 is not gut shot', );

ok( $bustedBelly6CardsDraw->is_busted_belly, 'is busted belly draw', );

ok(
    $bustedBelly6CardsDraw->complete_cards->has(
        'Qs', 'Qd', 'Qc', 'Qh', '9s', '9d', '9c', '9h'
    ),
    'to complete busted belly 6 need one of the Kings or 9s',
);
