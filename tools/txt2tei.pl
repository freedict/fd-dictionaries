#!/usr/bin/perl
# 
# this program converts a ding database from stdin
# and converts it to tei dictionary format on stdout.
# no sorting whatsoever is done. 
# also the heaader & footer are just basic shells
#
# GPL´ed 2000 by H.Eyermann
#
#

$rev = "0";
$sep = ",";
$delm = "\t";


# first print the header
print<<EOF;
<!DOCTYPE TEI.2       PUBLIC "-//TEI P3//DTD Main Document Type//EN"  [
   <!ENTITY % TEI.dictionaries "INCLUDE" >
]>

<tei.2>
  <teiheader>
    <filedesc>
      <titlestmt>
        <title>           </title>
      </titlestmt>
      <publicationstmt>
        <authority>Freedict.de</authority>
      </publicationstmt>
      <sourcedesc>
        <p>http://www.freedict.de</p>
      </sourcedesc>
    </filedesc>
  </teiheader>
  <text>
    <body>
EOF

# now we can read the database from stdin



while (<>) {
  ($ger, $eng) = split "$delm$sep$delm", $_ ;
  $ger =~ /^$delm(.+)$/;  # first field is all characters until end without leading delm
  $ger = $1;
  $eng =~ /^(.+)$delm/;  # first field is all characters until end without leading delm
  $eng = $1;
  if ($rev == "1") {
    $temp = $eng;
    $eng = $ger;
    $ger = $temp;
  }

  chomp $eng;
  $ger =~ s/^\s*//;
  $eng =~ s/^\s*//;
    foreach $ge (split ",", $ger) {
       # match: character - non character followed by nothing, or brackets with text included
      $ge =~ m/{(\S*)}/;
      $gender = $1;
      $pos = (($gender ne "") ? "<pos>n</pos>" : ""); #  if ($gender ne "");
      if ($gender eq "pl")  {
        $gram1 = "<num>pl</num>";
      } else {
        $gram1 = "<num>s</num><gen>$gender</gen>";
      }

      $po= (( $pos ne "") ? "\n        <gramgrp>\n          $pos$gram1\n        </gramgrp>": "");  #  if ($pos ne "");
      $ge =~ s/{\S*}//;  # remove pos in definition
      $eng =~ s/{\S*}//g;  # remove pos in definition
      $ge =~ s/^\s//;    # delete leading spaces
      $eng =~ s/^\s//;    # delete leading spaces
      $ge =~ s/\s*$//;   # delete tailing spaces
      $eng=~ s/\s*$//;   # delete tailing spaces

print<<EOF;
      <entry>
        <form>
          <orth>$ge</orth>
        </form>$po
        <trans>
          <tr>$eng</tr>
        </trans>
      </entry>
EOF
    }
}


# finaly print the footer:
print<<EOF
    </body>
  </text>
</tei.2>
EOF
