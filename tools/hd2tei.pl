#!/usr/bin/perl
#

# 2002 Michael Bunk <kleinerwurm@gmx.net>
# only sgml tei!

$hdfile = shift @ARGV;

if ($hdfile eq "") {
 print stderr "Usage: hd2dict <hdfile>\n";
 print stderr " To convert headword definition dict files to TEI format. Output\n";
 print stderr " is on stdout.\n";
 die;
 }

die "Can't find file \"$hdfile\"" unless -f $hdfile;

open(HDHANDLE, "<".$hdfile);

while (<HDHANDLE>) {
 push(@zeilen,$_);
 }

print "<!DOCTYPE TEI\.2 PUBLIC \"\-//TEI P3//DTD Main Document Type//EN\"\n";
print "\"/usr/share/sgml/tei-3/tei2\.dtd\" \[\n";
print " <!ENTITY % TEI\.dictionaries 'INCLUDE' > \]>\n";
print "<\?xml version='1\.0' encoding='ISO-8859-1'>\n";
print "<tei\.2>\n<teiheader>\n<filedesc>\n<titlestmt><title>".$hdfile."</title>\n";
print "  <respStmt><resp>converted with</resp><name>hd2tei\.pl</name></respStmt>\n";
print "  </titleStmt>\n<publicationStmt><p>freedict\.de\n";

# Statement aus Quelldatei uebernehmen (Zeilen vor dem ersten %h)
for(@zeilen) {
 if (/^%h/) {last;}# Schleife abbrechen
 print $_;
 }

print "  </p></publicationStmt>\n<sourceDesc><p>".$hdfile."</p></sourceDesc></fileDesc></teiHeader>\n";

print "<text><body>\n";

$openentry = 0;

for(@zeilen) {
     chop;
     if(/^%h/) {
       if ($openentry == 1) {
         print "</tr></trans></entry>\n"; 
         $openentry = 0;
         }
       print "<entry><form><orth>".substr($_,3)."</orth></form>\n <trans><tr>";
       next;
       };
     if(/^%d/) {
       $openentry = 1;
       next;
       } 
     if ($openentry == 1) {
       print $_;}
     else { print stderr "Unsinn: ".$_."\n";}
     }
 
print "</body></text></tei.2>\n";

close(HDHANDLE);

