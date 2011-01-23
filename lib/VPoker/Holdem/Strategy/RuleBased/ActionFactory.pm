package VPoker::Holdem::Strategy::RuleBased::ActionFactory;
use base qw(VPoker::Base);

use VPoker::Holdem::Strategy::RuleBased::Action;
use VPoker::Holdem::Strategy::RuleBased::RuleTable;
use VPoker::Holdem::Strategy::RuleBased::Rule;

sub create {
  my ($self, $string, $strategy, $root) = @_;
  if ($string =~ /\[/s) {
    return $self->create_rule_table_horizontal_format($string, $strategy, $root);
  }
  elsif ($string =~ /\|/) {
    return $self->create_rule_table_vertical_format($string, $strategy, $root);
  }
  else {
      $string =~ s/^\s*//;
      $string =~ s/\s*$//;

      if ($root) {
          my $root_replacement = "$root.";
          $string =~ s/\~/$root_replacement/g;
      }

      return VPoker::Holdem::Strategy::RuleBased::Action->new(
          'action'   => $string,
          'strategy' => $strategy,
      );
  }
}

sub create_rule_table_horizontal_format {
  my ($self, $string, $strategy, $root) = @_;
  my @lines = split("\n", $string);
  my $ruleTable = VPoker::Holdem::Strategy::RuleBased::RuleTable->new();

  my $end = 0;
  while (not $end) {
    my $status = 0;
    my $braceCount = 0;
    my @blocktext = ();

    while ($status <= 1) {
      my $line = shift @lines;
      $line =~ s/\s*$//;
      $line =~ s/^\s*//;
      $line =~ s/\s+/ /g;

      die "ERROR: after ']' there should be no more data on the same line '$line'\n $string" if $line =~ /\].+/;
	    my ($countOpen, $countClose) = count_braces($line);
	    die "ERROR: have more than one [ or ] on one line" if ($countOpen > 1 or $countClose > 1);

	    $braceCount = $braceCount + ($countOpen - $countClose);
	    die "ERROR: Invalid syntax braces doesnt match ] found without [" if ($braceCount < 0);
     
      $status = 1 if ($braceCount > 0);
	    $status = 2 if ($status == 1 && $braceCount == 0) or ($countOpen == 1 && $countClose == 1 && $braceCount == 0);
      push @blocktext, $line if $line;
      if (scalar @lines == 0) {
        $end = 1;
        last;
      }
    }

    my $subtext = join("\n", @blocktext);
    $ruleTable->new_rule($self->create_single_rule($subtext, $strategy, $root)) if $subtext;
  }

  $ruleTable->strategy($strategy);
  return $ruleTable;

}

sub create_single_rule {
  my ($self, $string, $strategy, $root) = @_;

  $string =~ s/^[\s\n]*//s;
  my $name = undef; 
  if ($string =~ /^\s*\@/s) {
      $string =~ s/\@\s*(.*?)\s*([\[\n])/$2/;
      $name = $1;
      $name =~ s/\s+/ /g;
  }
   
  $string =~ s/(.*?)\[//;
  my $condition_part = $1;
  my @conditions = split('\|', $condition_part);
  my @condition_objects = ();
  unless ($condition_part =~ /^\s*$/) {
    foreach my $condition_txt (@conditions) {
      my ($condition, $value) = split(':', $condition_txt);
      $condition =~ s/^\s*//g;
      $condition =~ s/\s*$//;
      $value =~ s/^\s*//;
      $value =~ s/\s*$//;
      push @condition_objects, VPoker::Holdem::Strategy::RuleBased::ConditionFactory->create(
        'name'     => lc($condition),
        'value'    => $self->_parse_text_value($value),
        'strategy' => $strategy,
      );
    }
  }

  $string =~ s/\]\s*$//;
  my $action = $self->create($string, $strategy, $root);

  if (@condition_objects) {
      $rule = VPoker::Holdem::Strategy::RuleBased::Rule->new(
          'conditions' => [ @condition_objects ],
          'action'     => $action,
          'strategy'   => $strategy,
          'name'       => $name,
      );

      $strategy->decision($root . '.' . $name, $rule) if $name && $root;
      return $rule;
  }
  else {
      $strategy->decision($root . '.' . $name, $action) if $name && $root;
      $action->name($name);
      return $action;
  }
}

sub count_braces {
  my $line = shift;
  my ($countOpen, $countClose) = (0, 0);
  while($line =~ /\[/g) {$countOpen++}
  while($line =~ /\]/g) {$countClose++}

  return ($countOpen, $countClose);
  
}

sub create_rule_table_vertical_format {
    my ($self, $string, $strategy, $root) = @_;
    my @raw_lines = split("\n", $string);
    my @lines = ();
    die ("Invalid table format $string") if scalar @raw_lines < 2;
    foreach my $line (@raw_lines) {
      chomp($line);
      push @lines, $line if ($line !~ /^\s*$/);
    }

    my $ruleTable = [];

    my @fields = ();
    my $first_line = shift @lines;
    foreach my $field (split('\|', $first_line)) {
      $field =~ s/^\s*//g;
      $field =~ s/\s*$//g;
      push @fields, $field;
    }

    push @$ruleTable, [@fields];
    while(scalar @lines > 0) {
        my $line = shift @lines;
        my (@values) = split('\|', $line);
        push @$ruleTable, $self->_parse_text_value([@values]);
    }

    return VPoker::Holdem::Strategy::RuleBased::RuleTable->new(
        'ruleTable' => $ruleTable,
        'strategy'  =>  $strategy,
    );
}

sub _parse_text_value {
    my ($self, $valueParam) = @_;
    return $valueParam unless $valueParam;

    my $parsedValues = [];
    if(ref($valueParam) eq 'ARRAY') {
        foreach my $value (@$valueParam) {
            push @$parsedValues, $self->_parse_text_value($value);
        }
        return $parsedValues;
    }
    else {
        $valueParam =~ s/\n/ /g;
        $valueParam =~ s/^\s*//g;
        $valueParam =~ s/\s*$//g;
        if($valueParam =~ /,/ || $valueParam=~ /\&/) {
            my @values = split(',', $valueParam);
            foreach my $value (@values) {
                $value = [split('&', $value)] if $value =~ /\&/;
                push @$parsedValues, $self->_parse_text_value($value);
            }
            return $parsedValues;
        }
        else {
            return $valueParam;
        }
    }
}

1;
