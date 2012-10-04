#!/usr/bin/env perl

use strict;
use warnings;

my $DEV = $ENV{DEVELOPMENT};

sub quit {
  my $msg = shift;
  print "$msg\n";
  exit 1;
}

my $cache_dir = shift || quit("No cache directory given");
my $build_dir = shift || quit("No build directory given");
my $dep_filename = shift || quit("No dependencies file given");
my @dependencies;

sub present_dependencies {
  printf "Got %d dependency/es\n", scalar @dependencies;
  foreach my $dep (@dependencies) {
    print $dep->{'dep'}, ":\n";
    foreach my $cmd (@{$dep->{'cmds'}}) {
      print "   $cmd\n";
    }
  }
}

sub check_new_dependency {
  my $line = shift;
  if($line =~ m/^([\w\.-]+):\s*$/) {
    push @dependencies, { 'dep' => $1, 'cmds' => [] };
  }
}

sub check_command {
  my $line = shift;
  if(@dependencies && $line =~ m/^ -\s+(.*)$/) {
    my $command = $1;
    $command =~ s/BUILD_DIR/$build_dir/g;
    my $dep = $dependencies[-1];
    push @{$dep->{'cmds'}}, $command;
  }
}

sub parse_dependencies {
  open (my $DEPENDENCIES_FILE, "<", $dep_filename) || 
    quit("Can't open $dep_filename.");
  while(<$DEPENDENCIES_FILE>) {
    next if m/^#.*|^$/; # avoid comments and empty lines
    chomp;
    check_new_dependency($_);
    check_command($_);
  }
  close $DEPENDENCIES_FILE;
}

# main

my $actual_dir=`pwd`;
chdir $cache_dir;

parse_dependencies($dep_filename);
present_dependencies();

my @cmds;
foreach my $dep (@dependencies) {
  foreach my $cmd (@{$dep->{'cmds'}}) {
    push @cmds, $cmd;  
  }
}
my $full_cmd = join ' ' , split(/ /, join(' && ', @cmds));
system($full_cmd) unless $DEV;

chdir $actual_dir;
