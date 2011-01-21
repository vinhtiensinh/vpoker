package VPoker::OpenHoldem;

use strict;
use warnings;
use diagnostics;

use Exporter;
use VPoker::Holdem::Player;
use VPoker::Table;
use VPoker::Holdem::Strategy::Limit;
use VPoker::PerlOHInteraction;
use VPoker::Debugger;
use Carp qw(confess);

use base qw(Exporter);
our @EXPORT = qw(pl_allin pl_swag pl_raise pl_call pl_play use_strategy);

my ( $table, $player, %openHoldemSymbols, %openHoldemLastSymbols, $autoplayerStrategy );

## -----------------------------------------------------------------------------
sub start {
    $table = VPoker::Table->new();
}

## ----------------------------------------------------------------------------
## This method replace openholdem play method
## To play or not to play is the question
sub pl_play {
    return 1;
}

## ----------------------------------------------------------------------------
## This method is replacement to openholdem allin in formular
## since allin is the initial action to evaluate, we reset the decision
## to UNDECIDED to that decide method have a chance to evaluate the play.
sub pl_allin {

    eval {
        cache_OHSymbols();
        return unless is_new_scrape();

        start() if OHSymbol('issittingin') && !$player;
        if ( is_autoplayer_turn() ) {
            update();
            unless ($player) {
                $player = $table->chair( OHSymbol('chair') )->player;
                $player->strategy($autoplayerStrategy);
                $autoplayerStrategy->player($player);
            }
            if ( not defined $player->hole_cards ) {
                $player->hole_cards(
                    VPoker::Holdem::HoleCards->new(
                        VPoker::Card->new(
                            rank => OHSymbol('$$pr0'),
                            suit => OHSymbol('$$ps0'),
                        ),
                        VPoker::Card->new(
                            rank => OHSymbol('$$pr1'),
                            suit => OHSymbol('$$ps1'),
                        ),
                    )
                );
                debug_message( 'Autoplayer cards is ' . $player->hole_cards->face );
            }

            update_player_action_until($player);
            $player->decide;
            debug_message(sprintf('%s %s %s',
                  $player->name,
                  player_action()->action,
                  player_action()->amount
            ));
            return player_action()->is_allin;
       }
   };

   if($@) {
       debug_message("ERROR:$@");
       return 0;
   }
}

sub is_autoplayer_turn {
    return OHSymbol('ismyturn') && OHSymbol('isfinalanswer');
}

sub update {

    if ( !current_hand()
        && OHSymbol('betround') != VPoker::Holdem::BetRound::BET_ROUND_PREFLOP )
    {
        return;
    }
    elsif (!current_hand()
        && OHSymbol('betround') == VPoker::Holdem::BetRound::BET_ROUND_PREFLOP
        && OHSymbol('playersdealtbits') )
    {
        debug_message("Deal first hand");
        start_new_hand();
    }
    elsif (current_hand()
        && current_hand()->bet_round->round < OHSymbol('betround') )
    {
        start_new_bet_round();
    }
    elsif (current_hand_finished()) {
        finish_current_hand();
        start_new_hand();
    }
}

sub current_hand_finished {

    return 0 unless current_hand();
    return 1 if (
       ( not current_hand()->bet_round->is_preflop )
       && OHSymbol('betround') == VPoker::Holdem::BetRound::BET_ROUND_PREFLOP
       && OHSymbol('playersdealtbits')
    );

    my $currentHoleCards = VPoker::Holdem::HoleCards->new(
        VPoker::Card->new(
            rank => OHSymbol('$$pr0'),
            suit => OHSymbol('$$ps0'),
        ),
        VPoker::Card->new(
            rank => OHSymbol('$$pr1'),
            suit => OHSymbol('$$ps1'),
        ),
    );

    return 1 if ($player->hole_cards && $player->hole_cards->face ne $currentHoleCards->face);

    return 0;
}
## ----------------------------------------------------------------------------
sub deal_new_cards {
    my $betRound = current_hand()->bet_round;
    if ( $betRound->is_preflop ) {

        current_hand()->deal(
            VPoker::Card->new(
                'rank' => OHSymbol('$$cr0') || 'X',
                'suit' => OHSymbol('$$cs0') || 'x',
            ),
            VPoker::Card->new(
                'rank' => OHSymbol('$$cr1') || 'X',
                'suit' => OHSymbol('$$cs1') || 'x',
            ),
            VPoker::Card->new(
               'rank' => OHSymbol('$$cr2') || 'X',
               'suit' => OHSymbol('$$cs2') || 'x',
            ),
        );
    }
    elsif ( $betRound->is_flop ) {
        current_hand()->deal(
            VPoker::Card->new(
                'rank' => OHSymbol('$$cr3') || 'X',
                'suit' => OHSymbol('$$cs3') || 'x',
            )
        );
    }
    elsif ( $betRound->is_turn ) {
        current_hand()->deal(
            VPoker::Card->new(
                'rank' => OHSymbol('$$cr4') || 'X',
                'suit' => OHSymbol('$$cs4') || 'x',
            )
        );
    }
}

## ----------------------------------------------------------------------------
sub finish_current_hand {

    if ( defined $player ) {
        $player->hole_cards(undef);
    }

    for ( my $i = 0 ; $i < 10 ; $i++ ) {
        $table->chair($i)->in_play(0);
    }
    ## Later on
    ## set the winner
    ## set the winning hand
    ## put hand in hand history
}
## ----------------------------------------------------------------------------
sub start_new_hand {
    $table->new_hand;

    debug_message('#############################');
    $table->current_hand->small_blind(OHSymbol('sblind'));
    $table->current_hand->big_blind(OHSymbol('bblind'));
    update_players_dealt();
    current_hand()->update_bet_position();
}

## ----------------------------------------------------------------------------
sub start_new_bet_round {
    update_player_action_until(undef);
    deal_new_cards();
    debug_message(sprintf('----- %s %s -----',
         current_hand()->bet_round->name,
         current_hand()->board->face,
    ));
}


sub update_player_at_hand_start {
    my $chair = shift;
    my $chairNo = $chair->number;
    $chair->in_play(1);
    my $chair_is_empty_or_new_player_arrive =
        $chair->is_empty || ($chair->player->name ne gwp($chairNo));
   
    my $chair_is_of_autoplayer = $player && $chair == $player->chair;
    
    if ( $chair_is_empty_or_new_player_arrive and
       (not $chair_is_of_autoplayer)   
    ) {
        my $newPlayer = VPoker::Holdem::Player->new(name => gwp($chairNo));
        $newPlayer->join( $table, $chairNo );
    }

    $chair->player->balance(
        OHSymbol("balance$chairNo") + OHSymbol("currentbet$chairNo")
    );

    debug_message(sprintf( 'Player %s at %s with %s',
        $chair->player->name, $chairNo, $chair->player->balance
    ));
}

sub setup_dealer_sb_bb_chairs {

    my $dealerChair = $table->chair(OHSymbol('dealerchair'));
    current_hand()->dealer_chair($table->chair(OHSymbol('dealerchair')));

    my $chair = $dealerChair;
    LOOP: {
	$chair = $chair->next_playing;
	next unless $chair->in_play;
	my $chairNo = $chair->number;
        if ( OHSymbol("currentbet$chairNo") == OHSymbol('sblind') ) {
	    my $sbChair = $table->chair($chairNo);
	    set_chair_post_small_blind($sbChair);
            set_chair_post_big_blind($sbChair->next_playing);
	    last;
	}

        redo LOOP if ($chair != $dealerChair);
    }

    if (!current_hand()->big_blind_chair) {
	my $playerChair = $table->chair(OHSymbol('chair'));
	my $playerChairNo = $playerChair->number;
	if (OHSymbol("currentbet$playerChairNo") == OHSymbol('bblind')) {
	    if ($playerChair->previous_playing != $dealerChair) {
                set_chair_post_small_blind($playerChair->previous_playing);
                set_chair_post_big_blind($playerChair);
	    }
	    else {
                set_chair_post_big_blind($playerChair);
	    }
	}
        else {
            if(current_hand()->dealer_chair) {
                my @digits = bl_dec2bin( OHSymbol('playersdealtbits') );
                my @playingSeats = map {$_ == 1} @digits;
                if (scalar @playingSeats == 2) {
                    set_chair_post_small_blind(current_hand()->dealer_chair);
                    set_chair_post_big_blind(current_hand()->dealer_chair->next_playing);
                }
                else {
                    set_chair_post_big_blind(current_hand()->dealer_chair->next_playing);
                }
            }
        }
    }

}

## ----------------------------------------------------------------------------
sub update_players_dealt {

    my @digits      = bl_dec2bin( OHSymbol('playersdealtbits') );
    for(my $chairNo = 0; $chairNo < scalar @digits; $chairNo++) {
        next unless $digits[$chairNo];
        update_player_at_hand_start($table->chair($chairNo));
    }

    setup_dealer_sb_bb_chairs();

}

sub set_chair_post_small_blind {
    my $chair = shift;
    current_hand()->small_blind_chair($chair);
    $chair->player->post( OHSymbol('sblind') );
    debug_message($chair->player->name . ' post sb ' . OHSymbol('sblind'));
}

sub set_chair_post_big_blind {
    my $chair = shift;
    if ( not defined current_hand()->big_blind_chair ) {
        current_hand()->big_blind_chair($chair);
    }
    $chair->player->post( OHSymbol('bblind') );
    debug_message($chair->player->name . ' post bb' . OHSymbol('bblind'));
}

## ----------------------------------------------------------------------------
#  param $forceUpdate: force the update of the player action. For example
#  If a player check, normally we cant be sure if he has check or he has
#  not act
sub update_player_action {
    my $playerToAct = current_hand()->to_act;
    my $chairNo     = $playerToAct->chair->number;
    my @digits      = bl_dec2bin( OHSymbol('playersplayingbits') );

    if ( $digits[$chairNo] ) {
        my $currentBet = $playerToAct->current_bet;
        my $handBet    = current_hand()->current_bet;
        my $newestBet  = OHSymbol("currentbet$chairNo");

        if ( $newestBet > $handBet ) {
            $playerToAct->bet( $newestBet - $currentBet );
            debug_message($playerToAct->name . ' bet ' . $newestBet );
        }
        elsif ( $currentBet < $newestBet ) {
            $playerToAct->call;
            debug_message($playerToAct->name . ' call');

        }
        elsif ( $playerToAct->balance == 0 ) {
	      $playerToAct->pass;
        }
        else {
            if($currentBet <  $handBet) {
                $playerToAct->call;
                debug_message($playerToAct->name . ' call') if $currentBet <  $handBet;
            }
            else {
                $playerToAct->check;
                debug_message($playerToAct->name . ' check ' . OHSymbol("currentbet$chairNo"));
            }
        }
    }
    else {
        $playerToAct->fold;
        debug_message($playerToAct->name . ' fold');
    }
}

## ----------------------------------------------------------------------------
## loop update_player_action until next to act is this one (param $nextToAct)
sub update_player_action_until {
    my $stop = shift;
    
    while ( defined current_hand()->to_act ) {
        if ( defined $stop  && current_hand()->to_act == $stop ) {
            last;
        }
        else {
            update_player_action();
        }
    }
}

## ----------------------------------------------------------------------------
sub bl_dec2bin {
    my $str = unpack( "B32", pack( "N", $_[0] * 1 ) );
    $str =~ s/^0+(?=\d)//;    # otherwise you'll get leading zeros
    my @digits = split( //, $str );
    my @returnDigits = ();
    for ( my $index = scalar @digits - 1 ; $index >= 0 ; $index-- ) {
        push @returnDigits, $digits[$index];
    }
    for ( my $index = scalar @returnDigits ; $index < 10 ; $index++ ) {
        push @returnDigits, 0;
    }
    return @returnDigits;
}

## ----------------------------------------------------------------------------
## This method is replacement to openholdem swag method.
sub pl_swag {
    if (   OHSymbol('ismyturn')
        && defined $player
        && player_action()
        && ( player_action()->is_raise || player_action()->is_bet ) )
    {
        return $player->current_bet;
    }
    return 0;
}

## ----------------------------------------------------------------------------
## This method is replacement to openholdem call method.
sub pl_call {
    return OHSymbol('ismyturn')
      && ( defined $player )
      && player_action()
      ? player_action()->is_call
      || player_action()->is_check
      || player_action()->is_allin
      : 0;
}

## ----------------------------------------------------------------------------
## This method is replacement to openholdem raise method.
sub pl_raise {
    if(  OHSymbol('ismyturn')
      && ( defined $player )
      && player_action()
      && (player_action()->is_bet || player_action()->is_raise || player_action()->is_allin)
    ) {
        return $player->current_bet;
    }
    return 0;
}

###############################################################################
## Helper methods to access current hand, player and table easily            ##
## ----------------------------------------------------------------------------
sub player_action {
    return current_hand()
      ? $table->current_hand->last_action_of($player)
      : undef;
}

## ----------------------------------------------------------------------------
sub current_hand {
    return $table->current_hand if $table;
    return undef;
}

## ---------------------------------------------------------------------------
sub current_bet_round {
    return current_hand()->bet_round;
}

sub OHSymbol {
    my $symbol = shift;
    return $openHoldemSymbols{$symbol};
}

sub cache_OHSymbols {
    my @symbolList = qw(
      issittingin ismyturn isfinalanswer

      playersdealtbits playersplayingbits playersblindbits

      betround chair dealerchair sblind bblind

      balance0 balance1 balance2 balance3 balance4
      balance5 balance6 balance7 balance8 balance9

      currentbet0 currentbet1 currentbet2 currentbet3 currentbet4
      currentbet5 currentbet6 currentbet7 currentbet8 currentbet9

      $$cr0 $$cr1 $$cr2 $$cr3 $$cr4 $$pr0 $$pr1
      $$cs0 $$cs1 $$cs2 $$cs3 $$cs4 $$ps0 $$ps1

    );

    %openHoldemLastSymbols = %openHoldemSymbols;
    foreach my $symbol (@symbolList) {
        $openHoldemSymbols{$symbol} = gws($symbol);
    }
}

sub is_new_scrape {
    return 1 unless (%openHoldemLastSymbols);
    
    foreach my $key (keys %openHoldemSymbols) {
        return 1 if $openHoldemLastSymbols{$key} != $openHoldemSymbols{$key};
    }
    return 0;
}

###############################################################################
###############################################################################
## Expose the table and player object use to write tests only.

sub table {
    return $table;
}

sub player {
    return $player;
}

sub use_strategy {
    $autoplayerStrategy = shift;
}
###############################################################################
###############################################################################

1;
