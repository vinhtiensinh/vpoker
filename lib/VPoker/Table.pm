package VPoker::Table;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;
use VPoker::Chair;
use VPoker::Holdem::Hand;
use Carp qw(confess);

__PACKAGE__->has_attributes(
    'players',   'hands', 'current_hand', 'small_blind',
    'big_blind', 'limit', 'chairs'
);

use constant TABLE_NO_LIMIT    => 0;
use constant TABLE_POT_LIMIT   => 1;
use constant TABLE_FIXED_LIMIT => 2;
use constant MAX_CHAIRS        => 10;

## ----------------------------------------------------------------------------
sub new {
    my ( $class, @args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->init(@args);

    ## Initialize the table's chair and setting the relationship
    ## between the chairs.
    $self->chairs( [] );
    for ( my $i = 0 ; $i < MAX_CHAIRS ; $i++ ) {
        push @{ $self->chairs }, VPoker::Chair->new( number => $i );
    }

    foreach my $chair ( @{ $self->chairs } ) {
        my ( $previousChair, $nextChair );
        $previousChair = $self->chair( $chair->number - 1 );
        $nextChair     = $self->chair( $chair->number + 1 );

        if ( $chair->number == 0 ) {
            $previousChair = $self->chair(9);
        }
        elsif ( $chair->number == 9 ) {
            $nextChair = $self->chair(0);
        }

        $chair->next($nextChair);
        $chair->previous($previousChair);
    }

    ## Initilize the table's hand history
    ## might change to something like HandHistory object if needed.
    $self->hands( [] );

    return $self;

}

## ----------------------------------------------------------------------------
sub chair {
    my ( $self, $index ) = @_;
    confess('invalid') unless defined $index;
    return $self->chairs->[$index];
}

## ----------------------------------------------------------------------------
sub new_hand {
    my $self = shift;
    push @{ $self->hands }, $self->current_hand;
    $self->current_hand( VPoker::Holdem::Hand->new( table => $self ) );
    return $self->current_hand;
}

1;
