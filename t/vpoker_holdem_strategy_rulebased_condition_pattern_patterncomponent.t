use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 3;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::PatternComponent');
ok(
    my $component = VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::PatternComponent->new(
        type => 'number',
    )
);

ok(
    $component->match(3),
    'number component match 3',
);