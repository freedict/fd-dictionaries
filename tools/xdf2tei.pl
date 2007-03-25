#!/usr/bin/perl -w
# $Id: xdf2tei.pl,v 1.5 2007-03-25 11:13:30 micha137 Exp $
# (c) Oct 2004 - July 2005 Michael Bunk
# This is GPL software.
#

use strict;

if(-t)
{
  # we are connected to a terminal - print help
  print STDERR "Call me as: $0 <inputfile.xdf >outputfile.tei\n";
  print STDERR <<'ENDOFDOCS';

This script converts an xdf file from stdin into a TEI file on stdout. You will
need to prepend a TEI header and append some closing TEI tags to generate a
complete TEI file.

xdf was documented here: http://fdicts.com/xdf.php
Now that they moved to http://dicts.info, it seems the xdf format was
abandoned, since I didn't find documentation for it anymore.


Short Summary
-------------

# comment line
word1 [tabulator] word2 [tabulator] note1 [tabulator] note2 [tabulator] translator

The first note column contains information about word class. Standard are:
m - masculine noun
f - feminine noun
n - neuter noun
pl - plural noun
n: - noun
v: - verb
adj: - adjective
adv: - adverb
prep: - preposition
conj: - conjunction
interj: - interjection

Or information about the sphere (domain) where it is commony used if it is not
a common word. Standard are:

[abbr.] - abbreviation		[fin.] - finance		 [myt.] - mythology
[agr.] - agricultural		[geo.] - geographical		 [phra.] - phrase
[astr.] - astronomy		[geol.] - geology		 [phy.] - physics
[aut.] - automobile industry	[hist.] - history		 [polit.] - politics
[bio.] - biology		[it.] - information technologies [rel.] - religion
[bot.] - botany			[law.] - law term		 [sex.] - sexual term
[chem.] - chemistry		[mat.] - mathematics		 [slang.] - slang term
[chil.] - children speech	[med.] - medicine		 [sport.] - sport term
[col.] - colloquial		[mil.] - military		 [tech.] - technology
[el.] - electrotechnics		[mus.] - musical term		 [vulg.] - vulgar term

Or special notes which are specified in each xdf file they are used in. Special
notes are in () braces.

Example:
# Comment. Special note (dv) used for derived verb
work	some word	(dv)	note for this translation	John Smith


Mapping into TEI
----------------

We split each line at the tabulator into 5 variables.
$note1 is further analyzed:

 $word1 -> <orth>
 $word2 -> <tr>
 $note1 = note1a + note1b => <pos> + <usg type="dom">
 $note2 -> <note>
 $translator -> <note resp="$translator">

<entry>
  <form>
    <orth>dog</orth>
  </form>
  <gramGrp><pos>note1a</pos></gramGrp>
  <trans>
    <usg type="dom">note1b</usg>
    <tr>word2</tr>
  </trans>
  <note resp="translator">note2</note>
</entry>
ENDOFDOCS
  exit 0;
}

sub htmlencode
{
  my $s = shift;
  $s =~ s/&/&amp;/g;
  $s =~ s/\"/&quot;/g;
  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;
  return $s;
}

sub mywarn
{
  my $headword = shift;
  print STDERR "$headword [$.]:\t", @_, "\n";
}

my $entries = 0;
while(<>)
{
  # remove DOS line ending
  s/\r\n//;

  # remove Unicode Byte Order Mark
  if(/\xef\xbb\xbf/)
  {
    print STDERR "removing Byte Order Mark\n";
    s/\xef\xbb\xbf//;
  }

  if(/^\s*#(.*)/)
  {
    # it would be best to put xdf comments into the header
    # but for this we should extract them with some grep command
    # and put them into the header manually
    print "<!-- $_ -->\n";
    next;
  }

  my($word1, $word2, $note1, $note2, $translator) = split /\t/;

  if(!defined($word1))
  {
    mywarn '', "Empty headword (word1). Skipping.";
    next;
  }
  if(!defined($word2))
  {
    mywarn '', "Empty translation (word2). Skipping.";
    next;
  }

  my($pos, $number);
  undef $pos;
  my $domain = "";
  undef $number;
  my $genus = "";

  if($note1)
  {
    my @notes1 = split /\s/, $note1;
    foreach(@notes1)
    {
      if(/^(\w+):$/)
      {
	mywarn $word1, "Part-of-Speech already set: $1 (had: $pos; note='$_')" if $pos;
	$pos = $1;
	next;
      }
      if(/^(pl)\.?$/)
      {
	mywarn $word1, "Number already set: $1 (had: $number; note='$_')" if $number;
	$number = $1;
	next;
      }
      if(/^(m|f|n)$/)
      {
	mywarn $word1, "Genus already set: $1 (had: $genus; note='$_')" if $genus;
	$genus = $1;
	next;
      }

      if(/^\[([^\.]+)\.\]$/)
      {
	mywarn $word1, "Domain already set: $1 (had: $domain; note='$_')" if $domain;
	$domain = $1;
	next;
      }

      mywarn $word1, "Unmatched part of note1: '$_'";
    }
  }

  my $pos1 = ""; my $number1 = ""; my $gen1= "";
  $pos1 = "<pos>$pos</pos>" if $pos;
  $number1 = "<number>$number</number>" if $number;
  $gen1 = "<gen>$genus</gen>" if $genus;

  print "  <entry>\n";
  print "     <form>\n";
  print "       <orth>". htmlencode($word1) ."</orth>\n";
  print "     </form>\n";
  print "     <gramGrp>$pos1$gen1$number1</gramGrp>\n" if $pos || $number || $genus;
  print "     <trans>\n";
  print "       <usg type=\"dom\">$domain</usg>\n" if $domain;
  print "       <tr>". htmlencode($word2) ."</tr>\n";
  print "     </trans>\n";
  my $r='';
  $r = " resp=\"". htmlencode($translator) ."\"" if $translator;
  print "     <note$r>". (defined($note2)?htmlencode($note2):'') ."</note>\n"
    if $translator || $note2;
  print "   </entry>\n";
  $entries++;
}
print STDERR "Wrote $entries entries.\n";

