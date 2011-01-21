use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 7;

use_ok('VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern');
my $patternText = '>|greater $number$';
ok(
    my $pattern = VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern->new(
        $patternText
    ),
    'create pattern ok',
);

ok(
    $pattern->match('> 3'),
    "pattern $patternText " . 'match "> 3"',
);

ok(
    $pattern->match('greater 5'),
    "pattern $patternText " . 'match greater 5"',
);

$patternText = '$>|greater|<|less|>=|<=$ $number$';
ok(
    $pattern = VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern->new(
        $patternText
    ),
    'create pattern ok',
);

ok(
    $pattern->match('>= 3'),
    "pattern $patternText " . 'match ">= 3"',
);

ok(
    $pattern->match('<= 5'),
    "pattern $patternText " . '<= 5"',
);