package VPoker::Holdem::Strategy::RuleBased::DSL::Yaml;
use strict;
use warnings;
use YAML;

use VPoker::Holdem::Strategy::RuleBased::RuleTable qw();
use VPoker::Holdem::Strategy::RuleBased::Rule qw();
use VPoker::Holdem::Strategy::RuleBased::ConditionFactory qw();
use File::Basename;
use File::Spec;


sub strategy {
    my ($self, $strategy, $path) = @_;
    my @files = $self->load_all_files_recursively($path);
    foreach my $file (@files) {
      $self->load_file($strategy, $file);
    }
}
sub load_all_files_recursively {
    my ($self, $path) = @_;
    my @files = ();
    opendir DIR, $path;

    my @dir_files = readdir DIR;
    foreach my $file (@dir_files) {
        next if ($file eq '.') or ($file eq '..');
        my $full_path = File::Spec->catfile($path, $file);
        push @files, $full_path if $self->is_yaml_vpk_file($full_path);
        push @files, $self->load_all_files_recursively($full_path) if $self->is_dir($full_path);
    }
    close DIR;

    return @files;
}

sub is_yaml_vpk_file {
    my ($self, $path) = @_;
    return (-f $path and $path =~/\.yaml\.vpk$/);
}

sub is_dir {
    my ($self, $path) = @_;
    return (-d $path);
}

sub load_file {
    my ($self, $strategy, $file) = @_;
    my $rule_table;

    eval {
        my ($name, $directories, $suffix) = File::Basename::fileparse($file);
        $name =~ s/\.yaml\.vpk$//;
        my $string = $self->read_file($file, $name);
        $rule_table = $self->create($strategy, $string);
        $strategy->decision($name, $rule_table);

        if ($name !~ /^_/) {

            foreach my $key (keys %{$rule_table->ruleset}) {
                $rule_table->ruleset($key);
                $strategy->decision(sprintf("%s->%s", $name, $key), $rule_table->ruleset($key));
            }
        }
    };

    if ($@) {
        die("Failed to load $file \n $@");
    }

    return $rule_table;
}

sub read_file {
    my ($self, $file, $name) = @_;
    open FILE, "$file" or die "Couldn't open file: $!"; 
    my @lines = ();
    while(my $line = <FILE>) {
        next if $line =~ /^\s*#/;
        $line =~ s/#.*\n/\n/;
        push @lines, $line;
    }
    my $string = join("", @lines); 
    close FILE;

    my $local_replacement = "$name->";
    $string =~ s/\~/$local_replacement/g;

    return $string;
}

sub create {
    my ($self, $strategy, $string) = @_;
    my ($yaml, $arrayref, $yaml_string) = Load($string);

    my $rule_table = $self->_create_rule_table($strategy, $yaml);
    return $rule_table;
}

sub _create_rule_table {
    my ($self, $strategy, $yaml) = @_;

    if (ref($yaml) eq 'ARRAY') {
        my $rule_table = VPoker::Holdem::Strategy::RuleBased::RuleTable->new(strategy => $strategy);
        $self->_populate_strategy_rules($rule_table, $strategy, $yaml);
        return $rule_table;
    }
    elsif (ref($yaml) eq 'HASH') {

        my $rule_table = undef;

        if ($yaml->{'use'}) {
            $rule_table = $self->_create_rule_table($strategy, $yaml->{'use'});
        }

        if ($yaml->{'rules'}) {
            if ($rule_table) {
                $self->_populate_strategy_rules($rule_table, $strategy, $yaml->{'rules'});
            }
            else {
                $rule_table = $self->_create_rule_table($strategy, $yaml->{'rules'});
            }
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

    sub _populate_strategy_rules {
        my ($self, $rule_table, $strategy, $yaml) = @_;

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

    }

    sub _create_action {
        my ($self, $strategy, $action) = @_;
        if (!ref($action)) {
            return VPoker::Holdem::Strategy::RuleBased::Action->new(
                action => $action, strategy => $strategy
            );
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
        my ($self, $string, $valueset) = @_;
        if ($string =~ /;/) {
            my $normalise_values = [];
            my @values = split(';', $string);
            foreach my $value (@values) {
                push @$normalise_values, $self->parse_condition_values($value, $normalise_values);
            }

            return $normalise_values;
        }
        elsif ($string =~ /\&/) {
            my $normalise_values = [];
            my @values = split('\&', $string);
            foreach my $value (@values) {
                push @$normalise_values, $self->parse_condition_values($value);
            }

            if (defined $valueset) {
              return $normalise_values;
            }
            else {
                return [$normalise_values];
            }
        }
        else {
            return $self->clean_up_whitespace($string);
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
