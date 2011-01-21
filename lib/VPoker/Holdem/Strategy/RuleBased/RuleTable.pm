package VPoker::Holdem::Strategy::RuleBased::RuleTable;

use base qw(VPoker::Holdem::Strategy::RuleBased::Action);
use VPoker::Holdem::Strategy::RuleBased::Rule;

__PACKAGE__->has_attributes('rules');

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    my $ruleTable = delete $args{'ruleTable'};
    $self->init(%args);

    if($ruleTable) {
        $self->_parse($ruleTable);
    }

    return $self;
}

sub add_rule {
    my ($self, $rule) = @_;
    $self->rules([]) unless $self->rules;

    push @{$self->rules}, $rule;
}

sub apply {
    my $self = shift;

    foreach my $rule (@{ $self->rules }) {
        return $rule->apply if ($rule->is_satisfied);
    }
    ## Default check or fold
    return $self->strategy->check_or_fold;
}

sub _parse {
    my ($self, $ruleTable) = @_;
    my $conditions = $ruleTable->[0];
    my $rules = [];


    for (my $rowIdx = 1; $rowIdx < scalar @$ruleTable; $rowIdx++) {
        my $values = $ruleTable->[$rowIdx];
        my %ruleArgs = (
            conditions => {},
            strategy   => $self->strategy,
        );
        for (my $columnIdx = 0; $columnIdx < scalar @$conditions; $columnIdx++) {
            my ($condition, $value) =
                ($conditions->[$columnIdx], $values->[$columnIdx]);

            next if $self->_no_value($value);
            $condition = lc($condition);

            if($self->_is_last_rule_value($value)) {
                $values->[$columnIdx] = $ruleTable->[$rowIdx - 1]->[$columnIdx];
                $value = $ruleTable->[$rowIdx - 1]->[$columnIdx];
            }

            if($condition eq 'name') {
                $ruleArgs{'name'} = $value;
            }
            elsif($condition eq 'description') {
                $ruleArgs{'description'} = $value;
            }
            elsif($condition eq 'action') {
                $ruleArgs{'action'} = $value;
            }
            else {
                $ruleArgs{'conditions'}->{$condition} = $value;
            }
        }

        push @$rules, VPoker::Holdem::Strategy::RuleBased::Rule->new(%ruleArgs);
    }

    $self->rules($rules);
}

sub _no_value {
    my ($self, $value) = @_;
    return (not defined $value) || ($value =~ m|^\s*$|);
}

sub _is_last_rule_value {
    my ($self, $value) = @_;
    return $value =~ m|^\s*\^\s*$|;
}

sub is_satisfied {
    my $self = shift;
    foreach my $rule (@{ $self->rules }) {
      return $self->TRUE if ($rule->is_satisfied);
    }
    return $self->FALSE;
}

sub validate {
  my $self = shift;
  foreach my $rule (@{$self->rules}) {
    $rule->validate;
  }
}

1;
