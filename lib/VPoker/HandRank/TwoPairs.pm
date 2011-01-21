package VPoker::HandRank::TwoPairs;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

use VPoker::Card;

__PACKAGE__->has_attributes( 'pair1', 'pair2', 'kicker' );

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    if ( ref( $args{'pair1'} ) eq 'ARRAY' ) {
        $args{'pair1'} = VPoker::CardSet->new( @{ $args{'pair1'} } );
    }

    if ( ref( $args{'pair2'} ) eq 'ARRAY' ) {
        $args{'pair2'} = VPoker::CardSet->new( @{ $args{'pair2'} } );
    }

    if( $args{'kicker'} && (not ref( $args{'kicker'} )) ) {

        $args{'kicker'} = VPoker::Card->new( $args{'kicker'} );
    }

    $self->init(%args);
    return $self;

}

## ----------------------------------------------------------------------------
sub high_pair_card {
    my $self = shift;
    return $self->high_pair->card(1);
}

## ----------------------------------------------------------------------------
sub low_pair_card {
    my $self = shift;
    return $self->low_pair->card(1);
}

## ----------------------------------------------------------------------------
sub low_pair {
    my $self = shift;
    return $self->pair1->card(1) < $self->pair2->card(1)
      ? $self->pair1
      : $self->pair2;
}

## ----------------------------------------------------------------------------
sub high_pair {
    my $self = shift;
    return $self->pair1->card(1) > $self->pair2->card(1)
      ? $self->pair1
      : $self->pair2;
}

## ----------------------------------------------------------------------------
sub top_kicker {
    my $self = shift;
    return (
         ( $self->kicker == 'A' )
      || ( $self->high_pair_card == 'A' && $self->kicker == 'K' )
      || ( $self->high_pair_card == 'A' && $self->low_pair_card == 'K' && $self->kicker == 'Q')
    );
}

## ----------------------------------------------------------------------------
sub is_two_pairs {
    return 1;
}

sub cards {
    my $self = shift;
    return [$self->kicker, @{$self->pair1->cards}, @{$self->pair2->cards}];
}

1;
