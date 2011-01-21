package VPoker::Holdem::Strategy::RuleBased::ConditionFactory;
use base qw(VPoker::Base);

our %condition_classes = ();

## -----------------------------------------------------------------------------
sub register {
    my ($self,%args) = @_;
    while(my($name, $object) = each %args) {
        if($self->is_registered($name)) {
            die("$name is already registered with ConditionFactory for " . $condition_classes{$name});
        }
        else {
            $condition_classes{$name} = $object;
        }
    }
}

## ----------------------------------------------------------------------------
sub create {
    my ($self, %args) = @_;
    my ($name, $strategy, $value) = ($args{'name'}, $args{'strategy'}, $args{'value'});

    my $condition = $self->get($name)->replicate(
        strategy => $strategy,
        value    => $value,
    );

    return $condition;
}

## ----------------------------------------------------------------------------
sub get {
    my ($self, $name) = @_;
    unless($self->is_registered($name)) {
        die("$name condition is not registered with condition factory");
    }
    return $condition_classes{$name};
}

## ----------------------------------------------------------------------------
sub is_registered {
    my ($self, $name) = @_;
    return exists $condition_classes{$name};
}

## ----------------------------------------------------------------------------
sub _register_conditions {
  my ($self, %args) = @_;

  while(my ($registerName, $condition) = each %args) {
      my $conditionClass = "VPoker::Holdem::Strategy::RuleBased::Condition::$condition";
      $self->register($registerName => $conditionClass->new(name => $registerName));
  }
}

## ----------------------------------------------------------------------------
## This is the part that we will declare various condition that can be used.
use VPoker::Holdem::Strategy::RuleBased::Condition::Hand;
use VPoker::Holdem::Strategy::RuleBased::Condition::ActionRound;
use VPoker::Holdem::Strategy::RuleBased::Condition::BetRound;
use VPoker::Holdem::Strategy::RuleBased::Condition::BoardCards;
use VPoker::Holdem::Strategy::RuleBased::Condition::HoleCards;
use VPoker::Holdem::Strategy::RuleBased::Condition::CurrentBet;
use VPoker::Holdem::Strategy::RuleBased::Condition::Position;
use VPoker::Holdem::Strategy::RuleBased::Condition::Player;
use VPoker::Holdem::Strategy::RuleBased::Condition::Balance;
use VPoker::Holdem::Strategy::RuleBased::Condition::LastRule;
use VPoker::Holdem::Strategy::RuleBased::Condition::Caller;
use VPoker::Holdem::Strategy::RuleBased::Condition::Betting;
use VPoker::Holdem::Strategy::RuleBased::Condition::PreflopBetting;
use VPoker::Holdem::Strategy::RuleBased::Condition::FlopBetting;
use VPoker::Holdem::Strategy::RuleBased::Condition::TurnBetting;
use VPoker::Holdem::Strategy::RuleBased::Condition::Flop;
use VPoker::Holdem::Strategy::RuleBased::Condition::Turn;
use VPoker::Holdem::Strategy::RuleBased::Condition::PotOdd;

__PACKAGE__->_register_conditions(
    'hand'            => 'Hand',
    'action round'    => 'ActionRound',
    'bet round'       => 'BetRound',
    'board'           => 'BoardCards',
    'hole cards'      => 'HoleCards',
    'betting'         => 'Betting',
    'current bet'     => 'CurrentBet',
    'position'        => 'Position',
    'player'          => 'Player',
    'balance'         => 'Balance',
    'last rule'       => 'LastRule',
    'caller'          => 'Caller',
    'preflop betting' => 'PreflopBetting',
    'flop betting'    => 'FlopBetting',
    'turn betting'    => 'TurnBetting',
    'flop'            => 'Flop',
    'turn'            => 'Turn',
    'pot odd'            => 'PotOdd',
);

1;
