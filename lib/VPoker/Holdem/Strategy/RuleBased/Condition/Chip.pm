package VPoker::Holdem::Strategy::RuleBased::Condition::Chip;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Pattern);

use VPoker::ChipEvaluator;

sub evaluator {
    my $self = shift;
    return VPoker::ChipEvaluator->new(table => $self->strategy->table);
}
## ----------------------------------------------------------------------------
## is asbtract class for any condition on chip
## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;
    return
        $self->validator->is_chip_amount($value)
        || $self->SUPER::_validate($value)
    ;
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;
    return $self->evaluator->evaluate($value) if $self->validator->is_chip_amount($value);
    return $self->SUPER::_check($value);
}


sub _build_patterns {
    my $self = shift;
    $self->add_patterns(
        '$greater|less$ than[opt] $chip$' => sub {
            my ($self, $compare, $than, $chip) = shift;
            return $self->_check_compare($compare, $chip);
        },
        'between $int$ and[opt] $chip$' => sub {
            my ($self, $firstValue, $and, $secondValue) = @_;
            my @values = (
                $self->evaluator->evaluate($firstValue),
                $self->evaluator->evaluate($secondValue)
            );
            my ($smallerValue, $biggerValue) = sort @values;
            return
                $self->condition_value >= $smallerValue &&
                $self->condition_value <= $biggerValue;
        },
        '$>|<|>=|<=$ $chip$' => sub {
            my $self = shift;
            return $self->_check_compare(@_);
        },
    );
}

## ----------------------------------------------------------------------------
sub _check_compare {
    my ($self, $compare, $value) = @_;
    $compare = '>' if $compare eq 'greater';
    $compare = '<' if $compare eq 'less';

    my $conditionValue = $self->condition_value;
    $value             = $self->evaluator->evaluate($value);
    my $expression = "$conditionValue $compare $value";
    return eval $expression;
}

## ----------------------------------------------------------------------------
sub condition_value {
    die('child class must implement this method');
}

1;
