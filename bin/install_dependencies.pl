#!/usr/bin/env perl

use strict;
use warnings;


sub quit {
  my $msg = shift;
  print "$msg\n";
  exit 1;
}

my $dependencies = shift || quit("No input given");


open my $DEPENDENCIES_FILE, "<", $dependencies;

while(<$DEPENDENCIES_FILE>) {
  print "=>$_<= \n";
}


