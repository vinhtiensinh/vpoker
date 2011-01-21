package VPoker::HandRank::OnePair;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

__PACKAGE__->has_attributes( 'pair', 'kickers' );

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    if ( ref( $args{'kickers'} ) eq 'ARRAY' ) {
        $args{'kickers'} = VPoker::CardSet->new( @{ $args{'kickers'} } );
    }

    if ( ref( $args{'pair'} ) eq 'ARRAY' ) {
        $args{'pair'} = VPoker::CardSet->new( @{ $args{'pair'} } );
    }

    $self->init(%args);
    $self->kickers->cards( [ $self->kickers->sort( 'desc' => 1 ) ] );
    return $self;

}

## ----------------------------------------------------------------------------
sub pair_card {
    my $self = shift;
    return $self->pair->card(1);
}

## ----------------------------------------------------------------------------
sub kicker {
    my ( $self, $index ) = @_;
    $index = $index || 1;
    return $self->kickers->card($index);
}

## ----------------------------------------------------------------------------
sub is_pair {
    return 1;
}

## ----------------------------------------------------------------------------
sub is_top_pair {
    my $self = shift;
    return $self->pair_card > $self->kicker;
}

## -----------------------------------------------------------------------------
sub top_kicker {
    my $self = shift;
    return $self->kicker == 'A'
      || ( $self->kicker == 'K' && $self->pair_card == 'A' );
}

## ------------------------------------------------------------------------------
sub is_top_pair_top_kicker {
    my $self = shift;
    return $self->is_top_pair && $self->is_top_kicker;
}

sub cards {
    my $self = shift;
    return [@{$self->kickers->cards}, @{$self->pair->cards}];
}

1;
