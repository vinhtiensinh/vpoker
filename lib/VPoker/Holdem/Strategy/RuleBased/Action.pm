package VPoker::Holdem::Strategy::RuleBased::Action;
use strict;
use warnings;

use base qw(VPoker::Base);

use VPoker::ChipEvaluator;

__PACKAGE__->has_attributes('action', 'strategy', 'name');

sub apply {
    my $self = shift;
    
    my @actions = split(',', $self->action);
    foreach my $action (@actions) {
        $action =~ s/^\s*//g;
        $action =~ s/\s*$//g;
        $action =~ s/\s+$/ /g;
        if ( defined $self->strategy->decision($action) ) {
            if ($self->strategy->decision($action)->is_satisfied) {
                return $self->strategy->decision($action)->apply;
            }
        }
        else {
            return $self->_apply($action);
        }
    }
    return $self->strategy->check_or_fold;
}

sub _apply {

    my ($self, $single_action) = @_;

    my @elements = split(' ', $single_action);
    my $action = shift @elements;

    die ("unknown action: $action") unless $self->_valid_action($action);
        
    $self->strategy->add_applied_rule($self);
    if ($self->_action_is_any_of($action, 'raise', 'bet', 'reraise') ) {
        my ($amount, $randomFactor) = @elements;
        if($randomFactor && (not $self->_random_true($randomFactor))) {
            return $self->strategy->call;
        }
        else {
            if ($amount) {
              my $evaluator =
                VPoker::ChipEvaluator->new(table => $self->strategy->table);
                $amount = $evaluator->evaluate($amount);
            }
            return $self->strategy->$action($amount);
        }
    }
    else {
        my $randomFactor = shift @elements;
        if($randomFactor && (not $self->_random_true($randomFactor))) {
            return $self->strategy->check_or_fold;
        }
        else {
            return $self->strategy->$action;
        }
    }
}

sub _action_is_any_of {
  my ($self, $action, @values) = @_;
  foreach my $value (@values) {
    return $self->TRUE if ($action eq $value);
  }
  return $self->FALSE;
}


sub _random_true {
    my ($self, $randomFactor) = @_;
    $randomFactor =~ s|%||g;
    $randomFactor = int($randomFactor);
    
    my $range = 100;
    my $random_number = int(rand($range));

    return $random_number <= $randomFactor;
}

sub validate {
  my $self = shift;
  my @actions = split(',', $self->action);
  foreach my $action (@actions) {
    $action =~ s/^\s*//g;
    $action =~ s/\s*$//g;
    $action =~ s/\s+$/ /g;

    if ( not defined $self->strategy->decision($action) ) {
      my @elements = split(' ', $action);
      my $mainAction = shift @elements;
      die ("unknown action: $action") unless $self->_valid_action($mainAction);
      if ($self->strategy->isa('VPoker::Holdem::Strategy::Limit')) {
        die sprintf("Unreconized action '%s'", $action) if (scalar @elements > 0);
      }
      else {
        my $amount = shift @elements;
        my $randomFactor = shift @elements;
        die sprintf("Unreconized action '%s'", join(' ', $action, @elements)) if (scalar @elements > 0);
        die sprintf("Unreconized action '%s'", join(' ', $action, @elements)) if ($randomFactor && $randomFactor !~ /^\d+\%$/);

        if($amount) {
          my $evaluator =
            VPoker::ChipEvaluator->new(table => $self->strategy->table);
          die sprintf("Unreconized action '%s'", join(' ', $action, @elements)) unless $evaluator->validate($amount);
        }
      }
    }
  }   
}

sub _valid_action {
  my ($self, $action) = @_;
  return $self->_action_is_any_of(
      $action,
      'bet', 'call', 'fold', 'raise', 'check'
  );
}

sub is_satisfied {
  my $self = shift;
  return $self->TRUE;
}

1;
