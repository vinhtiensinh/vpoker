package VPoker::Test::DB;

use strict;
use warnings;

use Test::MockModule;

sub setup_db_data {
  my %data = @_ ;

  my $mockDB = new Test::MockModule('VPoker::DB');

  $mockDB->mock('get_doc', sub {
      my ($self, $name) = @_;
      return $data{$name};
  });

  return $mockDB;
}

1;
