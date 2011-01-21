package VPoker::Holdem::Strategy::RuleBased::Condition::Integer;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Pattern);

use VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern;
## ----------------------------------------------------------------------------
## Condition::Integer is asbtract class for any condition on integer
##
## accepted values are:
##     integers
##     greater <integer>            # e.g greater 3
##     less    <integer>            # e.g less    2
##     between <interger> <integer> # e.g between 3 5 (inclusive 3, 4, 5)
##
## subclass should provide one abstract method sub condition_value
## which is the value from the poker game that should be compare against
## for example position or number of raise action, etc
## ----------------------------------------------------------------------------


## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;

    return $self->SUPER::_validate($value) || $self->validator->is_int($value);
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;

    return $self->condition_value == $value if ($self->validator->is_int($value));
    return $self->SUPER::_check($value);
}

## ----------------------------------------------------------------------------
sub condition_value {
    die('child class must implement this method');
}

## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        '$greater|less$ than[opt] $int$' => sub {
            my ($self, $compare, $than, $value) = @_;
            return $self->_check_compare($compare, $value);
        },

        'between $int$ and[opt] $int$' => sub {
            my ($self, $firstValue, $and, $secondValue) = @_;
            my ($smallerValue, $biggerValue) = sort ($firstValue, $secondValue);
            return
                $self->condition_value >= $smallerValue &&
                $self->condition_value <= $biggerValue;
        },

        '$>|<|>=|<=$ $int$' => sub {
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
    my $expression = "$conditionValue $compare $value";
    return eval $expression;
}


1;
