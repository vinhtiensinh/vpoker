package VPoker::HandRank::Quad;
use base qw(VPoker::CardSet VPoker::HandRank);

use strict;
use warnings;
use diagnostics;
use Carp qw(confess);

use VPoker::Card;

__PACKAGE__->has_attributes( 'quad', 'kicker' );

sub new {
    my ( $class, %args ) = @_;
    my $self = {};
    bless $self, $class;
    if ( ref( $args{'quad'} ) eq 'ARRAY' ) {
        $args{'quad'} = VPoker::CardSet->new( @{ $args{'quad'} } );
    }

    unless ( ref( $args{'kicker'} ) ) {
        $args{'kicker'} = VPoker::Card->new( $args{'kicker'} );
    }

    $self->init(%args);
    return $self;

}

## ----------------------------------------------------------------------------
sub quad_card {
    my $self = shift;
    return $self->quad->card(1);
}

## ----------------------------------------------------------------------------
sub is_quad {
    return 1;
}

sub cards {
    my $self = shift;
    return [$self->kicker, @{$self->quad}];
}

1;
