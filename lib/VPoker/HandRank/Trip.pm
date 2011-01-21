package VPoker::HandRank::Trip;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

__PACKAGE__->has_attributes( 'trip', 'kickers' );

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    if ( ref( $args{'kickers'} ) eq 'ARRAY' ) {
        $args{'kickers'} = VPoker::CardSet->new( @{ $args{'kickers'} } );
    }

    if ( ref( $args{'trip'} ) eq 'ARRAY' ) {
        $args{'trip'} = VPoker::CardSet->new( @{ $args{'trip'} } );
    }

    $self->init(%args);
    $self->kickers->cards( [ $self->kickers->sort( 'desc' => 1 ) ] );
    return $self;

}

## ----------------------------------------------------------------------------
sub trip_card {
    my $self = shift;
    return $self->trip->card(1);
}

## ----------------------------------------------------------------------------
sub kicker {
    my ( $self, $index ) = @_;
    $index = $index || 1;
    return $self->kickers->card($index);
}

## ----------------------------------------------------------------------------
sub is_trip {
    return 1;
}

##-----------------------------------------------------------------------------
sub cards {
    my $self = shift;
    return [@{$self->trip->cards}, @{$self->kickers->cards}];
}

1;
