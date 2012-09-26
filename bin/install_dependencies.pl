#!/usr/bin/env perl

use strict;
use warnings;

sub quit {
  my $msg = shift;
  print "$msg\n";
  exit 1;
}

my $cache_dir = shift || quit("No cache directory given");
my $dep_filename = shift || quit("No dependencies file given");
my $current_dependency;
my %dependencies;

sub present_dependencies {
  printf "Got %d dependency/es\n", scalar keys %dependencies;
  foreach my $dep (sort keys %dependencies) {
    print "$dep:\n";
    foreach my $cmd (@{$dependencies{$dep}}) {
      print "   $cmd\n";
    }
  }
}

sub check_new_dependency {
  my $line = shift;
  if($line =~ m/^(\w+):\s*$/) {
    $current_dependency = $1;
    $dependencies{$current_dependency} = [];
  }
}

sub check_command {
  my $line = shift;
  if($current_dependency && $line =~ m/^ -\s+(.*)$/) {
    my $command = $1;
    push @{$dependencies{$current_dependency}}, $command;
  }
}

sub parse_dependencies {
  open my $DEPENDENCIES_FILE, "<", $dep_filename;
  while(<$DEPENDENCIES_FILE>) {
    next if m/^#.*|^$/; # avoid comments and empty lines
    chomp;
    check_new_dependency($_);
    check_command($_);
  }
  close $DEPENDENCIES_FILE;
}

parse_dependencies($dep_filename);
present_dependencies();

