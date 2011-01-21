package VPoker::Holdem::Strategy::RuleBased::Condition::CurrentBet;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);

use VPoker::Debugger;

sub condition_value {
    my $self = shift;
    return scalar $self->strategy->bet_round->raise_actions;
}

## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        'amount $>|<|>=|<=$ $chip$' => sub {
            my ($self, $compare, $value) = @_;
            $compare = '>' if $compare eq 'greater';
            $compare = '<' if $compare eq 'less';

            my $conditionValue = $self->strategy->hand_bet;
            $value = $self->strategy->evaluator->evaluate($value);
            my $expression = "$conditionValue $compare $value";
            return eval $expression;
        },

        'amount between $chip$ and[opt] $chip$' => sub {
            my ($self, $firstValue, $and, $secondValue) = @_;
            my ($smallerValue, $biggerValue) = sort ($firstValue, $secondValue);
            return (
                 $self->strategy->hand_bet >=
                   $self->strategy->evaluator->evaluate($smallerValue)
                 && $self->strategy->hand_bet <=
                   $self->strategy->evaluator->evaluate($biggerValue)
            );
        },

        '$nobet|bet|raised|reraised$' => sub {
            my ($self, $text) = @_;
            return $self->_check(0)      if($text eq 'nobet');
            return $self->_check(1)      if($text eq 'bet');
            return $self->_check(2)      if($text eq 'raised');
            return $self->_check('>= 3') if($text eq 'reraised');
        },
    );
}

1;
