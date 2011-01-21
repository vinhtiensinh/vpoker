package VPoker::Holdem::Strategy::RuleBased::Condition::LastRule;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition);

## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;

    foreach my $ruleTable ($self->strategy->all_rule_tables) {
        foreach my $rule (@{$ruleTable->rules}) {
            return $self->TRUE if ($rule->name && $rule->name eq $value);
        }
    }
    return $self->FALSE;
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;
    return (
        $self->strategy->last_applied_rule
        && $self->strategy->last_applied_rule->name
        && $self->strategy->last_applied_rule->name eq $value
    );
}

1;

