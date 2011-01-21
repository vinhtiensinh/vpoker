use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 12;
use_ok('VPoker::Base');

package AutoLoadTest;
use base qw(VPoker::Base);
    __PACKAGE__->has_attributes('value_1');
    sub is_true {
        return 1;
    }

    sub is_false {
        return 0;       
    }

    sub true {
        return 1;
    }
    sub false {
        return 0;
    }

    sub is_value_1 {
        my ($self, $value) = @_;
        return $self->value_1 eq $value;
    }

package main;

my $autoload_tester = AutoLoadTest->new;
$autoload_tester->value_1("correct");
ok(!$autoload_tester->is_not_true, 'not at middle of positive method');
ok(!$autoload_tester->is_no_true, 'no at middle of negative method');
ok($autoload_tester->is_not_false, 'not at middle of negative method');
ok($autoload_tester->is_no_false, 'no at middle of negative method');
ok(!$autoload_tester->no_true, 'no at the start of the method');
ok(!$autoload_tester->not_true, 'not at the start of the method');
ok($autoload_tester->no_false, 'no at the start of the negative method');
ok($autoload_tester->not_false, 'not at the start of the negative method');
ok(!$autoload_tester->true_not, 'not at the end of the positive method');
ok($autoload_tester->false_not, 'not at the end of the negative method');
ok($autoload_tester->is_not_value_1('not correct'), 'passing the parameter ok');

