#!/usr/bin/perl
# (c) Oct 2004 Michael Bunk
# This is GPL software.

# This script converts an xdf file from stdin
# into a TEI file on stdout. You will need to
# prepend a TEI header and append some closing
# TEI tags to generate a complete TEI file.
#
# find xdf documented here: http://fdicts.com/xdf.php
#
# short sommary:
#
# # comment line
# word1 [tabulator] word2 [tabulator] note1 [tabulator] note2 [tabulator] translator
#
# The first note column contains information about word class. Standard are:
#m - masculine noun
#f - feminine noun
#n - neuter noun
#pl - plural noun
#n: - noun
#v: - verb
#adj: - adjective
#adv: - adverb
#prep: - preposition
#conj: - conjunction
#interj: - interjection

#Or information about the sphere (domain) where it is commony used if it is not a common word. Standard are:
#[abbr.] - abbreviation		[fin.] - finance		 [myt.] - mythology
#[agr.] - agricultural		[geo.] - geographical		 [phra.] - phrase
#[astr.] - astronomy		[geol.] - geology		 [phy.] - physics
#[aut.] - automobile industry	[hist.] - history		 [polit.] - politics
#[bio.] - biology		[it.] - information technologies [rel.] - religion
#[bot.] - botany			[law.] - law term		 [sex.] - sexual term
#[chem.] - chemistry		[mat.] - mathematics		 [slang.] - slang term
#[chil.] - children speech	[med.] - medicine		 [sport.] - sport term
#[col.] - colloquial		[mil.] - military		 [tech.] - technology
#[el.] - electrotechnics		[mus.] - musical term		 [vulg.] - vulgar term
#
#Or special notes which are specified in each xdf file they are used in. Special notes are in () braces.
#Example:
## Comment. Special note (dv) used for derived verb
#work	some word	(dv)	note for this translation	John Smith

# mapping into TEI:
#
# we have some variables:
# word1
# word2
# note1 = note1a + note1b (pos / domain )
# note2
# translator
#
#<entry>                                                                
#  <form>                                                                   
#    <orth>dog</orth>                                   
#  </form>                                                          
#  <gramGrp><pos>note1a</pos></gramGrp>            
#  <trans>                                                                  
#    <usg type="dom">note1b</usg>
#    <tr>word2</tr>
#  </trans>                                                                
#  <note resp="translator">note2</note> 
#</entry>       

sub htmlencode
{
  $s = shift;
  $s =~ s/&/&amp;/g;
  $s =~ s/\"/&quot;/g;
  $s =~ s/</&lt;/g;
  $s =~ s/>/&gt;/g;
  return $s;
}

sub mywarn
{
  $headword = shift;
  print STDERR "$headword [$.]:\t", @_, "\n";
}

while(<>)
{
  s/\r\n//;

  if(/^\s*#(.*)/)
  {
    # it would be best to put xdf comments into the header
    # but for this we should extract them with some grep command
    # and put them into the header manually
    print "<!-- $_ -->\n";
    next;
  }

  @v = split /\t/;

  undef $pos;
  $domain = "";
  undef $number;
  $gen = "";

  @notes1 = split /\s/, $v[2];
  foreach(@notes1)
  {
     if(/(\w+):/)
     {
       mywarn $v[0], "Pos already set: $1 (had: $pos)" if $pos;
       $pos = $1;
       next;
     }
     if(/(pl\.)/)
     {
       mywarn $v[0], "Number already set: $1 (had: $number)" if $number;
       $number = $1;
       next;
     }
     
     if(/\[([^\.]+)\.\]/)
     {
       mywarn $v[0], "Domain already set: $1 (had: $domain)" if $domain;
       $domain = $1;
       next;
     }
     
     mywarn $v[0], "Unmatched part of note1: '$_'";
  }

  $pos1 = ""; $number1 = ""; $gen1= "";
  $pos1 = "<pos>$pos</pos>" if $pos;
  $number1 = "<number>$number</number>" if $number;
  $gen1 = "<gen>$gen</gen>" if $gen;
  
  print "  <entry>\n";                                                        
  print "     <form>\n";                                                       
  print "       <orth>". htmlencode($v[0]) ."</orth>\n";                                    
  print "     </form>\n";                               
  print "     <gramGrp>$pos1$gen1$number1</gramGrp>\n" if $pos || $number || $gen;
  print "     <trans>\n";                                                     
  print "       <usg type=\"dom\">$domain</usg>\n" if $domain;
  print "       <tr>". htmlencode($v[1]) ."</tr>\n";
  print "     </trans>\n";
  $r = " resp=\"". htmlencode($v[4]) ."\"" if$v[4];
  print "     <note$r>". htmlencode($v[3]) ."</note>\n" if $v[4] || $v[3]; 
  print "   </entry>\n";       
}
