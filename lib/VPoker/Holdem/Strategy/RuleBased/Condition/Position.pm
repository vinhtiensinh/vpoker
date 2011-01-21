package VPoker::Holdem::Strategy::RuleBased::Condition::Position;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);

## ----------------------------------------------------------------------------
sub condition_value {
    my ($self) = @_;
    return $self->strategy->position;
}

sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    
    $self->add_patterns(
        'early'  => sub {
            my ($self) = @_;
            return $self->strategy->players_behind >= 4;
        },
        'middle' => sub {
            my ($self) = @_;
            return (
                 $self->strategy->players_behind == 2
             or  $self->strategy->players_behind == 3 
            );
        },
        'late'   => sub {
            my ($self) = @_;
            return $self->strategy->players_behind < 2 ;
        },
        'last'   => sub {
            my ($self) = @_;
            return $self->strategy->players_behind == 0 ;
        },
        'SB'     => sub {
            my ($self) = @_;
            return $self->strategy->player->chair == $self->strategy->hand->small_blind_chair;
        },
        'BB'     => sub {
            my ($self) = @_;
            return $self->strategy->player->chair == $self->strategy->hand->big_blind_chair;
        },
        'small blind'     => sub {
            my ($self) = @_;
            return $self->strategy->player->chair == $self->strategy->hand->small_blind_chair;
        },
        'big blind'     => sub {
            my ($self) = @_;
            return $self->strategy->player->chair == $self->strategy->hand->big_blind_chair;
        },
        'button' => sub {
            my ($self,) = @_;
            return $self->strategy->player->chair == $self->strategy->hand->dealer_chair;
        },

        'blind' => sub {
            my ($self,) = @_;
            return $self->_check('SB') || $self->_check('BB');
        },
        'second last' => sub {
            my ($self) = @_;
            return $self->strategy->players_behind == 1 ;
        }
    );
}

1;
