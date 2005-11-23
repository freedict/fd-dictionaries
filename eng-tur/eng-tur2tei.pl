#!/usr/bin/perl

open(E, "<:utf8", "ingtur-ing.utf8") || die("can't open ingtur-ing: $!");
open(T, "<:utf8", "ingtur-tur.utf8") || die("can't open ingtur-tur: $!");
binmode(STDOUT, ":utf8");

sub escape
{
  my $s = shift;
  $s =~ s/&/&amp;/;
  return $s;
}

while(<E>)
{
  $e = $_;
  $e =~ tr/\x{FEFF}//d;# remove Byte Order Mark
  $e =~ s/\s*\r\n//;# remove trailing space & newline

  $t = <T>;
  # `ingtur-tur.utf' contains an invalid unicode character, which
  # leads to `make validation` complaining, if it stays unreplaced:
  # > nsgmls:eng-tur.tei:136233:13:E: non SGML character number 149
  $t =~ tr/\x{95}\x{FEFF}/'/d;# remove Byte Order Mark
  $t =~ s/\s*\r\n//;
  $t =~ s/^\s*//;# remove leading space

  @senses = split /;/, $t;
  
  print "<entry>\n";
  print "     <form>\n";
  print '       <orth>' . escape($e) . "</orth>\n";
  print "     </form>\n";
  $s = 0;
  foreach(@senses)
  {
    $s++;
    s/\s*$//;# remove trailing space
    s/^\s*//;# remove leading space
    print "     <sense n=\"$s\">\n";
    print "       <trans>\n";
    @equiv = split /,/;
    foreach(@equiv)
    {
      s/\s*$//;# remove trailing space
      s/^\s*//;# remove leading space
      print '         <tr>' . escape($_) . "</tr>\n";
    }
    print "       </trans>\n";
    print "     </sense>\n";
  }
  print "   </entry>\n";
}

