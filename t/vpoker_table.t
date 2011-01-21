use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 6;
use_ok('VPoker::Table');
use_ok('VPoker::Holdem::Player');
use_ok('VPoker::Chair');

ok( my $table = VPoker::Table->new, 'create new table' );
my $firstHand = $table->new_hand;
ok( $table->current_hand->isa('VPoker::Holdem::Hand'), 'create new hand' );
ok( $firstHand == $table->current_hand, 'new_hand return a Hand object' );

