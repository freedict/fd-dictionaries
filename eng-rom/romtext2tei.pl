#!/usr/bin/perl -w
 
# This program converts a eng-rom database from stdin
# to TEI dictionary format on stdout.
# No sorting is done. 
#
# V1.0 GPL´ed 2002 by H.Eyermann
# V1.1 Michael Bunk: simplified script, converted to TEI P4

sub xmlescape
{
  my $w = shift;
  $w =~ s/&/&amp;/g;
  $w =~ s/\'/&quot;/g;
  $w =~ s/\"/&apos;/g;
  $w =~ s/</&lt;/g;
  $w =~ s/>/&gt;/g;
  $w;
}

# print the header
system 'cat eng-rom.tei.header';

# read the database from stdin
$orth = "";
while(<>)
{
  # if the line doesn't start with whitespace
  if(/^(\S+)/)
  {
    # if we had read an entry before, output it
    if($orth)
    {
      print<<EOF;
      <entry>
        <form>
          <orth>$orth</orth>
$pron        </form>
$tran      </entry>
EOF
    }
    
    # recognize next headword
    if(/\:(.+)\:/)
    {
      $orth = xmlescape($1);
      $pron = "";
      $tran = "";
    }
    else
    { 
      chomp;
      warn "Line $.: Didn't find headword in '$_'\n"; }
    next;
  }

  # why this, while there is no pronunciation information
  # in the dictionary source?
  if(/^\[(.*)\]$/)
  {
    $pron = "          <pron>$1</pron>\n";
    next;
  }

  chomp;
  next if $_ eq "";

  # parse entry contents
  foreach $tr (split /,/)
  {
    $tr =~ s/^\s*//g;# delete leading
    $tr =~ s/\s*$//g;# and trailing spaces
    $tr = xmlescape($tr);
    $tran .= "        <trans><tr>$tr</tr></trans>\n";
  }

} # while

# print the footer
    print<<EOF
    </body>
  </text>
</TEI.2>
EOF
