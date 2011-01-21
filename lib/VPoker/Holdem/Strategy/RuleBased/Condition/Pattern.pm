package VPoker::Holdem::Strategy::RuleBased::Condition::Pattern;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition);

use VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern;

__PACKAGE__->has_attributes('patterns', 'pattern_processors');

sub init {
    my ($self, %args) = @_;
    $self->SUPER::init(%args);
    $self->_build_patterns;
}
sub _validate {
    my ($self, $value) = @_;

    foreach my $pattern ( @{ $self->patterns} ) {
        return $self->TRUE if $pattern->match($value);
    }
    return $self->FALSE;
}

sub _check {
    my ($self, $value) = @_;
    foreach my $pattern ( @{$self->patterns} ) {
        if($pattern->match($value)) {
            my @params = $pattern->process($value);

            my $checkMethod = $self->pattern_processors->{$pattern->pattern};
            return $checkMethod->($self, @params);
        }
    }

    $self->SUPER::_check($value);
}

sub add_patterns {
    my ($self, %patterns) = @_;
    $self->patterns([]) unless $self->patterns;
    $self->pattern_processors({}) unless $self->pattern_processors;

    while(my ($patternText, $checkMethod) = each %patterns) {
        $self->pattern_processors->{$patternText} = $checkMethod;
        push
            @{$self->patterns},
            VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern->new($patternText)
        ;
    }
}

sub _build_patterns {
    my $self = shift;
    $self->patterns([]);
}

1;
