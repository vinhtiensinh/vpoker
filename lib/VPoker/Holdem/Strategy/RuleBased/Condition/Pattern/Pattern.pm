package VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::Pattern;
use base qw(VPoker::Base);

use VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::PatternComponent;
use Carp;

__PACKAGE__->has_attributes ('pattern', 'components');

sub new {
    my ($class, $pattern) = @_;
    my $self = bless {}, $class;
    $self->pattern($pattern);
    $self->_parse_pattern();
    return $self;
}

sub match {
    my ($self, $value) = @_;
    eval {
        $self->process($value);
    };

    return $@ ? $self->FALSE : $self->TRUE;
}

sub process {
    my ($self, $value) = @_;
 
    confess('calling process without a value') if not defined $value;

    my (@valueComponents)   = $self->_parse_value($value);
    my @copiedComponents = @{$self->components};
    my @params = ();
    foreach my $component (@copiedComponents) {

        if ((not scalar @valueComponents) && $component->optional) {
            push @params, undef;
        }
        elsif($component->match($valueComponents[0])) {
            push @params, $valueComponents[0] if $component->type || $component->optional;
            shift @valueComponents;
        }
        elsif($component->optional) {
            push @params, undef;
        }
        else {
            return confess("Invalid pattern value to process $value");
        }
    }

    return confess("Invalid pattern value $value") if @valueComponents;

    return @params;
}

sub _parse_pattern {
    my ($self) = @_;
    $self->components([]) unless $self->components;

    my @components = split(' ', $self->pattern);
    foreach my $componentText (@components) {
        my $component = VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::PatternComponent->new;
        if($componentText =~ s|\$(.+)\$||) {
            my $var = $1;

            if($var =~ /\|/) {
                $component->type('text');
                $component->text([split('\|', $var)]);
            }
            else {
                $component->type($var);
            }
        }
        if($componentText =~ s|\[\s*opt\s*\]||) {
            $component->optional($self->TRUE);
        }
        $component->text( [split('\|', $componentText)] ) if $componentText;
        push @{$self->components}, $component;
    }

}

sub _parse_value {
    my ($self, $value) = @_;
    return split(' ', $value) if $value;
    return $value;
}

1;
