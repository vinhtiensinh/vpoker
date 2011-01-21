use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More tests => 7;
use_ok('VPoker::Chair');
use VPoker::Holdem::Player;

my $chair_1 = VPoker::Chair->new;
my $chair_2 = VPoker::Chair->new;
my $chair_3 = VPoker::Chair->new;


$chair_1->next($chair_2);
$chair_2->previous($chair_1);

$chair_2->next($chair_3);
$chair_3->previous($chair_2);

$chair_3->next($chair_1);
$chair_1->previous($chair_3);

ok($chair_1->is_empty, "is_empty check ok");
$chair_1->player(VPoker::Holdem::Player->new);
ok($chair_1->is_not_empty, "is not empty check ok");

$chair_2->in_play(1);
ok($chair_1->next_playing == $chair_2, "next playing chair is next chair");
ok($chair_3->next_playing == $chair_2, "next playing chair skipping not playing chair in the middle");

$chair_1->in_play(1);
ok($chair_1->previous_playing == $chair_2, "previous playing chair, skipping not playing chair in the middle");
ok($chair_2->previous_playing == $chair_1, "previous playing chair is chair just previous");
