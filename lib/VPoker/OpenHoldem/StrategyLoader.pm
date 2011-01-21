package VPoker::OpenHoldem::StrategyLoader;
use strict;
use warnings;
use base qw(VPoker::Base);
use File::Spec;
use VPoker::Holdem::Strategy::RuleBased::ActionFactory;
use File::Basename;

  sub strategy {
    my ($self, $strategy, $path) = @_;
    my @files = $self->load_all_files_recursively($path);
    foreach my $file (@files) {
      $self->load_file($strategy, $file);
    }

  }

  sub load_file {
    my ($self, $strategy, $file) = @_;
    eval {
      my ($name, $directories, $suffix) = File::Basename::fileparse($file);
      $name =~ s/\.vpk$//;
      my $string = $self->read_file($file);
      $strategy->decision($name, VPoker::Holdem::Strategy::RuleBased::ActionFactory->create($string, $strategy, $name));
    };

    if($@) {
      die ("Error load_file $file $@");
    }
  }

  sub read_file {
    my ($self, $file) = @_;
    open FILE, "$file" or die "Couldn't open file: $!"; 
    my @lines = ();
    while(my $line = <FILE>) {
        next if $line =~ /^\s*#/;
        $line =~ s/#.*\n/\n/;
        push @lines, $line;
    }
    my $string = join("", @lines); 
    close FILE;
    return $string;
  }

  sub load_all_files_recursively {
    my ($self, $path) = @_;
    my @files = ();
    opendir DIR, $path;

    my @dir_files = readdir DIR;
    foreach my $file (@dir_files) {
      next if ($file eq '.') or ($file eq '..');
      my $full_path = File::Spec->catfile($path, $file);
      push @files, $full_path if $self->is_vpk_file($full_path);
      push @files, $self->load_all_files_recursively($full_path) if $self->is_dir($full_path);
    }
    close DIR;

    return @files;
  }

  sub is_vpk_file {
    my ($self, $path) = @_;
    return (-f $path and $path =~/\.vpk$/);
  }

  sub is_dir {
    my ($self, $path) = @_;
    return (-d $path);
  }
 


1;
