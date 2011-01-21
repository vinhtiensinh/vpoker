use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 10;
use_ok('VPoker::Base');

VPoker::Base->has_attributes( 'attribute1', 'attribute2' );
ok(
    my $base = VPoker::Base->new(
        'attribute1' => 'attr1Value',
        'attribute2' => 'attr2Value',
    ),
    'sub new',
);

ok( $base->attribute1 eq 'attr1Value', 'attribute 1 value', );

ok( $base->attribute2 eq 'attr2Value', 'attribute 2 value', );

VPoker::Base->alias( 'attribute1', 'attribute1_alias' );
ok( $base->can('attribute1_alias'), 'set alias attribute1 attribute1_alias' );
is( $base->attribute1_alias, $base->attribute1,
    'alias attribute1_alias works' );

package TestDelegate;
use base ('VPoker::Base');
__PACKAGE__->has_attributes('VPokerBase');
__PACKAGE__->delegate( 'vpoker_base_attr1', [ 'VPokerBase', 'attribute1' ] );

package main;
my $testDelegate = TestDelegate->new(
    'VPokerBase' => VPoker::Base->new( 'attribute1' => 'attr1Value' ) );

ok(
    $testDelegate->VPokerBase->isa('VPoker::Base'),
    'Delegate has correct attribute',
);

is(
    $testDelegate->VPokerBase->attribute1,
    'attr1Value', 'Attribute 1 value ok',
);
ok( $testDelegate->can('vpoker_base_attr1'), 'delegate method defined', );

is(
    $testDelegate->vpoker_base_attr1,
    'attr1Value', 'Delegate method return correct value',
);
