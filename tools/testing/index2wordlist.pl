#!/usr/bin/perl -w

die "Call me as '$0 <filename>'\n".
 " where <filename> is the name of the dictd index file" if not $ARGV[0];

open my $f,$ARGV[0] or die $!;

while (<$f>) {

  @line = split /\t/;
  print $line[0]."\n";
  $i++;
  }

print STDERR "Processed $i lines.\n";

