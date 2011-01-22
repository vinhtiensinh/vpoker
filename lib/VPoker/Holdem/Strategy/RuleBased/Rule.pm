package VPoker::Holdem::Strategy::RuleBased::Rule;
use base qw(VPoker::Base);

use VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use VPoker::Holdem::Strategy::RuleBased::ActionFactory;
use VPoker::Debugger;

use base qw(VPoker::Holdem::Strategy::RuleBased::Action);

__PACKAGE__->has_attributes('conditions');
__PACKAGE__->delegate(
    'apply'     => [ 'action', 'apply' ],
);

sub new {
    my ($class, %args) = @_;
    if(ref($args{'conditions'}) eq 'HASH') {
        my $conditionObjects = [];
        while(my ($condition, $value) = each %{$args{'conditions'}}) {
            push @$conditionObjects,
                VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(
                     name     => $condition,
                     strategy => $args{'strategy'},
                     value    => $value,
                );
        }
        
        $args{'conditions'} = $conditionObjects;
    }

    my $action = $args{'action'};
    if ($action) {
      unless (ref($action) && $action->isa('VPoker::Holdem::Strategy::RuleBased::Action')) {
        $args{'action'} = VPoker::Holdem::Strategy::RuleBased::ActionFactory->create(
            $action,
            $args{'strategy'},
            $args{'root'},
        );
      }
    }

    my $self = bless {}, $class;
    $self->init(%args);
    return $self;
}

sub stringify_conditions {
    my ($self) = @_;
    return join('|', sort map {$_->to_string} @{$self->conditions});
}

sub is_satisfied {
    my $self = shift;
    foreach my $condition ( @{ $self->conditions } ) {
        return $self->FALSE unless $condition->is_satisfied($condition->value);
    }
    return $self->TRUE;
}

sub validate {
  my $self = shift;
  foreach my $condition (@{$self->conditions}) {
    $condition->validate($condition->value);
  }
  $self->action->validate;
}

1;
