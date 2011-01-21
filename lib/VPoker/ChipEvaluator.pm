package VPoker::ChipEvaluator;
use base qw(VPoker::Base);

__PACKAGE__->has_attributes('table');

## ----------------------------------------------------------------------------
sub validate {
    my ($self, $value) = @_;
    $value = $self->_normalise($value);
    my $symbol_values = {};
    for ($self->_all_symbols) {
        $symbol_values->{$_} = 1;
    }

    eval $self->_expression(
        symbols => $symbol_values,
        value   => $value,
    );
    return $@ ? $self->FALSE : $self->TRUE;
}

## ----------------------------------------------------------------------------
sub evaluate {
    my ($self, $value) = @_;
    $value = $self->_normalise($value);
    my $symbols = {
        bb  => $self->table->current_hand->big_blind,
        sb  => $self->table->current_hand->small_blind,
        pot => $self->table->current_hand->total_pot,
    };
    foreach my $chairNo (0 .. 9) {
        my $player = $self->table->chair($chairNo)->player;
        if($player) {
            $symbols->{"balance$chairNo"} = $player->balance;
            $symbols->{"bet$chairNo"}   = $self->table->current_hand->current_bet_of($player);
        }
        else {
            $symbols->{"balance$chairNo"} = 0;
            $symbols->{"bet$chairNo"}   = 0;
        };
    }

    $symbols->{'currentbet'} = $self->table->current_hand->current_bet;

    return eval $self->_expression(
        value   => $value,
        symbols => $symbols,
    );
}

## ----------------------------------------------------------------------------
sub _all_symbols {
    return qw(
        sb
        bb
        pot
        balance0 balance1 balance2 balance3 balance4 balance5 balance6 balance7 balance8 balance9
        currentbet bet0 bet1   bet2   bet3   bet4   bet5   bet6   bet7   bet8   bet9
    );
}

## ----------------------------------------------------------------------------
sub _expression {
    my ($self, %args) = @_;
    
    my ($symbols, $value) = ($args{symbols}, $args{value});
    $value =~ s|%|*(1/100)|g;
    foreach my $symbol (keys %$symbols) {
        my $symbolValue = $symbols->{$symbol};
        $value =~ s|([\d)]+)$symbol|$1*$symbolValue|g;
        $value =~ s|$symbol|$symbolValue|g;
    }

    return $value;
}

## ----------------------------------------------------------------------------
sub _normalise {
    my ($self, $value) = @_;
    $value =~ s|\s+||g;
    return lc($value);
}

1;