package VPoker::Base;

use warnings;
use diagnostics;

use Carp;

## ----------------------------------------------------------------------------
## In Only very simple case should a class inherits this method
## simply set the class attributes' values.
sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init(%args);
    return $self;
}

sub init {
    ( $self, %args ) = @_;
    while ( my ( $key, $value ) = each %args ) {
        $self->$key($value);
    }
}

## ----------------------------------------------------------------------------
## Method for child class to generate attributes method, similar to
## Class::Method::Maker but much more simpler.
## eg.
## package SomePackage;
## use base qw(VPoker::Base);
## __PACKAGE_->attributes('attribute1', 'attribute2');
##
sub has_attributes {
    my ( $class, @attributes ) = @_;
    foreach my $attribute (@attributes) {
        my $sub = $class . "::" . $attribute;
        *$sub = sub {
            my ( $self, $value ) = @_;
            if ( scalar @_ > 1 ) {
                $self->{$attribute} = $value;
            }
            return $self->{$attribute};
        };
    }
}

## ----------------------------------------------------------------------------
sub alias {
    my ( $class, %args ) = @_;
    while ( my ( $key, $value ) = each %args ) {
        if ( ref($value) eq 'ARRAY' ) {
            foreach my $valueItem (@$value) {
                $class->alias( $key, $valueItem );
            }
        }
        else {
            my $alias = $class . "::" . $value;
            my $sub   = $class . "::" . $key;
            *$alias = *$sub;
        }
    }
}

## ----------------------------------------------------------------------------
## USE WITH CARE
## This method delegate a class method to a class  attribute method
## for example we have class Car->has_attributes('engine', 'frame');
## and frame->has_attributes('color', 'shape');
## we can set Car->delegate('frame_color' => ['frame', 'color']) so that
## we can call Car->frame_color which essentially call Car->frame->color;
sub delegate {
    my ( $class, %args ) = @_;
    while ( my ( $key, $value ) = each %args ) {
        if ( ref($value) eq 'ARRAY' && scalar @$value == 2 ) {
            my $attribute       = $value->[0];
            my $attributeMethod = $value->[1];
            my $sub             = $class . "::" . $key;
            *$sub = sub {
                my ( $self, @args ) = @_;
                return $self->$attribute->$attributeMethod(@args);
              }
        }
        else {
            die
                "delegate value should be an array of [property, property method]";
        }
    }
}

## -----------------------------------------------------------------------------
sub remove_redundant_spaces {
  my ($self, $string) = @_;
  $string = s/^\s*//g;
  $string = s/\s*$//g;
  $string = s/\s+/ /g;
  return $string;
}

sub TRUE {
    return 1;
}

sub FALSE {
    return '';
}

sub to_string {
    my ($self, $value) = @_;
    {
        use Data::Dumper;
        local $Data::Dumper::Terse  = 1;
        local $Data::Dumper::Indent = 0;
        return Dumper($value);
    }
}
sub AUTOLOAD {
    return if $AUTOLOAD =~ /DESTROY/;


    my $self = shift;
    my $method = $AUTOLOAD;
    $method =~ s/^.*://;
    if ($method =~ /^not_/) {
        $method =~ s/^not_//;
        return not $self->$method(@_);
    }
    if ($method =~ /^no_/) {
        $method =~ s/^no_//;
        return not $self->$method(@_);
    }
    if ($method =~ /_no_/) {
        $method =~ s/_no_/_/;
        return not $self->$method(@_);
    }
    if ($method =~ /_not_/) {
        $method =~ s/_not_/_/;
        return not $self->$method(@_);
    }
    if ($method =~ /_not$/) {
        $method =~ s/_not$//;
        return not $self->$method(@_);
    }

    croak("$method undefined for ". ref($self));
}

1;
