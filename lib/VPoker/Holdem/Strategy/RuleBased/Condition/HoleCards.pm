package VPoker::Holdem::Strategy::RuleBased::Condition::HoleCards;
use base qw(VPoker::Holdem::Strategy::RuleBased::Condition::Pattern);

## ----------------------------------------------------------------------------
sub _validate {
    my($self, $value) = @_;
    return
        $self->validator->is_hole_cards($value)
          || $self->SUPER::_validate($value)
          || $self->validator->is_any_of(
                 $value,
                 'pair',
                 'suited',
                 'connected',
                 'suited connectors',
                 'gap1',
                 'gap2',
                 'gap3',
             );
}

## ----------------------------------------------------------------------------
sub _check {
    my ($self, $value) = @_;
    if($self->validator->is_hole_cards($value)) {

        return $self->strategy->hole_cards->is($value);
    }
    elsif($self->SUPER::_validate($value)) {
        return $self->SUPER::_check($value);
    }
    else {
        my $checkMethod = 'is_' . join('_', $self->_parse_value($value));
        return $self->strategy->hole_cards->$checkMethod;
    }
}

## ----------------------------------------------------------------------------
sub _build_patterns {
    my $self = shift;
    $self->add_patterns(
        '$pair|connected|suited|gap1|gap2|gap3$ $>|<|>=|<=$ $holecards$' => sub {
            my ($self, $attribute, $compare, $value) = @_;
            return
                $self->_check($attribute) &&
                $self->_check("$compare $value");
        },
        'suited connectors $>|<|>=|<=$ $holecards$' => sub {
            my ($self, $compare, $value) = @_;
            return
                $self->_check('suited connectors') &&
                $self->_check("$compare $value");
        },
        '$>|<|>=|<=$ $holecards$' => sub {
            my ($self, $compare, $value) = @_;
            $compare = '>' if $compare eq 'greater';
            $compare = '<' if $compare eq 'less';

            if($compare    eq '>') {
                return $self->strategy->hole_cards > $value;
            }
            elsif($compare eq '<') {
                return $self->strategy->hole_cards < $value;
            }
            elsif($compare eq '>=') {
                return $self->strategy->hole_cards >= $value;
            }
            elsif($compare eq '<=') {
                return $self->strategy->hole_cards <= $value;
            }
        },
        'used $>|<|>=|<=|is|==$ $int$' => sub {
            my ($self, $compare, $value) = @_;
            my $hand                     = $self->strategy->all_cards->strength;
            my $usedCards                = 0;
            $usedCards++ if $hand->has($self->strategy->hole_cards->card1);
            $usedCards++ if $hand->has($self->strategy->hole_cards->card2);

            $compare = '==' if $compare eq 'is';

            my $expression = "$usedCards $compare $value";
            return eval $expression;
        },
        'used $flush|straight$ draw $>|<|>=|<=|is|==$ $int$' => sub {
            my ($self, $drawType, $compare, $value) = @_;
            my $draw;
            my $usedCards = 0;
            if($drawType eq 'flush') {
                $draw = $self->strategy->all_cards->has_flush_draw;
            }
            elsif($drawType eq 'straight') {
                $draw = $self->strategy->all_cards->has_straight_draw;
            }

            return $self->FALSE unless defined $draw;
            
            $usedCards++ if $draw->has($self->strategy->hole_cards->card1);
            $usedCards++ if $draw->has($self->strategy->hole_cards->card2);

            $compare = '==' if $compare eq 'is';

            my $expression = "$usedCards $compare $value";
            return eval $expression;
        },
    );
}

1;
