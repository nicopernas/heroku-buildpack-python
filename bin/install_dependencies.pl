#!/usr/bin/env perl

use strict;
use warnings;


sub quit {
  my $msg = shift;
  print "$msg\n";
  exit 1;
}

my $cache_dir = shift || quit("No cache directory given");
my $dependencies = shift || quit("No dependencies file given");

open my $DEPENDENCIES_FILE, "<", $dependencies;

while(<$DEPENDENCIES_FILE>) {
  next if m/^#.*/;
  chomp;
  print "=>$_<= \n";
}

close $DEPENDENCIES_FILE;
