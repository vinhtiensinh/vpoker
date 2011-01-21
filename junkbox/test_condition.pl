#!/usr/bin/perl
use strict;
use warnings;
my $condition  = shift;
system("perl t/vpoker_holdem_strategy_rulebased_condition_$condition.t");
