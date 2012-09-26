#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 3;

my $app = '../../bin/install_dependencies.pl';

{
  ok(-r $app, "File readable");
}

{
  my $expected =<<EOF;
Got 1 dependency/es
cairo:
   wget cairo
   ./configure --prefix=...
   make
   make install
EOF
  is(`perl $app cache_dir dep1.txt`, $expected, "Reads line by line avoiding comments");
}


{
  my $expected =<<EOF;
Got 3 dependency/es
dep1:
   cmd1
dep2:
   cmd2
dep3:
   cmd3
EOF
  is(`perl $app cache_dir dep2.txt`, $expected, "Handles multiples dependencies");
}

