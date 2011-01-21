package VPoker::Holdem::Strategy::RuleBased::Condition::PotOdd;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Pattern);

sub _build_patterns {
    my $self = shift;
    $self->SUPER::_build_patterns;
    $self->add_patterns(
        '$int$ %' => sub {
            my ($self, $number) = @_;
            my $total_pot = $self->strategy->total_pot;
            my $to_call = $self->strategy->player->to_call;

            my $pot_odd = 100 - ($to_call/$total_pot)*100;
            return $self->TRUE if $pot_odd > $number;
        },
    );
}

1;
