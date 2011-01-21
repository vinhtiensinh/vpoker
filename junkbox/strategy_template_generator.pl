#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Text::xSV;

## ----------------------------------------------------------------------------
## Quick and dirty script to quickly generate a strategy base on a predefined
## set of value for each conditions
##
##  seed file contain
##  {
##    'bet round'  => ['preflop', 'flop', 'turn', 'river'],
##    'position'   => ['early', 'middle', 'late'],
##    'hole cards' => ['pair & greater TT', 'AK, AQ'],
##  }
##
##  This is turned into
##
##  [
##      {bet round => preflop},
##      {bet round => flop},
##      { bet round => turn } ...
##  ]
##
##  [
##      {position => early},
##      {position => middle}
##     ....
##  ]
##
##  combine this two we have
##
## [
##      {
##           bet round => preflop,
##           position  => middle,
##      },
##      {
##           bet round => preflop,
##           position  => late,
##      },
##      {
##           bet round => flop,
##           position  => early,
##      },
##      {
##           bet round => flop,
##           position  => early,
##      }
##       ......
## ]
##
## continue to do this with all the conditions and we have all the combination of all the condition
## 
##
##
my $file    = $ARGV[0];
my $outfile = $ARGV[1];

unless( -f $file ) {
    print "File $file not found";
    exit();
}

if($file eq $outfile) {
    print "seed file and output file should not be the same";
    exit();
}

my $hashConditions = do $file;

my @allConditionValues = ();
my @allCombinations    = ({});

while(my ($key, $values) = each %$hashConditions) {
    push @allConditionValues, generate_condition_values($key, $values);
}

foreach my $conditionValue (@allConditionValues) {
    @allCombinations = combine(\@allCombinations, $conditionValue);
}

print_file(\@allCombinations, $outfile);

## ----------------------------------------------------------------------------
sub print_file {
    my ($data, $outFile) = @_;
    my $csv = Text::xSV->new(
        filename => $outFile,
        header   => [ keys %{ $data->[0]} ],
    );
    $csv->print_header;
    foreach my $datum (@$data) {
        $csv->print_data(%$datum);
    }
}

## ----------------------------------------------------------------------------
sub generate_condition_values {
    my ($key, $values) = @_;
    my $valueArrayRef = [];
    foreach my $value (@$values) {
        push @$valueArrayRef, {$key => $value};
    }
    return $valueArrayRef;

}

## ----------------------------------------------------------------------------
sub combine {
    my ($firstValues, $secondValues) = @_;
    my @result;

    foreach my $firstValue (@$firstValues) {
        foreach my $secondValue (@$secondValues) {
            push @result, combine_hash($firstValue, $secondValue);
        }
    }
    return @result;
}

## ----------------------------------------------------------------------------
sub combine_hash {
    my ($hash1, $hash2) = @_;
    my %resultHash = %$hash1;
    while(my ($key, $value) = each %$hash2) {
        $resultHash{$key} = $value;
    }

    return {%resultHash};
}