package VPoker::Holdem::Strategy::RuleBased;
use base qw(VPoker::Holdem::Strategy);
use strict;
use warnings;
use diagnostics;

use VPoker::Holdem::Strategy::RuleBased::RuleTable;

__PACKAGE__->has_attributes('decisions', 'applied_rules');

sub play {
    my $self = shift;

    if($self->decision('master')) {
        return $self->decision('master')->apply;
    }
    die('Need to provide master decision table');
}

sub decision {
    my ($self, $decision, $ruleTable) = @_;
    $self->decisions({}) unless $self->decisions;
    if ($ruleTable) {
        if ($self->global($decision)) {
            foreach my $rule (@{$ruleTable->rules}) {
                die ("global strategy '$decision' has rule without name") unless $rule->name;
                $self->decision($rule->name, $rule);
            }
        }
        $self->decisions->{$decision} = $ruleTable
    }
    return $self->decisions->{$decision};
}

sub global {
    my ($self, $name) = @_;
    return $name =~ /^_/ && $name !~ /\./;
}

sub last_applied_rule {
    my $self = shift;
    return ( $self->appliedRules )[-1];
}

sub add_applied_rule {
    my ($self, $rule) = @_;
    $self->applied_rules([]) unless $self->applied_rules;

    push @{ $self->applied_rules }, $rule;
}

sub all_rule_tables {
    my $self = shift;
    return values %{$self->decisions};
}

sub decisions_from_db {

  my ($self, $docid, $isMaster) = @_;

  my $ruleTable = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
      'database' => $docid, 
      'strategy' => $self,
  );

  if($isMaster) {
      $self->decision('master', $ruleTable);
  }
  else {
      $self->decision($docid, $ruleTable);
  }

  foreach my $rule (@{ $ruleTable->rules }) {
    if ($rule->{'action'} =~ /apply\s+(.*)/) {
      my $subTableId = $1;
      unless (exists $self->decisions->{$subTableId}) {
          $self->decisions_from_db($subTableId);
      }
    }
  }
}

sub validate {
  my ($self) = @_;
  foreach my $ruleTable ($self->all_rule_tables) {
    $ruleTable->validate;
  }
}


1;
