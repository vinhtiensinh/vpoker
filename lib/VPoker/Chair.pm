package VPoker::Chair;
use base qw(VPoker::Base);

use strict;
use warnings;
use diagnostics;

__PACKAGE__->has_attributes( 'player', 'number', 'previous', 'next', 'in_play' );

sub next_playing {
    my $self      = shift;
    my $nextChair = $self;
    do { $nextChair = $nextChair->next; } while ( $nextChair->not_in_play );
    return $nextChair;
}

sub is_empty {
    my $self = shift;
    if ($self->player) {
      return $self->FALSE;
    }
    return $self->TRUE;
}

sub previous_playing {
    my $self          = shift;
    my $previousChair = $self;
    do { $previousChair = $previousChair->previous; } while ( $previousChair->not_in_play );
    return $previousChair;
}

1;
