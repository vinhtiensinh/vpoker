package VPoker::HandRank::FullHouse;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

__PACKAGE__->has_attributes( 'trip', 'pair' );

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    if ( ref( $args{'pair'} ) eq 'ARRAY' ) {
        $args{'pair'} = VPoker::CardSet->new( @{ $args{'pair'} } );
    }

    if ( ref( $args{'trip'} ) eq 'ARRAY' ) {
        $args{'trip'} = VPoker::CardSet->new( @{ $args{'trip'} } );
    }

    $self->init(%args);
    return $self;

}

## ----------------------------------------------------------------------------
sub trip_card {
    my $self = shift;
    return $self->trip->card(1);
}

## ----------------------------------------------------------------------------
sub pair_card {
    my $self = shift;
    return $self->pair->card(1);
}

## ----------------------------------------------------------------------------
sub is_fullhouse {
    return 1;
}

1;
