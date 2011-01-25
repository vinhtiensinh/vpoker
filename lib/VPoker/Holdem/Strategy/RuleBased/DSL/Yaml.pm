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

    my $rule_table = $self->_create_rule_table($strategy, $yaml);
    return $rule_table;
}

sub _create_rule_table {
    my ($self, $strategy, $yaml) = @_;

    if (ref($yaml) eq 'ARRAY') {
        my $rule_table = VPoker::Holdem::Strategy::RuleBased::RuleTable->new();
        foreach my $rule (@$yaml) {
            unless (ref($rule)) {
                $rule_table->add_order_of_execution($rule);
                next;
            }

            if (ref($rule) eq 'HASH') {
                while (my ($key, $value) = each(%$rule)) {

                    if ($key =~ /\./) {
                      $rule_table->new_rule($self->_create_rule($strategy, $key, $value));
                    }
                    else {
                      $rule_table->new_named_rule($key, $self->_create_action($strategy,$value));
                    }
                }
            }
        }
        return $rule_table;
    }
    elsif (ref($yaml) eq 'HASH') {

        my $rule_table = undef;

        if ($yaml->{'use'}) {
            $rule_table = $self->_create_rule_table($strategy, $yaml->{'use'});
        }

        if ($yaml->{'rules'}) {
            $rule_table = $self->_create_rule_table($strategy, $yaml->{'rules'});
        }

        if ($yaml->{'with'}) {
            while (my ($key, $value) = each(%{$yaml->{'with'}})) {
                if ($key =~ /\./) {
                  my $rule = $self->_create_rule($strategy, $key, $value);
                  $rule_table->new_named_rule(
                      $rule->stringify_conditions, $rule
                  );
                }
                else {
                  $rule_table->new_named_rule($key, $self->_create_action($strategy,$value));
                }
            }
        }
        return $rule_table;
    }

    sub _create_action {
        my ($self, $strategy, $action) = @_;
        if (!ref($action)) {
            return VPoker::Holdem::Strategy::RuleBased::Action->new(action => $action);
        }
        else {
            return $self->_create_rule_table($strategy, $action);
        }
    }

    sub _create_rule {
        my ($self, $strategy, $conditions, $action) = @_;

        return VPoker::Holdem::Strategy::RuleBased::Rule->new(
            conditions => $self->parse_conditions($conditions, $strategy),
            action => $self->_create_action($strategy, $action),
            strategy => $strategy,
        );
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
                                  $self->clean_up_whitespace($condition_value)),
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
