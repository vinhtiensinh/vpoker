package VPoker::Holdem::Strategy::RuleBased::DSL::Yaml;
use strict;
use warnings;
use YAML;

use VPoker::Holdem::Strategy::RuleBased::RuleTable qw();
use VPoker::Holdem::Strategy::RuleBased::Rule qw();
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory qw();

sub create {
    my ($self, $strategy, $string) = @_;
    print $string;
    my ($yaml, $arrayref, $yaml_string) = Load($string);
    my $rule_table = $self->_create($strategy, $yaml);
    return $rule_table;
}

sub _create {
    my ($self, $strategy, $yaml) = @_;
    if (ref($yaml) eq 'ARRAY') {
        my $rule_table = VPoker::Holdem::Strategy::RuleBased::RuleTable->new();
        foreach my $rule (@$yaml) {
            my @keys = keys %$rule;
            my $conditions = pop @keys;
            my $action     = $rule->{$conditions};

            my $rule  = VPoker::Holdem::Strategy::RuleBased::Rule->new(
                conditions => $self->parse_conditions($conditions, $strategy),
                action => $action,
                strategy => $strategy,
            );

            $rule_table->new_rule($rule);
        }
        return $rule_table;
    }

    sub parse_conditions {
        my ($self, $string, $strategy) = @_;
        my @conditions_string = split('\|', $string);
        my $conditions = [];
        foreach my $condition (@conditions_string) {
            my($condition_name, $condition_value) = split('\.', $condition);
            $condition = VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(
                'name'     => lc($self->clean_up_whitespace($condition_name)),
                'value'    => $self->parse_condition_values(
                                  lc($self->clean_up_whitespace($condition_value))),
                'strategy' => $strategy,
            );
            push @$conditions, $condition;
        }

        return $conditions;
    }

    sub parse_condition_values {
        my ($self, $string) = @_;
        if ($string =~ /;/) {
            my $normalise_values = [];
            my @values = split(';', $string);
            foreach my $value (@values) {
                push @$normalise_values, $self->clean_up_whitespace($value);
            }

            return $normalise_values;
        }
        else {
            return $string;
        }
    }

    sub clean_up_whitespace {
        my ($self, $string) = @_;
        $string =~ s/^\s+//g;
        $string =~ s/\s+$//g;
        $string =~ s/\s+$/ /g;
        return $string;
    }
}

1;
