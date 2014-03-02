#!/usr/bin/perl -w

# V1.1 6/2002 by Guido Ostkamp, <Guido.Ostkamp@t-online.de>
#  * more dictd-like sorting with by_dict_sort()
#
# V1.0 4/2002 by Michael Bunk, <kleinerwurm@gmx.net>
#  * does some sorting of a tei-file, but without parser (worked out on xml,
#    but might be fine with sgml - i didn't try it)
#  * problem: xml-parser would not tell position, would it?
#  * so let's do without parser ;-)
#  * using some undefined collation order
#  * i wrote this to be able to merge double entrys
#  * sort with an in-memory index of
#    - keyword (first orth)
#    - byte-start-offset of entry in tei file (end is found by
#      outputting until </entry>)
#  * maybe dict.py in the tools-directory of freedict.sf.net could do the same
#    but i don't know python and there is less documentation and it
#    needs a tei.header - uncomfortable...
#  * we could try DB_File (see manpage), but let's try simple hash first
#     key: <orth>-characters
#     value: struct <entry>-offset

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, visit
# <http://www.gnu.org/licenses/gpl-2.0.txt>

use strict;

sub by_dict_sort {
 my $x = $a;
 my $y = $b;

 $x =~ s/[^\d\w\s]//gi; # remove all non-alphanumeric and non-whitespace
 $x =~ s/(.*)/\L$1/gi;  # turn lowercase

 $y =~ s/[^\d\w\s]//gi; # remove all non-alphanumeric and non-whitespace
 $y =~ s/(.*)/\L$1/gi;  # turn lowercase

 $x cmp $y
 }

my $file = shift;

unless(defined $file) {
 print STDERR "\nteisort - sort tei file without using any xml parser (not safe)\n";
 print STDERR "\n The inputfile is expected in XML or SGML TEI format, see http://www.tei-c.org/\n";
 print STDERR " Output is on stdout.\n\n";
 print STDERR " Usage: teisort <teifile>\n";
 print STDERR " <teifile> : name of tei inputfile\n\n";
 die
 }

die "Can't find file \"$file\"" unless -r $file;

open HANDLE, "<".$file;

print STDERR "Generating index in memory...\n";
my ($headend, $footstart, $offset, $entry, %orths, $orth, $counter,
 $tell_now, $tell_lastline);

# when we find "<entry" then we keep on reading until "</entry>",
# but save everything inside a $entry (we could keep the whole text
# in the hash!!! [this is just a notice for future reference
# for myself]). then we look for the "<orth*>$1</orth>" and use
# $1 as key
my $todo = "";
my $offsetOnLine = 0;

my $searchmode = 0;
# 0 = find end of header by finding "<entry"
# 1 = find beginning of entry by looking for "<entry"
#     or find end by looking for "</body>"
# 2 = find end of entry by looking for "</entry>"
# 3 = nothing more to find, we are inside the footer, break;
# input is taken from $todo !

readfile: while (<HANDLE>) {
 $tell_lastline = $tell_now;
 $tell_now = tell;
 $todo .= $_;

 while ($todo ne "") {

  # find end of header
  if (($searchmode == 0) && ($todo =~ /<entry/i)) { #i for case insensitivity
   $searchmode = 1;

   my $eoffset = index "<entry", $todo;
   $headend = $tell_lastline + $eoffset; print STDERR "headoffset: $headend\n";

   $offsetOnLine -= $eoffset;
   $todo = substr $todo, 0, $eoffset;
   next
   }

  # find beginning of entry
  if (($searchmode == 1) && ($todo =~ /<entry/i)) {
   $searchmode = 2;

   my $eoffset = index "<entry", $todo;
   $offset = $tell_lastline + $eoffset;

   $entry = substr $todo, $eoffset;

   $counter++; if ($counter % 100 == 0) { print STDERR " $counter entries\n" }

   $offsetOnLine -= $eoffset;
   $todo = substr $todo, 0, $eoffset;
   next
  }

  # find footer
  if (($searchmode == 1) && ($todo =~ /<\/body>/i)) {
   $searchmode = 3;

   my $eoffset = index("<\/body>", $todo);
   $footstart = $tell_lastline + $eoffset; print STDERR "footoffset: $footstart\n";
   #$offsetOnLine -= $eoffset;
   $todo = "";#substr($todo,0,$eoffset);
   last readfile #exit that loop
  }

  # find end of entry
  if (($searchmode == 2) && ($todo =~ /<\/entry>/i)) {
   $searchmode = 1;

   my $eoffset = index "</entry>", $todo;
   $entry .= substr($todo, 0, 8+$eoffset) . "\n";

   $offsetOnLine -= $eoffset;
   $todo = substr $todo, 0, $eoffset;

   # find orth
   # /s modifies to treat $entry as single line
   if ($entry =~ /<orth.*>(.*)<\/orth>/s) {
    $orth = $1;
    #print STDERR "orth: '$orth'\n";
    }
   else {
    #print STDERR ".";
    warn "no orth found in entry!!! there is something wrong! Entry is <$entry>"
    }

   # we may not overwrite any pair in the hash that we already have
   # but since the entry-elements are read from the tei file again,
   # the " *" is never seen in the output :)
   while(defined $orths{$orth}) { $orth .= " " }

   # save in hash
   $orths{$orth}=$offset;

   next
   }

  # else
  $entry .= $todo;
  $todo = "";
  $offsetOnLine = 0
  }
 }

print STDERR " $counter entries\n";

###############################################################

print STDERR "Outputting sorted entries...\n";

# output header
my $header;
die unless sysseek HANDLE, 0, 0;
sysread HANDLE, $header, $headend;
print $header;

$counter = 0;

# this one simple sort call does the keywork!
foreach $orth (sort by_dict_sort keys %orths) {

 $counter++; if ($counter % 100 == 0) { print STDERR " $counter entries\n" }

 $offset = $orths{$orth};
 #print STDERR "offset: $offset\n";

 sysseek HANDLE, $offset, 0;

 # output until </entry>
 my $stopword = "</entry>";
 my $stopwordpos = 0;
 my $stopwordlength = length $stopword;
 my $c;
 do {
  sysread HANDLE, $c,1;# maybe sysread with more than one byte would be faster...
  print $c;
  if ($c eq substr($stopword, $stopwordpos, 1)) { $stopwordpos++ }
  else { $stopwordpos = 0 }
  }
 until $stopwordpos == $stopwordlength;

 } # foreach

# output footer
my $footer;
die unless sysseek HANDLE, $footstart, 0;
my @stats = stat HANDLE;# fetch tei filesize
die unless @stats;
sysread(HANDLE, $footer, $stats[7]-$footstart);
print $footer;

print STDERR " $counter entries\n";
close HANDLE
