package VPoker::Test::Table;
use base qw(VPoker::Table);

use strict;
use warnings;
no warnings 'redefine';
no warnings 'once';

use VPoker::Holdem::Strategy;
use VPoker::Holdem::Strategy::Limit;
use VPoker::Holdem::Strategy::RuleBased;
use VPoker::Holdem::BetRound;
use VPoker::Holdem::HoleCards;
use VPoker::Table;

__PACKAGE__->has_attributes('player_hash', 'autoplayer');

sub create {
    my ($class, %options) = @_;
    
    my $numberOfPlayer = $options{'players'};
    my $strategyType   = $options{'strategyType'};
    my $autoplayerStrategy = $options{'autoplayerStrategy'};

    my $self = $class->new;

    my @playerNames = qw(
        dealer sblinder bblinder firster
        seconder thirder fourther
        fifther sixther seventher 
    );

    my $chairNo = 0;
    $self->player_hash({});

    for (@playerNames) {
      my $player = VPoker::Holdem::Player->new(
          name => $_,
          balance => 2000000000,
      );
      $player->join($self, $chairNo);
      $chairNo++;
      $self->player_hash->{$player->name} = $player;

      my $strategy;
      if (lc($strategyType) eq 'limit') {
        $strategy = VPoker::Holdem::Strategy::Limit->new(player => $player);
      }
      elsif (lc($strategyType) eq 'nolimit') {
        $strategy = VPoker::Holdem::Strategy->new(player => $player);
      }

      $player->strategy($strategy);

      last if $chairNo == $numberOfPlayer;
    }

    $self->autoplayer($options{'autoplayer'}) if $options{'autoplayer'};

    if($autoplayerStrategy) {
      my $autoplayer = $self->player($self->autoplayer);
      $autoplayerStrategy->player($autoplayer);
      $autoplayer->strategy($autoplayerStrategy);
    }

    return $self;
}

sub new_hand {
    my $self = shift;
    $self->SUPER::new_hand;
    $self->current_hand->dealer_chair($self->chair(0));
    $self->current_hand->small_blind_chair($self->chair(1));
    $self->current_hand->big_blind_chair($self->chair(2));
    $self->current_hand->small_blind(1);
    $self->current_hand->big_blind(2);
    $self->player('sblinder')->post($self->current_hand->small_blind);
    $self->player('bblinder')->post($self->current_hand->big_blind);
    for (my $index = 0; $index < 10; $index++) {
      $self->chair($index)->in_play(1) if $self->chair($index)->player;
    }
    $self->current_hand->update_bet_position();
  
}

sub actions {
    my ($self, @actions) = @_;
   
    foreach my $action (@actions) {
        if ($action =~ /deal /) {
          my ($action, @cards) = split(' ', $action);
          $self->current_hand->deal(@cards);
        }
        elsif ($action =~ /cards/) {
          my ($playerName,$action, @cards) = split(' ', $action);
          $playerName = $self->autoplayer if ($playerName eq 'autoplayer');
          $self->player_hole_cards($playerName, @cards);
        }
        else {
            my $amount;

            if ($action =~ s/(\d+)//) {
                $amount = $1;
            }

            my (@elements)  = split(' ', $action);
            my $action = pop @elements;
            my @playerNames = @elements;

            foreach my $playerName (@playerNames) {
                $playerName =~ s/,//g;
                $playerName = $self->autoplayer if ($playerName eq 'autoplayer');
                my $player = $self->player($playerName);

                die("$playerName not existed in test table\n") unless $player;
                $player->strategy->$action($amount);
            }
        }
    }
}

sub player_make_decision {
  my ($self, $player) = @_;
  $self->player($player)->decide;
}

sub player_hole_cards {
  my ($self, $playerName, @cards) = @_;
  my $player = $self->player($playerName);
  $player->hole_cards(VPoker::Holdem::HoleCards->new(@cards));

}

sub player {
  my ($self, $playerName) = @_;
  return $self->player_hash->{$playerName};
}

sub player_strategy {
  my ($self, $playerName, $strategy) = @_;
  if ($strategy) {
    $strategy->player($self->player($playerName));
    $self->player($playerName)->strategy($strategy);
  }
  else {

    die ("No player with name $playerName") unless $self->player($playerName);
    return $self->player($playerName)->strategy;
  }
}

sub autoplayer_decision {
  my $self = shift;
  my $player = $self->player($self->autoplayer);

  return $self->current_hand->last_action_of($player);
}

package main;

sub create_test_table {
  return VPoker::Test::Table->create(@_);
}

1;
