#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 6;

$ENV{DEVELOPMENT} = 1;
my $pwd = `pwd`;
chomp $pwd;
my $app = "$pwd/../../bin/install_dependencies.pl";

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
  is(`perl $app cache_dir build_dir dep1.txt`, $expected, "Reads line by line avoiding comments");
}


{
  my $expected =<<EOF;
Got 3 dependency/es
dep3:
   cmd3
dep2:
   cmd2
dep1:
   cmd1
EOF
  is(`perl $app cache_dir build_dir dep2.txt`, $expected, "Handles multiples dependencies");
}

{
  local $ENV{DEVELOPMENT} = 0;
  system "perl $app . . dep3.txt &>/dev/null";
  ok(-f "file.txt", "Commands execution");
  system "rm -f file.txt";
}

{
  my $expected =<<EOF;
Got 1 dependency/es
dep1:
   ls build_dir
EOF
  
  is(`perl $app cache_dir build_dir dep4.txt`, $expected, "Replace WORK_DIR by build dir");  
}

SKIP: {
skip "too long", 1;
  local $ENV{DEVELOPMENT} = 0;
  mkdir 'cache';
  mkdir 'build';
  system "perl $app $pwd/cache $pwd/build $pwd/dep5.txt &>/dev/null";
  ok(-f "$pwd/build/zlib/lib/libz.a" and -f "$pwd/build/libnpg/lib/libpng.a", 
    'Installing zlib from the scratch');  

  system 'rm -rf cache build';
};
