package VPoker::Holdem::Strategy::RuleBased::RuleTable;

use base qw(VPoker::Holdem::Strategy::RuleBased::Action);
use VPoker::Holdem::Strategy::RuleBased::Rule;

__PACKAGE__->has_attributes('order_of_execution', 'ruleset');

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


sub rules {
    my ($self) = @_;
    my $rules = [];
    foreach my $rule_id (@{$self->order_of_execution}) {
        push @$rules, $self->ruleset->{$rule_id};

    }

    return $rules;
}

sub new_rule {
    my ($self, $rule) = @_;
    $self->order_of_execution([]) unless $self->order_of_execution;
    $self->ruleset({}) unless $self->ruleset;


    my $rule_id = '';

    if ($rule->isa('VPoker::Holdem::Strategy::RuleBased::Rule')) {
        $rule_id = $rule->name || $rule->stringify_conditions;
    }
    else {
        $rule_id = $rule->name;
    }

    unless ($rule_id) {
        if (exists $self->ruleset->{'anonymous'}) {
            die ('cant have more than 1 anonymous rules inside a rule table');
        }
        else {
            $rule_id = 'anonymous';
        }
    }

    unless (exists $self->ruleset->{$rule_id}) {
        push @{$self->order_of_execution}, $rule_id;
    }
    $self->ruleset->{$rule_id} = $rule;
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
        $self->new_rule(VPoker::Holdem::Strategy::RuleBased::Rule->new(%ruleArgs));
    }
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
