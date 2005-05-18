#!/usr/bin/perl

$recognized = 0;
while(<>)
{
  # example line in '':
  # '  GDK_slash,  GDK_3,          0,      0,      0,      0x25B,    /* LATIN SMALL LETTER OPEN E */'
  if(/^  (GDK_\w+),\s+(0|GDK_\w+),\s+0,\s+0,\s+0,\s+0x([\w]+),\s+\/\* ([\w ]+)\*\/$/)
  {
    print "\t<row><entry>$1";
    print " + $2" if($2 ne "0");
    $ucode = $3;
    $description = $4;
    $description =~ s/ $//;
    print "</entry><entry>&#x$ucode;</entry><entry>$description</entry></row>\n";
    $recognized++;
    next;
  }
  print STDERR "$.: Unrecognized line '$_'\n";
}
print STDERR "Recognized $recognized lines.\n";
