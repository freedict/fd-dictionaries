#!/usr/bin/perl -w
# 
# this program converts a ergane database from stdin
# and converts it to tei dictionary format on stdout.
# no sorting whatsoever is done. 
# also the header & footer are just basic shells
#
# GPLed 2000 by H. Eyermann
#
#

# first print the header
print<<EOF;
<!DOCTYPE TEI.2       PUBLIC "-//TEI P3//DTD Main Document Type//EN"  [
   <!ENTITY % TEI.dictionaries "INCLUDE" >
]>

<tei.2>
  <teiHeader>
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
  </teiHeader>
  <text>
    <body>
EOF

# now we can read the database from stdin

while (<>) {
    $_ =~ s/<//g;
    $_ =~ s/>//g;
    if ($_ =~ /^(\S+)/) {
	if ($orth ne "") {
	    print<<EOF;
      <entry>
        <form>
          <orth>$orth</orth>
$pron        </form>
$tran      </entry>
EOF
        }
	$orth = $1;
	$pron = "";
	$tran = "";
    } elsif ($_ =~ /\[(.*)\]/) {
	$pron = "          <pron>$1</pron>\n";
    } else {
	chomp $_;
	$tran .= "        <trans>\n" if ($_ ne "");
	foreach $tr (split ",", $_) {
            $tr =~ s/^\s*//g;     # delete leading spaces
            $tr =~ s/\s*$//g;     # and spaces at the end
	    $tran .= "          <tr>$tr</tr>\n";
	}
	$tran .= "        </trans>\n" if ($_ ne "");
	
    }

}

# finally print the footer:
    print<<EOF
    </body>
  </text>
</tei.2>
EOF












