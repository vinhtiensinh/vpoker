package VPoker::Holdem::Strategy::RuleBased::Condition::Player;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Integer);

use strict;
use warnings;
use diagnostics;

sub condition_value {
    my $self = shift;
    return scalar @{$self->strategy->bet_round->players};
}
## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        'players $remain|before|behind$ $>|<|>=|<=|=$ $int$' => sub {
            my ($self, $position, $compare, $value) = @_;

            $compare = '==' if $compare eq '=';
            my $conditionValue = scalar $self->_players_remain_at($position);

            my $expression = "$conditionValue $compare $value";
            return eval $expression;
        },
    );
}

sub _players_remain_at {
    my ($self, $position) = @_;
    my $method = "players_$position";
    return $self->strategy->$method;
};

1;
