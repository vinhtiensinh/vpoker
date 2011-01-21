package VPoker::Holdem::Strategy::RuleBased::Condition;
use base qw(VPoker::Base);
use strict;
use warnings;

use VPoker::Holdem::Strategy::RuleBased::ValueValidator;
use Carp qw(confess);
use VPoker::Debugger;

__PACKAGE__->has_attributes('strategy', 'value', 'name');
## ----------------------------------------------------------------------------
## sub validate asbtract method that need to implemented by child class.
## This class validate the value of the condition.
sub validate {
    my ($self, $value) = @_;
    $value = $value || $self->value;
    
    $value = $self->validator->normalise_value($value);
    if(ref($value) eq 'ARRAY') {
        foreach my $valueItem (@$value) {
            return $self->FALSE unless $self->validate($valueItem);
        }
        return $self->TRUE;
    }
    elsif(ref($value)) {
        confess('Condition value should be array of string');
    }
    else {
        $value = $self->_remove_negative_word($value) if $self->_is_negative($value);
        return $self->_validate($value);
    }
}

## ----------------------------------------------------------------------------
sub is_satisfied {
    my ($self, $value) = @_;
    $value = $self->value unless (defined $value);

    $value = $self->validator->normalise_value($value);
    if (ref($value) eq 'ARRAY') {
        foreach my $valueItem (@$value) {
            return $self->TRUE if $self->check_value($valueItem) ;
        }
    }
    elsif (ref($value)) {
        die('accept only scalar or array ref');
    }
    else {
        return $self->check_value($value);
    }

    ## reaching here means no condition value satisfies.
    return $self->FALSE;
}

## This method check for a single value or a combined condition values.
sub check_value {
    my ($self, $value) = @_;
    if (ref($value) eq 'ARRAY') {
        foreach my $valueItem (@$value) {
            return $self->FALSE unless $self->check_value($valueItem) ;
        }
        ## reaching here means all condition values are satisfied.
        return $self->TRUE;
    }
    elsif (ref($value)) {
        die('accept only scalar or array ref');
    }
    elsif ($self->_is_negative($value)) {
        $value = $self->_remove_negative_word($value);
        return not ( $self->_check($value) );
    }
    else {
        return $self->_check($value);
    }
}

sub _is_negative {
    my ($self, $value) = @_;
    return
        (defined $value) &&
        ($value =~ / no / || $value =~ / not / || $value =~ /^no / || $value =~ /^not /)
    ;
}

sub _remove_negative_word {
    my ($self, $value) = @_;
    $value =~ s| no ||;
    $value =~ s| not ||;
    $value =~ s|^no ||;
    $value =~ s|^not ||;
    return $value;
}
## ----------------------------------------------------------------------------
## Very basic and naive method.
## a value 'between 2 10' will translate into a call _check_between(2, 10)
## this provide a basic and very common case among the condition subclass
## however is expected to be extends by subclass for it specific value.
## This method check for a single value.
sub _check {
    my ($self, $value) = @_;
    my ($checkValue, @arguments) = $self->_parse_value($value);
    my $checkMethod = "_check_$checkValue";

    return $self->$checkMethod(@arguments);
}
## ----------------------------------------------------------------------------
## register to a Condition Factory.
sub register {
    my ($self, $name) = @_;
    VPoker::Holdem::Strategy::RuleBased::ConditionFactory->register($name, $self);
}

sub replicate {
    my ($self,%args) = @_;
    my %replicationHash = %$self;
    my $replication = bless \%replicationHash, ref($self);
    $replication->strategy($args{'strategy'}) if $args{'strategy'};

    if(exists $args{'value'} && defined $args{'value'}) {
        if($replication->validate($args{'value'})) {
            $replication->value($args{'value'});
        }
        else {
            use Data::Dumper;
            die(sprintf(
                "%s '%s' '%s' ",
                'Error: Invalid value for condition',
                $self->name,
                Dumper($args{'value'}),
            ));
        }
    }

    return $replication;
}

sub validator {
    return VPoker::Holdem::Strategy::RuleBased::ValueValidator->new;
}

sub _parse_value {
    my ($self, $value) = @_;
    return split(' ', $value);
}

1;
