package VPoker::Holdem::Strategy::RuleBased::ValueValidator;
use base(VPoker::Base);

use VPoker::Card;
use VPoker::Holdem::HoleCards;
use VPoker::ChipEvaluator;

sub is_int {
    my ($self, $value) = @_;
    return $self->TRUE if defined $value && $value =~ /^\s*\d+\s*$/;
    return $self->FALSE;
}

sub is_number {
    my ($self, $value) = @_;
    return $value =~ m|^\s*\d+\s*$| or $value =~ m|^\s*\d+\.\d+\s*$|;
}

sub is_card {
    my ($self, $value) = @_;
    return VPoker::Card->validate_card_face($value);
}

sub is_hole_cards {
    my ($self, $value) = @_;
    return VPoker::Holdem::HoleCards->validate_card_faces($value);
}

sub is_cardset {
    my ($self, $value) = @_;
    return VPoker::CardSet->validate_card_faces($value);
}

sub is_hand_rank {
    my ($self, $value) = @_;
    return $self->is_any_of(
        $value,
        'straight flush',
        'four of a kind',
        'quad',
        'fullhouse',
        'flush',
        'straight',
        'trip',
        'set',
        'two pairs',                  '2 pairs',
        'pair',                       '1 pair', 'a pair', 'one pair',
        'high cards',                 'nothing',
        'flush draw',
        'straight draw',
        'gut shot straight draw',
        'open ended straight draw',
        'busted belly straight draw',
        'suited',
        'connected',
    ); 
}

sub is_chip_amount {
    my ($self, $value) = @_;
    return VPoker::ChipEvaluator->validate($value);
}

sub is_any_of {
    my ($self, $value, @checkValues) = @_;

    return undef unless $value && scalar @checkValues;
    
    foreach my $valueItem (@checkValues) {
        return $valueItem if $self->normalise_value($valueItem) eq $self->normalise_value($value);
    }

    return undef;
}

sub normalise_value {
    my ($self, $value) = @_;
    if(ref($value) && ref($value) eq 'ARRAY') {
        my $valueItems = [];
        foreach my $tmpValue (@$value) {
            push @$valueItems, $self->normalise_value($tmpValue);
        }
        return $valueItems;
    }
    elsif($value) {
        $value =~ s|^\s+||g;
        $value =~ s|\s+$||g;
        $value =~ s|\s+| |g;
    }
    return $value;
}

1;
