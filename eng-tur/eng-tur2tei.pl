#!/usr/bin/perl

open(E, "<ingtur-ing.utf8") || die("can't open ingtur-ing: $!");
open(T, "<ingtur-tur.utf8") || die("can't open ingtur-tur: $!");

while(<E>)
{
  $e = $_;
  $e =~ s/\s*\r\n//;# remove trailing space & newlines
  $t = <T>;
  $t =~ s/\s*\r\n//;
  $t =~ s/^\s*//;# remove leading space
  
  @senses = split /;/, $t;
  
  print "<entry>\n";
  print "     <form>\n";                                                          
  print "       <orth>$e</orth>\n";
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
      print "         <tr>$_</tr>\n";
    }
    print "       </trans>\n";
    print "     </sense>\n";                                                         
  }
  print "   </entry>\n";
}

