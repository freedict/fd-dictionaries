#!/usr/bin/perl

# adds phonetics to a tei file.
# phonetics is taken from a file in the format:

# word (ASCII)	TAB	phonetic

# usage: teiaddphon.pl inputfile phoneticfile 
#   output is streamed to stdout
#   a file notfound.txt is generated wich contains all the words not 
#   found in the file phoneticfile

use Unicode::String qw(latin1 utf8);

$infile = shift @ARGV;
$phoneticfile = shift @ARGV;

open IN, "<$infile";
open NOTFOUND, ">>notfound.txt";

while (<IN>) {
  print $_;                  # print the line, no matter else we do
  if ( $_ =~ /<ORTH>/i) {    # in this line we are looking for the headword
    $_  =~ /\<orth\>(.+)\<\/orth\>/i;
    $word = $1;
     $word =~ s/\"/\\\"/g;   # do not allow quotation marks
    $word =~ s/\[/\\\[/g;   # escape [ and ]
    $word =~ s/\]/\\\]/g;
    open PHON, "grep  \"\`echo \"^$word\" | recode utf8..latin1\`\" $phoneticfile|" || die("can't grep");
    $phonet = <PHON>;
    close PHON;
    print NOTFOUND "$word\n" if ($phonet eq "");
    @pho = split /\t/, $phonet;
    chomp $pho[1];
    print "          <pron>$pho[1]</pron>\n";
  }
}
