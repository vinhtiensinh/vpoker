package VPoker::Holdem::Strategy::RuleBased::Condition::Pattern::PatternComponent;
use base qw(VPoker::Base);

use VPoker::Holdem::Strategy::RuleBased::ValueValidator;
__PACKAGE__->has_attributes('type', 'optional', 'text');

use constant CHECK_METHOD_FOR => {
    card         => 'is_card',
    number       => 'is_number',
    int          => 'is_int',
    hand         => 'is_hand_rank',
    chip         => 'is_chip_amount',
    holecards    => 'is_hole_cards',
    cardset      => 'is_cardset',
};

sub match {
    my ($self, $value) = @_;
    
    if($self->type && $self->type ne 'text') {
        my $checkMethod = CHECK_METHOD_FOR()->{$self->type};
        return VPoker::Holdem::Strategy::RuleBased::ValueValidator->$checkMethod($value);
    }
    else {

        return VPoker::Holdem::Strategy::RuleBased::ValueValidator->is_any_of(
            $value,
            @{$self->text},
        );
    }
}

1;
