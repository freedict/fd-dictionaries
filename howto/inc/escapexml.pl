#!/usr/bin/perl
while(<>)
{
  s/&/&amp;/g;
  s/</&lt;/g;
  print $_;
}

